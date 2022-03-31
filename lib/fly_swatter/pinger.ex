defmodule FlySwatter.Pinger do
  use GenServer

  require Logger

  alias FlySwatter.DynamicClient
  alias FlySwatter.LogflareClient
  alias FlySwatter.Stack
  alias FlySwatter.Stacks

  def start_link(%Stack{uri: %URI{}, headers: _headers, regions: [:all]} = stack) do
    GenServer.start_link(__MODULE__, stack)
  end

  def start_link(%Stack{uri: %URI{}, headers: _headers, regions: regions} = stack) do
    if get_region() in regions,
      do: GenServer.start_link(__MODULE__, stack),
      else: {:error, :not_this_region}
  end

  @impl true
  def init(%Stack{uri: %URI{}, headers: _headers} = stack) do
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
    ping(stack.every)

    {:noreply, randomize_config(stack)}
  end

  def ping(delay \\ 60_000) do
    Process.send_after(self(), :ping, delay)
  end

  defp randomize_config(stack) do
    case stack do
      %Stack{uri: %URI{host: "njgfjlqpsydyrpxplfre.functions.supabase.net"}} ->
        Stacks.fn_beta()

      _stack ->
        stack
    end
  end

  defp to_logflare(stack, {:error, reason}, resp_time) do
    metadata = %{
      error: inspect(reason),
      level: :error,
      resp_time: resp_time,
      region: get_region(),
      url: URI.to_string(stack.uri)
    }

    message = "Ping error!!"

    LogflareClient.new()
    |> LogflareClient.post_data(message, metadata)
  end

  defp to_logflare(%Stack{parser: :prom}, {:ok, %Tesla.Env{body: body} = response}, resp_time)
       when is_binary(body) do
    region = get_region()

    json =
      String.split(body, "\n")
      |> Enum.map(&PrometheusParser.parse(&1))
      |> Enum.reject(fn
        {:error, _y} -> true
        {:ok, %PrometheusParser.Line{line_type: "HELP"}} -> true
        {:ok, %PrometheusParser.Line{line_type: "TYPE"}} -> true
        {:ok, %PrometheusParser.Line{line_type: "COMMENT"}} -> true
        {:ok, _y} -> false
      end)
      |> Enum.map(fn {_x, y} -> y end)

    IO.inspect(json)

    metadata = %{
      status_code: response.status,
      level: :info,
      url: response.url,
      method: response.method,
      json: json,
      resp_time: resp_time,
      region: region
    }

    message = "#{response.url} | #{region} | #{response.status} | #{resp_time}"

    LogflareClient.new()
    |> LogflareClient.post_data(message, metadata)
  end

  defp to_logflare(_stack, {:ok, %Tesla.Env{body: body} = response}, resp_time)
       when is_binary(body) do
    region = get_region()

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

  defp to_logflare(_stack, {:ok, %Tesla.Env{body: body} = response}, resp_time)
       when is_map(body) do
    region = get_region()

    metadata = %{
      status_code: response.status,
      level: :info,
      url: response.url,
      method: response.method,
      json: body,
      resp_time: resp_time,
      region: region
    }

    message = "#{response.url} | #{region} | #{response.status} | #{resp_time}"

    LogflareClient.new()
    |> LogflareClient.post_data(message, metadata)
  end

  defp get_region() do
    System.get_env("FLY_REGION", "env_not_set")
    |> String.to_atom()
  end
end
