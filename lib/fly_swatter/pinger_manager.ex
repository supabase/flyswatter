defmodule FlySwatter.PingerManager do
  use GenServer

  require Logger

  alias FlySwatter.LogflareClient

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [])
  end

  @impl true
  def init(stack) do
    stacks = get_supabase_project_ids() |> gen_supabase_project_stacks() |> Enum.take(5)

    for s <- stacks do
      DynamicSupervisor.start_child(FlySwatter.DynamicSupervisor, {FlySwatter.Pinger, s})
    end

    {:ok, stack}
  end

  defp get_supabase_project_ids() do
    {:ok, %Tesla.Env{body: %{"result" => projects}}} =
      LogflareClient.new()
      |> LogflareClient.get_supabase_projects()

    projects
  end

  defp gen_supabase_project_stacks(projects) when is_list(projects) do
    for %{"project" => project_id} <- projects do
      uri = "https://" <> project_id <> ".supabase.co/rest/v1/"
      URI.parse(uri)
    end
  end
end
