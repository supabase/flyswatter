defmodule FlySwatterWeb.PageController do
  use FlySwatterWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
