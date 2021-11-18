defmodule AsciiSketchWeb.CanvasLive.Show do
  use AsciiSketchWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:canvas, AsciiSketch.get(id))}
  end

  defp page_title(:show), do: "Show Canvas"
end
