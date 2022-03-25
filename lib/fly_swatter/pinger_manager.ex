defmodule FlySwatter.PingerManager do
  use GenServer

  require Logger

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [])
  end

  @impl true
  def init(stack) do
    stacks = [
      fn_beta(),
      supabase_com(),
      my_stack("ixlqpcigbdlbmfnvzxtw")
    ]

    for s <- stacks do
      DynamicSupervisor.start_child(FlySwatter.DynamicSupervisor, {FlySwatter.Pinger, s})
    end

    {:ok, stack}
  end

  def fn_beta() do
    params =
      [%{"foo" => 1, "bar" => 2}, nil]
      |> Enum.random()
      |> case do
        nil -> nil
        p -> URI.encode_query(p)
      end

    uri = %URI{
      scheme: "https",
      host: "scbqtatfcemmhnxjxrhv.functions.supabase.net",
      path: "/hello-world",
      query: params
    }

    method = Enum.random([:post, :get])

    %{
      uri: uri,
      headers: [
        {"authorization",
         "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.7beGaAcyg_8eX8GbGqL2ucygXlNgcrXKQoIkvEhZco0"}
      ],
      method: method
    }
  end

  def supabase_com() do
    uri = "https://supabase.com"

    %{
      uri: URI.parse(uri),
      headers: [],
      method: :get
    }
  end

  def my_stack(project_id) do
    uri = "https://" <> project_id <> ".supabase.co/rest/v1/metrics?select=*"

    %{
      uri: URI.parse(uri),
      headers: [
        {"apikey", supabase_key()},
        {"authorization", "Bearer #{supabase_key()}"}
      ],
      method: :get
    }
  end

  defp supabase_key() do
    System.get_env("FS_SUPABASE_KEY") || "blah"
  end
end
