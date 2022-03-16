defmodule FlySwatter.Pinger do
  use GenServer

  require Logger

  alias FlySwatter.DynamicClient
  alias FlySwatter.LogflareClient
  alias FlySwatter.PingerManager

  def start_link(%{uri: %URI{}, headers: _headers} = stack) do
    GenServer.start_link(__MODULE__, stack)
  end

  @impl true
  def init(%{uri: %URI{}, headers: _headers} = stack) do
    Logger.info("Starting pinger for path: " <> URI.to_string(stack.uri))
    ping(0)
    {:ok, stack}
  end

  @impl true
  def handle_info(:ping, stack) do
    Logger.info("Pinging...")

    start = System.monotonic_time()

    response =
      DynamicClient.new(stack)
      |> DynamicClient.do_request(stack)

    stop = System.monotonic_time()
    resp_time = (stop - start) / 1_000_000

    Logger.info("Sending ping data to Logflare")

    {_status, _response} = to_logflare(stack, response, resp_time)

    Logger.info("Scheduling next ping")
    ping()

    stack =
      case stack do
        %{uri: %URI{host: "njgfjlqpsydyrpxplfre.functions.supabase.net"}} ->
          PingerManager.fn_beta()

        _stack ->
          stack
      end

    {:noreply, stack}
  end

  def ping(delay \\ 60_000) do
    Process.send_after(self(), :ping, delay)
  end

  defp to_logflare(stack, {:error, reason}, resp_time) do
    metadata = %{
      error: inspect(reason),
      level: :error,
      resp_time: resp_time,
      region: System.get_env("FLY_REGION", "not found"),
      url: URI.to_string(stack.uri)
    }

    message = "Ping error!!"

    LogflareClient.new()
    |> LogflareClient.post_data(message, metadata)
  end

  defp to_logflare(_stack, {:ok, %Tesla.Env{body: body} = response}, resp_time)
       when is_binary(body) do
    region = System.get_env("FLY_REGION", "not found")

    metadata = %{
      status_code: response.status,
      level: :info,
      url: response.url,
      method: response.method,
      resp_time: resp_time,
      resp_string: response.body,
      region: region
    }

    message = "#{response.url} | #{region} | #{response.status} | #{resp_time}"

    LogflareClient.new()
    |> LogflareClient.post_data(message, metadata)
  end

  defp to_logflare(_stack, {:ok, %Tesla.Env{body: body} = response}, resp_time) do
    region = System.get_env("FLY_REGION", "not found")

    metadata = %{
      status_code: response.status,
      level: :info,
      url: response.url,
      method: response.method,
      pg_data: body,
      resp_time: resp_time,
      region: region
    }

    message = "#{response.url} | #{region} | #{response.status} | #{resp_time}"

    LogflareClient.new()
    |> LogflareClient.post_data(message, metadata)
  end
end
