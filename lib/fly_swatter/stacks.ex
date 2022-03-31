defmodule FlySwatter.Stacks do
  alias FlySwatter.Stack

  def fn_beta() do
    params =
      [%{"foo" => 1, "bar" => 2}, nil]
      |> Enum.random()
      |> case do
        nil -> nil
        p -> URI.encode_query(p)
      end

    path =
      ["/hello-world", nil]
      |> Enum.random()

    uri = %URI{
      scheme: "https",
      host: "scbqtatfcemmhnxjxrhv.functions.supabase.net",
      path: path,
      query: params
    }

    method = Enum.random([:post, :get])

    %Stack{
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

    %Stack{
      uri: URI.parse(uri),
      headers: [],
      method: :get
    }
  end

  def my_stack(project_id) do
    uri = "https://" <> project_id <> ".supabase.co/rest/v1/metrics?select=*"

    %Stack{
      uri: URI.parse(uri),
      headers: [
        {"apikey", supabase_key()},
        {"authorization", "Bearer #{supabase_key()}"}
      ],
      method: :get
    }
  end

  def realtime_prom() do
    %Stack{
      uri: URI.parse("https://realtime-demo.fly.dev/metrics"),
      headers: [],
      method: :get,
      parser: :prom,
      every: 5_000,
      regions: [:fra]
    }
  end

  defp supabase_key() do
    System.get_env("FS_SUPABASE_KEY") || "blah"
  end
end
