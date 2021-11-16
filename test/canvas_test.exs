defmodule AsciiSketch.Test.CanvasTest do
  use ExUnit.Case

  alias AsciiSketch.Canvas
  alias AsciiSketch.Test.Support.Dot

  describe "new()" do
    test "returns a changeset" do
      assert %Ecto.Changeset{} = Canvas.new([])
    end

    test "creates a struct with an empty canvas using values from config" do
      assert %Canvas{
               lines: [
                 '+++++',
                 '+++++',
                 '+++++',
                 '+++++',
                 '+++++'
               ],
               canvas: "+++++\n+++++\n+++++\n+++++\n+++++",
               width: 5,
               height: 5,
               id: _
             } = [] |> Canvas.new() |> Ecto.Changeset.apply_changes()
    end

    test "config can be overriden" do
      opts = [height: 2, width: 10, empty_character: '*']

      assert %Canvas{
               lines: [
                 '**********',
                 '**********'
               ],
               canvas: "**********\n**********",
               width: 10,
               height: 2,
               id: _
             } = opts |> Canvas.new() |> Ecto.Changeset.apply_changes()
    end

    test "returns an invalid changeset if width or height <= 0" do
      assert %Ecto.Changeset{valid?: false} = Canvas.new(width: -10, height: 0)
    end

    test "returns an invalid changeset if empty_character isn't ASCII printable" do
      assert %Ecto.Changeset{valid?: false} = Canvas.new(empty_character: [321])
    end

    test "returns an invalid changeset if empty_character isn't a charlist" do
      assert %Ecto.Changeset{valid?: false} = Canvas.new(empty_character: "+")
    end

    test "returns an invalid changeset if empty_character isn't a single character" do
      assert %Ecto.Changeset{valid?: false} = Canvas.new(empty_character: 'hello')
    end
  end

  describe "apply_change/2" do
    test "applies given change and returns an updated Canvas" do
      change_1 = %Dot{x: 3, y: 2, character: '@'}
      change_2 = %Dot{x: 1, y: 0, character: '$'}

      assert %Canvas{} = canvas = [] |> Canvas.new() |> Ecto.Changeset.apply_changes()

      assert %Canvas{
               lines: [
                 '+++++',
                 '+++++',
                 '+++@+',
                 '+++++',
                 '+++++'
               ],
               canvas: "+++++\n+++++\n+++@+\n+++++\n+++++"
             } =
               updated = canvas |> Canvas.apply_change(change_1) |> Ecto.Changeset.apply_changes()

      assert %Canvas{
               lines: [
                 '+$+++',
                 '+++++',
                 '+++@+',
                 '+++++',
                 '+++++'
               ],
               canvas: "+$+++\n+++++\n+++@+\n+++++\n+++++"
             } = updated |> Canvas.apply_change(change_2) |> Ecto.Changeset.apply_changes()
    end
  end
end
