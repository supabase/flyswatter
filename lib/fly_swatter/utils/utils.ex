defmodule FlySwatter.Utils do
  require Logger

  def bench(function) when is_function(function) do
    function
    |> :timer.tc()
    |> elem(0)
    |> Kernel./(1_000)
  end

  def bench({m, f, a}) do
    :timer.tc(m, f, a)
    |> elem(0)
    |> Kernel./(1_000)
  end

  def run_global_locks(its) when is_integer(its) do
    Logger.info("Setting #{its} locks")

    for i <- 0..its do
      :global.set_lock({__MODULE__, i})
      :global.del_lock({__MODULE__, i})
    end
  end
end
