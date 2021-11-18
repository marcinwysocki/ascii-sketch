defmodule AsciiSketchWeb.LiveHelpers do
  import Phoenix.LiveView.Helpers

  @doc """
  Renders a component inside the `AsciiSketchWeb.ModalComponent` component.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <%= live_modal AsciiSketchWeb.CanvasLive.FormComponent,
        id: @canvas.id || :new,
        action: @live_action,
        canvas: @canvas,
        return_to: Routes.canvas_index_path(@socket, :index) %>
  """
  def live_modal(component, opts) do
    path = Keyword.fetch!(opts, :return_to)
    modal_opts = [id: :modal, return_to: path, component: component, opts: opts]
    live_component(AsciiSketchWeb.ModalComponent, modal_opts)
  end
end
