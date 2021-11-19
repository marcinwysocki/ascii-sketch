defmodule AsciiSketchWeb.CanvasLive.Show do
  use AsciiSketchWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    Phoenix.PubSub.subscribe(AsciiSketch.PubSub, "canvas:#{id}")

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:canvas, AsciiSketch.get(id))
     |> assign(:meta, nil)}
  end

  @impl true
  def handle_info({:drawing_applied, %{canvas: canvas, meta: meta}}, socket) do
    {:noreply,
     socket
     |> assign(:canvas, canvas)
     |> assign(:meta, meta)}
  end

  defp page_title(:show), do: "Show Canvas"
end
