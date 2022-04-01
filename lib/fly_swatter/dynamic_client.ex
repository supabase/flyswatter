defmodule FlySwatter.DynamicClient do
  use Tesla

  def new(%{uri: %URI{scheme: scheme, host: host}, headers: headers} = _stack)
      when is_list(headers) do
    middleware = [
      {Tesla.Middleware.BaseUrl, scheme <> "://" <> host},
      {Tesla.Middleware.Headers, merge_headers(headers)},
      Tesla.Middleware.JSON
    ]

    Tesla.client(middleware)
  end

  def do_request(client, %{uri: %URI{} = uri, method: :get} = _stack) do
    Tesla.get(client, URI.to_string(uri))
  end

  def do_request(client, %{uri: %URI{} = uri, method: :post, body: body} = _stack) do
    Tesla.post(client, URI.to_string(uri), body)
  end

  defp merge_headers(headers) do
    headers ++ [{"user-agent", "Fly Swatter - Uptime monitor by Supabase"}]
  end
end
