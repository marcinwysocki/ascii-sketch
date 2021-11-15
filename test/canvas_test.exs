defmodule AsciiSketch.Test.CanvasTest do
  use ExUnit.Case

  alias AsciiSketch.Canvas

  setup do
    config = [width: 5, height: 5, empty_character: ' ']

    given_canvas_config(config)

    {:ok, %{config: config}}
  end

  describe "new/0" do
    test "creates a struct with an empty canvas", %{config: config} do
      given_canvas_config(config, empty_character: '+')

      assert %Canvas{
               lines: [
                 '+++++',
                 '+++++',
                 '+++++',
                 '+++++',
                 '+++++'
               ],
               canvas: "+++++\n+++++\n+++++\n+++++\n+++++",
               id: _
             } = Canvas.new()
    end
  end

  defp given_canvas_config(base \\ [], changes) do
    Application.put_env(:ascii_sketch, Canvas, Keyword.merge(base, changes))
  end
end
