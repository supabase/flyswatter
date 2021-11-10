defmodule FlySwatter.DynamicClient do
  use Tesla

  def new(%{uri: %URI{scheme: scheme, host: host}, headers: headers} = _stack)
      when is_list(headers) do
    middleware = [
      {Tesla.Middleware.BaseUrl, scheme <> "://" <> host},
      {Tesla.Middleware.Headers, merge_headers(headers)}
    ]

    Tesla.client(middleware)
  end

  def do_request(client, %{uri: %URI{path: path} = uri}) when is_nil(path),
    do: do_request(client, %{uri: Map.put(uri, "path", "/")})

  def do_request(client, %{uri: %URI{path: path}} = _stack) do
    Tesla.get(client, path)
  end

  defp merge_headers(headers) do
    headers ++ [{"user-agent", "Fly Swatter - Uptime monitor by Supabase"}]
  end
end
