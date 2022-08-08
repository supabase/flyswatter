defmodule FlySwatter.Bench do
  require Logger

  def run(function) when is_function(function) do
    function
    |> :timer.tc()
    |> elem(0)
    |> Kernel./(1_000)
  end

  def run({m, f, a}) do
    :timer.tc(m, f, a)
    |> elem(0)
    |> Kernel./(1_000)
  end

  def async_global_locks(its) when is_integer(its) do
    for _i <- 0..its do
      Task.async(fn ->
        name = Ecto.UUID.generate()

        Logger.info("Setting #{name} lock")

        :global.set_lock({__MODULE__, name})
        :global.del_lock({__MODULE__, name})
      end)
    end
    |> Task.await_many()
  end
end
