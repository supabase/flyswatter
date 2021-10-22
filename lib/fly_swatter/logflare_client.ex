defmodule FlySwatter.LogflareClient do
  use Tesla

  @logflare_api_key Application.get_env(:fly_swatter, __MODULE__)[:api_key]
  @logflare_source Application.get_env(:fly_swatter, __MODULE__)[:source]
  @supabase_projects_logflare_endpoint Application.get_env(:fly_swatter, __MODULE__)[
                                         :supabase_projects_endpoint_id
                                       ]

  def new() do
    middleware = [
      {Tesla.Middleware.BaseUrl, "https://api.logflare.app"},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers, [{"x-api-key", @logflare_api_key}]}
    ]

    Tesla.client(middleware)
  end

  def post_data(client, message, metadata) when is_binary(message) and is_map(metadata) do
    data = %{message: message, metadata: metadata}
    Tesla.post(client, "/logs/?source=#{@logflare_source}", data)
  end

  def get_supabase_projects(client) do
    Tesla.get(client, "endpoints/query/#{@supabase_projects_logflare_endpoint}")
  end
end
