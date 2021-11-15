defmodule AsciiSketch.Test.CanvasTest do
  use ExUnit.Case

  alias AsciiSketch.Canvas
  alias AsciiSketch.Test.Support.VerticalLine

  setup do
    config = [width: 5, height: 5, empty_character: '+']

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

  describe "apply_change/2" do
    test "applies given change and returns an updated Canvas" do
      change_1 = %VerticalLine{x: 3, y: 2, length: 2, character: '@'}
      change_2 = %VerticalLine{x: 1, y: 0, length: 10, character: '$'}

      assert %Canvas{} = canvas = Canvas.new()

      assert %Canvas{
               lines: [
                 '+++++',
                 '+++++',
                 '+++@+',
                 '+++@+',
                 '+++++'
               ],
               canvas: "+++++\n+++++\n+++@+\n+++@+\n+++++"
             } = updated = Canvas.apply_change(canvas, change_1)

      assert %Canvas{
               lines: [
                 '+$+++',
                 '+$+++',
                 '+$+@+',
                 '+$+@+',
                 '+$+++'
               ],
               canvas: "+$+++\n+$+++\n+$+@+\n+$+@+\n+$+++"
             } = Canvas.apply_change(updated, change_2)
    end
  end

  defp given_canvas_config(base \\ [], changes) do
    Application.put_env(:ascii_sketch, Canvas, Keyword.merge(base, changes))
  end
end
