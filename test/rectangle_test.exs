defmodule AsciiSketch.Test.RectangleTest do
  use ExUnit.Case

  alias AsciiSketch.Canvas
  alias AsciiSketch.Canvas.Rectangle

  import AsciiSketch.DataCase, only: [errors_on: 1]
  import Ecto.Changeset

  test "test" do
    canvas = [width: 200, height: 100, empty_character: ' '] |> Canvas.new() |> apply_changes()

    IO.puts(canvas)
    IO.puts("\n\n\n")

    rect_1 =
      Rectangle.changeset(%{x: 2, y: 2, height: 50, width: 70, outline: '$'}, canvas)
      |> apply_changes()

    rect_2 =
      Rectangle.changeset(%{x: 40, y: 40, height: 50, width: 50, fill: '*'}, canvas)
      |> apply_changes()

    c1 = Canvas.apply_change(canvas, rect_1) |> apply_changes()

    IO.puts("\n\n\n")
    IO.puts(c1)
    IO.puts("\n\n\n")

    Canvas.apply_change(c1, rect_2) |> apply_changes() |> IO.puts()
  end
end
