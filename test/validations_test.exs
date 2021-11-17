defmodule AsciiSketch.Test.ValidationsTest do
  use ExUnit.Case

  alias AsciiSketch.Canvas
  alias AsciiSketch.Canvas.Validations

  import AsciiSketch.DataCase, only: [errors_on: 1]
  import Ecto.Changeset

  describe "validate_coordinates/1" do
    setup do
      types = %{x: :integer, y: :integer}

      {:ok, %{types: {%{}, types}, fields: Map.keys(types)}}
    end

    test "adds an error if the coordinate is < 0", %{types: types, fields: fields} do
      changeset =
        types
        |> cast(%{x: -5, y: -1}, fields)
        |> Validations.validate_coordinates(:x)
        |> Validations.validate_coordinates(:y)

      assert %Ecto.Changeset{valid?: false} = changeset

      assert %{
               x: ["must be greater than or equal to 0"],
               y: ["must be greater than or equal to 0"]
             } = errors_on(changeset)
    end

    test "adds an error if X coordinate exceeds canvas' width", %{types: types, fields: fields} do
      canvas = Canvas.new(width: 5, height: 20) |> apply_changes()

      changeset =
        types
        |> cast(%{x: 10}, fields)
        |> Validations.validate_coordinates(:x, canvas_axis: {:x, canvas})

      assert %Ecto.Changeset{valid?: false} = changeset
      assert %{x: ["out of bounds on axis x"]} = errors_on(changeset)
    end

    test "adds an error if Y coordinate exceeds canvas' hight", %{types: types, fields: fields} do
      canvas = Canvas.new(width: 20, height: 5) |> apply_changes()

      changeset =
        types
        |> cast(%{y: 10}, fields)
        |> Validations.validate_coordinates(:y, canvas_axis: {:y, canvas})

      assert %Ecto.Changeset{valid?: false} = changeset
      assert %{y: ["out of bounds on axis y"]} = errors_on(changeset)
    end

    test "returns a valid changeset for valid params", %{types: types, fields: fields} do
      canvas = Canvas.new(width: 20, height: 20) |> apply_changes()

      changeset =
        types
        |> cast(%{y: 10, x: 10}, fields)
        |> Validations.validate_coordinates(:x, canvas_axis: {:x, canvas})
        |> Validations.validate_coordinates(:y, canvas_axis: {:y, canvas})

      assert %Ecto.Changeset{valid?: true} = changeset
    end
  end

  describe "validate_character/1" do
    setup do
      types = %{char: {:array, :integer}}

      {:ok, %{types: {%{}, types}, fields: Map.keys(types)}}
    end

    test "adds an error if the character isn't ASCII printable", %{types: types, fields: fields} do
      changeset =
        types
        |> cast(%{char: [321]}, fields)
        |> Validations.validate_character(:char)

      assert %Ecto.Changeset{valid?: false} = changeset
      assert %{char: ["must be ASCII printable"]} = errors_on(changeset)
    end

    test "adds an error if the character isn't a single character", %{
      types: types,
      fields: fields
    } do
      changeset =
        types
        |> cast(%{char: 'cat'}, fields)
        |> Validations.validate_character(:char)

      assert %Ecto.Changeset{valid?: false} = changeset
      assert %{char: ["must be a single character"]} = errors_on(changeset)
    end

    test "adds an error if the character isn't a charlist" do
      changeset =
        {%{}, %{char_1: :string, char_2: :integer}}
        |> cast(%{char_1: "@", char_2: 64}, [:char_1, :char_2])
        |> Validations.validate_character(:char_1)
        |> Validations.validate_character(:char_2)

      assert %Ecto.Changeset{valid?: false} = changeset

      assert %{char_1: ["must be a charlist"], char_2: ["must be a charlist"]} =
               errors_on(changeset)
    end

    test "returns a valid changeset for valid params", %{types: types, fields: fields} do
      changeset =
        types
        |> cast(%{char: '@'}, fields)
        |> Validations.validate_character(:char)

      assert %Ecto.Changeset{valid?: true} = changeset
    end
  end
end
