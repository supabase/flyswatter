defmodule FlySwatter.Stacks do
  require Logger

  alias FlySwatter.Stack
  alias FlySwatter.DynamicClient
  alias FlySwatter.LogflareClient

  def ping_stack(stack) do
    Logger.info("Pinging Stack #{stack.uri} ...")

    start = System.monotonic_time()

    response =
      DynamicClient.new(stack)
      |> DynamicClient.do_request(stack)

    stop = System.monotonic_time()
    resp_time = (stop - start) / 1_000_000

    Logger.info("Sending ping data to Logflare")

    case to_logflare(stack, response, resp_time) do
      {:ok, %Tesla.Env{status: 200}} ->
        :noop

      {:ok, %Tesla.Env{}} = response ->
        Logger.warn("Non 200 response from Logflare", error_string: inspect(response))

      {:error, response} ->
        Logger.error("Logflare request error", error_string: inspect(response))
    end
  end

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

  def book_club() do
    %Stack{
      uri: URI.parse("https://book-club.fly.dev/repos/13/requests/new"),
      headers: [],
      method: :post,
      parser: :prom,
      every: 5_000,
      regions: [:fra]
    }
  end

  defp supabase_key() do
    System.get_env("FS_SUPABASE_KEY") || "blah"
  end

  defp to_logflare(stack, {:error, reason}, resp_time) do
    metadata = %{
      error: inspect(reason),
      level: :error,
      resp_time: resp_time,
      region: get_region(),
      url: URI.to_string(stack.uri)
    }

    message = "Ping error!!"

    LogflareClient.new()
    |> LogflareClient.post_data(message, metadata)
  end

  defp to_logflare(%Stack{parser: :prom}, {:ok, %Tesla.Env{body: body} = response}, resp_time)
       when is_binary(body) do
    region = get_region()

    json =
      String.split(body, "\n")
      |> Enum.map(&PrometheusParser.parse(&1))
      |> Enum.reject(fn
        {:error, _y} -> true
        {:ok, %PrometheusParser.Line{line_type: "HELP"}} -> true
        {:ok, %PrometheusParser.Line{line_type: "TYPE"}} -> true
        {:ok, %PrometheusParser.Line{line_type: "COMMENT"}} -> true
        {:ok, _y} -> false
      end)
      |> Enum.map(fn {_x, y} ->
        m = Map.from_struct(y)
        pairs = Enum.map(m.pairs, fn {x, y} -> x <> ":" <> y end)

        int =
          case Integer.parse(m.value) do
            {int, _rem} -> int
            :error -> nil
          end

        m |> Map.put(:value, int) |> Map.put(:pairs, pairs)
      end)

    metadata = %{
      status_code: response.status,
      level: :info,
      url: response.url,
      method: response.method,
      prom: json,
      resp_time: resp_time,
      region: region
    }

    message = "#{response.url} | #{region} | #{response.status} | #{resp_time}"

    LogflareClient.new()
    |> LogflareClient.post_data(message, metadata)
  end

  defp to_logflare(_stack, {:ok, %Tesla.Env{body: body} = response}, resp_time)
       when is_binary(body) do
    region = get_region()

    metadata = %{
      status_code: response.status,
      level: :info,
      url: response.url,
      method: response.method,
      resp_time: resp_time,
      resp_string: response.body,
      region: region
    }

    message = "#{response.url} | #{region} | #{response.status} | #{resp_time}"

    LogflareClient.new()
    |> LogflareClient.post_data(message, metadata)
  end

  defp to_logflare(_stack, {:ok, %Tesla.Env{body: body} = response}, resp_time)
       when is_map(body) or is_list(body) do
    region = get_region()

    metadata = %{
      status_code: response.status,
      level: :info,
      url: response.url,
      method: response.method,
      json: body,
      resp_time: resp_time,
      region: region
    }

    message = "#{response.url} | #{region} | #{response.status} | #{resp_time}"

    LogflareClient.new()
    |> LogflareClient.post_data(message, metadata)
  end

  defp get_region() do
    System.get_env("FLY_REGION", "fra")
    |> String.to_atom()
  end
end
