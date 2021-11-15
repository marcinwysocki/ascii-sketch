defmodule AsciiSketchWeb.PageController do
  use AsciiSketchWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
