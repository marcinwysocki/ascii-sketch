defmodule AsciiSketch.Test.RectangleTest do
  use ExUnit.Case

  alias AsciiSketch.Canvas
  alias AsciiSketch.Canvas.Rectangle

  import AsciiSketch.DataCase, only: [errors_on: 1]
  import Ecto.Changeset

  describe "changeset/2" do
    setup do
      canvas = [width: 20, height: 10] |> Canvas.new() |> apply_changes()

      params = %{
        x: 2,
        y: 4,
        width: 7,
        height: 5,
        fill: '$',
        outline: '@'
      }

      {:ok, %{canvas: canvas, params: params}}
    end

    test "returns a changeset", %{canvas: canvas, params: params} do
      changeset = Rectangle.changeset(params, canvas)

      assert %Ecto.Changeset{} = changeset
      assert %Rectangle{} = apply_changes(changeset)
    end

    test "returns an invalid changeset if upper left corner coordinates are outside the canvas",
         %{canvas: canvas, params: params} do
      assert %Ecto.Changeset{valid?: false} =
               Rectangle.changeset(%{params | x: -1, y: -1}, canvas)

      assert %Ecto.Changeset{valid?: false} = Rectangle.changeset(%{params | x: 50, y: 1}, canvas)
      assert %Ecto.Changeset{valid?: false} = Rectangle.changeset(%{params | x: 1, y: 50}, canvas)
    end

    test "returns an invalid changeset if the rectangle won't fit on the canvas",
         %{canvas: canvas, params: params} do
      assert %Ecto.Changeset{valid?: false} = Rectangle.changeset(%{params | width: 50}, canvas)
      assert %Ecto.Changeset{valid?: false} = Rectangle.changeset(%{params | height: 50}, canvas)

      assert %{width: ["must fit on the canvas"], height: ["must fit on the canvas"]} =
               errors_on(Rectangle.changeset(%{params | height: 50, width: 50}, canvas))
    end

    test "returns an invalid changeset if both fill and outline are missing",
         %{canvas: canvas, params: params} do
      assert %Ecto.Changeset{valid?: false} =
               Rectangle.changeset(Map.drop(params, [:fill, :outline]), canvas)
    end

    test "returns a valid changeset if only fill or outline is set",
         %{canvas: canvas, params: params} do
      assert %Ecto.Changeset{valid?: true} =
               Rectangle.changeset(Map.drop(params, [:fill]), canvas)

      assert %Ecto.Changeset{valid?: true} =
               Rectangle.changeset(Map.drop(params, [:outline]), canvas)
    end

    test "returns a valid changeset if fill is an invalid character",
         %{canvas: canvas, params: params} do
      assert %Ecto.Changeset{valid?: false} = Rectangle.changeset(%{params | fill: "+"}, canvas)
      assert %Ecto.Changeset{valid?: false} = Rectangle.changeset(%{params | fill: 123}, canvas)
      assert %Ecto.Changeset{valid?: false} = Rectangle.changeset(%{params | fill: [321]}, canvas)
    end

    test "returns a valid changeset if outline is an invalid character",
         %{canvas: canvas, params: params} do
      assert %Ecto.Changeset{valid?: false} =
               Rectangle.changeset(%{params | outline: "+"}, canvas)

      assert %Ecto.Changeset{valid?: false} =
               Rectangle.changeset(%{params | outline: 123}, canvas)

      assert %Ecto.Changeset{valid?: false} =
               Rectangle.changeset(%{params | outline: [321]}, canvas)
    end
  end
end
