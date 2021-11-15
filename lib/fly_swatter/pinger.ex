defmodule FlySwatter.Pinger do
  use GenServer

  require Logger

  alias FlySwatter.DynamicClient
  alias FlySwatter.LogflareClient

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

    response =
      DynamicClient.new(stack)
      |> DynamicClient.do_request(stack)

    Logger.info("Sending ping data to Logflare")

    {_status, _response} = to_logflare(response)

    Logger.info("Scheduling next ping")
    ping()

    {:noreply, stack}
  end

  def ping(delay \\ 60_000) do
    Process.send_after(self(), :ping, delay)
  end

  defp to_logflare({:error, reason}) do
    metadata = %{
      error: inspect(reason),
      level: :error,
      region: System.get_env("FLY_REGION", "not found")
    }

    message = "Ping error!!"

    LogflareClient.new()
    |> LogflareClient.post_data(message, metadata)
  end

  defp to_logflare({:ok, response}) do
    {:ok, pg_data} = Jason.decode(response.body)

    metadata = %{
      status_code: response.status,
      level: :info,
      url: response.url,
      method: response.method,
      pg_data: pg_data,
      region: System.get_env("FLY_REGION", "not found")
    }

    message = "Pinged " <> response.url <> " successfully"

    LogflareClient.new()
    |> LogflareClient.post_data(message, metadata)
  end
end
