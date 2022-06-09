defmodule FlySwatter.StackProducer do
  use GenStage

  require Logger

  def start_link(_args) do
    GenStage.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(args) do
    Logger.info("StackProducer started!")
    {:producer, args, buffer_size: :infinity, buffer_keep: :first}
  end

  def ping_stacks(stacks) when is_list(stacks) do
    GenStage.cast(__MODULE__, {:stacks, stacks})
  end

  def handle_cast({:stacks, stacks}, state) do
    Logger.info("Handling Stacks")

    {:noreply, stacks, state}
  end

  def handle_demand(demand, state) when demand > 0 do
    Logger.info("Stacking Stacks")

    stacks = []

    {:noreply, stacks, state}
  end
end
