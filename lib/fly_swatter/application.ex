defmodule FlySwatter.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    topologies = Application.get_env(:libcluster, :topologies) || []

    children = [
      FlySwatterWeb.Telemetry,
      {Phoenix.PubSub, name: FlySwatter.PubSub},
      FlySwatterWeb.Endpoint,
      {Finch, name: FlySwatter.Finch},
      {Cluster.Supervisor, [topologies, [name: FlySwatter.ClusterSupervisor]]},
      FlySwatter.PingerSupervisor,
      FlySwatter.StackProducer,
      FlySwatter.StackConsumerSupervisor
    ]

    opts = [strategy: :one_for_one, name: FlySwatter.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    FlySwatterWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
