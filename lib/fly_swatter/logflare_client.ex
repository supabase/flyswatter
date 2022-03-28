defmodule FlySwatter.LogflareClient do
  use Tesla

  def new() do
    middleware = [
      {Tesla.Middleware.BaseUrl, "https://api.logflare.app"},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers, [{"x-api-key", logflare_api_key()}]}
    ]

    Tesla.client(middleware)
  end

  def post_data(client, message, metadata) when is_binary(message) and is_map(metadata) do
    data = %{message: message, metadata: metadata}
    Tesla.post(client, "/logs/?source=#{logflare_source()}", data)
  end

  def get_supabase_projects(client) do
    Tesla.get(client, "endpoints/query/#{logflare_endpoint()}")
  end

  defp logflare_api_key() do
    System.get_env("FS_LOGFLARE_API_KEY") || "not found"
  end

  defp logflare_source() do
    System.get_env("FS_LOGFLARE_SOURCE") || "not found"
  end

  defp logflare_endpoint() do
    System.get_env("FS_LOGFLARE_ENDPOINT") || "not found"
  end
end
