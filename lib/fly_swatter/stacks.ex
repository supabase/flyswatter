defmodule FlySwatter.Stacks do
  alias FlySwatter.Stack

  def fn_beta() do
    body = %{"name" => "Functions"}

    path =
      ["/hello"]
      |> Enum.random()

    uri = %URI{
      scheme: "https",
      host: "scbqtatfcemmhnxjxrhv.functions.supabase.co",
      path: path,
      query: nil
    }

    method = Enum.random([:post])

    %Stack{
      uri: uri,
      headers: [
        {"authorization", "Bearer " <> System.get_env("FS_FN_ANON_KEY", "bearer not found")}
      ],
      method: method,
      body: body
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
