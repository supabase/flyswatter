defmodule FlySwatter.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      FlySwatterWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: FlySwatter.PubSub},
      # Start the Endpoint (http/https)
      FlySwatterWeb.Endpoint,
      # Start a worker by calling: FlySwatter.Worker.start_link(arg)
      # {FlySwatter.Worker, arg}
      {Finch, name: FlySwatter.Finch},
      FlySwatter.PingerSupervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FlySwatter.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FlySwatterWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
