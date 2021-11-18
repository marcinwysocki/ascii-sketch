defmodule AsciiSketchWeb.Router do
  use AsciiSketchWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {AsciiSketchWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AsciiSketchWeb do
    pipe_through :browser

    live "/canvas/:id", CanvasLive.Show, :show
  end

  scope "/api/v1", AsciiSketchWeb do
    pipe_through :api

    post "/canvas", CanvasController, :create

    scope "/canvas/:id" do
      get "/", CanvasController, :get
      put "/draw", CanvasController, :draw
    end
  end
end
