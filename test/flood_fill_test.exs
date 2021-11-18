defmodule AsciiSketch.Test.FloodFillTest do
  use ExUnit.Case

  alias AsciiSketch.Canvas
  alias AsciiSketch.Canvas.FloodFill

  import Ecto.Changeset

  describe "changeset/2" do
    setup do
      canvas = [width: 20, height: 10] |> Canvas.new() |> apply_changes()

      params = %{
        x: 2,
        y: 4,
        character: '@'
      }

      {:ok, %{canvas: canvas, params: params}}
    end

    test "returns a changeset", %{canvas: canvas, params: params} do
      changeset = FloodFill.changeset(params, canvas)

      assert %Ecto.Changeset{} = changeset
      assert %FloodFill{} = apply_changes(changeset)
    end

    test "returns an invalid changeset if start coordinates are outside the canvas",
         %{canvas: canvas, params: params} do
      assert %Ecto.Changeset{valid?: false} =
               FloodFill.changeset(%{params | x: -1, y: -1}, canvas)

      assert %Ecto.Changeset{valid?: false} = FloodFill.changeset(%{params | x: 50, y: 1}, canvas)
      assert %Ecto.Changeset{valid?: false} = FloodFill.changeset(%{params | x: 1, y: 50}, canvas)
    end

    test "returns a valid changeset if an invalid character is passed",
         %{canvas: canvas, params: params} do
      assert %Ecto.Changeset{valid?: false} =
               FloodFill.changeset(%{params | character: "+"}, canvas)

      assert %Ecto.Changeset{valid?: false} =
               FloodFill.changeset(%{params | character: 123}, canvas)

      assert %Ecto.Changeset{valid?: false} =
               FloodFill.changeset(%{params | character: [321]}, canvas)
    end
  end
end
