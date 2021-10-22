defmodule FlySwatter.Pinger do
  use GenServer

  require Logger

  alias FlySwatter.DynamicClient
  alias FlySwatter.LogflareClient

  def start_link(%URI{} = stack) do
    GenServer.start_link(__MODULE__, stack)
  end

  @impl true
  def init(%URI{} = stack) do
    Logger.info("Starting pinger for path: " <> URI.to_string(stack))
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

    {:ok, _response} = to_logflare(response)

    Logger.info("Scheduling next ping")
    ping()

    {:noreply, stack}
  end

  def ping(delay \\ 60_000) do
    Process.send_after(self(), :ping, delay)
  end

  defp to_logflare({:ok, response}) do
    metadata = %{
      status_code: response.status,
      url: response.url,
      method: response.method,
      region: System.get_env("FLY_REGION", "not found")
    }

    message = "Pinged " <> response.url <> " successfully"

    LogflareClient.new()
    |> LogflareClient.post_data(message, metadata)
  end
end
