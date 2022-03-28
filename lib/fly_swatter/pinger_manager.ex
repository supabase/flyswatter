defmodule FlySwatter.PingerManager do
  alias FlySwatter.Stacks

  use GenServer

  require Logger

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [])
  end

  @impl true
  def init(args) do
    stacks = [
      Stacks.fn_beta(),
      Stacks.supabase_com(),
      Stacks.my_stack("ixlqpcigbdlbmfnvzxtw")
    ]

    for s <- stacks do
      DynamicSupervisor.start_child(FlySwatter.DynamicSupervisor, {FlySwatter.Pinger, s})
    end

    {:ok, args}
  end
end
