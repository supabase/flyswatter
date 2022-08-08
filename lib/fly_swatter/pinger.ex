defmodule FlySwatter.Pinger do
  use GenServer

  require Logger

  alias FlySwatter.Stack
  alias FlySwatter.Stacks
  alias FlySwatter.StackProducer

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
    StackProducer.ping_stacks([stack])

    Logger.info("Scheduling next ping now")
    ping(stack.every)

    {:noreply, randomize_config(stack)}
  end

  def ping(delay \\ 60_000) do
    Process.send_after(self(), :ping, delay)
  end

  defp randomize_config(stack) do
    case stack do
      %Stack{uri: %URI{host: "scbqtatfcemmhnxjxrhv.functions.supabase.co"}} ->
        Stacks.fn_beta()

      _stack ->
        stack
    end
  end

  defp get_region() do
    System.get_env("FLY_REGION", "fra")
    |> String.to_atom()
  end
end
