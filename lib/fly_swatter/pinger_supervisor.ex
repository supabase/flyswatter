defmodule FlySwatter.PingerSupervisor do
  # Automatically defines child_spec/1
  use Supervisor

  def start_link(_args) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_stack) do
    children = [
      {DynamicSupervisor, strategy: :one_for_one, name: FlySwatter.DynamicSupervisor},
      {FlySwatter.PingerManager, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
