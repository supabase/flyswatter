defmodule FlySwatter.StackConsumerSupervisor do
  use ConsumerSupervisor

  def start_link(arg) do
    ConsumerSupervisor.start_link(__MODULE__, arg)
  end

  def init(_arg) do
    children = [
      %{
        id: FlySwatter.StackConsumer,
        start: {FlySwatter.StackConsumer, :start_link, []},
        restart: :transient
      }
    ]

    opts = [
      strategy: :one_for_one,
      subscribe_to: [{FlySwatter.StackProducer, min_demand: 0, max_demand: 10}]
    ]

    ConsumerSupervisor.init(children, opts)
  end
end
