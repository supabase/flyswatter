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
        {"apikey", "KEY"},
        {"authorization", "Bearer KEY"}
      ]
    }
  end

  # defp get_supabase_project_ids() do
  #   {:ok, %Tesla.Env{body: %{"result" => projects}}} =
  #     LogflareClient.new()
  #     |> LogflareClient.get_supabase_projects()
  #
  #   projects
  # end
  #
  # defp gen_supabase_project_stacks(projects) when is_list(projects) do
  #   for %{"project" => project_id} <- projects do
  #     uri = "https://" <> project_id <> ".supabase.co/rest/v1/"
  #     URI.parse(uri)
  #   end
  # end
end
