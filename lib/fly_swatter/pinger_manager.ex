defmodule FlySwatter.PingerManager do
  use GenServer

  require Logger

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [])
  end

  @impl true
  def init(stack) do
    stacks = [my_stack("ixlqpcigbdlbmfnvzxtw")]

    for s <- stacks do
      DynamicSupervisor.start_child(FlySwatter.DynamicSupervisor, {FlySwatter.Pinger, s})
    end

    {:ok, stack}
  end

  defp my_stack(project_id) do
    uri = "https://" <> project_id <> ".supabase.co/rest/v1/metrics?select=*"

    %{
      uri: URI.parse(uri),
      headers: [
        {"apikey", supabase_key()},
        {"authorization", "Bearer #{supabase_key()}"}
      ]
    }
  end

  defp supabase_key() do
    System.get_env("FS_SUPABASE_KEY")
  end
end
