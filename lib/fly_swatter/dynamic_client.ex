defmodule FlySwatter.DynamicClient do
  use Tesla

  def new(%URI{scheme: scheme, host: host} = _stack) do
    middleware = [
      {Tesla.Middleware.BaseUrl, scheme <> "://" <> host},
      {Tesla.Middleware.Headers, [{"user-agent", "Fly Swatter - Uptime monitor by Supabase"}]}
    ]

    Tesla.client(middleware)
  end

  def do_request(client, %URI{path: path} = stack) when is_nil(path),
    do: do_request(client, Map.put(stack, :path, "/"))

  def do_request(client, %URI{path: path} = _stack) do
    Tesla.get(client, path)
  end
end
