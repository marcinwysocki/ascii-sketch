defmodule AsciiSketch.Test.CanvasTest do
  use ExUnit.Case

  alias AsciiSketch.Canvas
  alias AsciiSketch.Test.Support.VerticalLine

  describe "new_changeset()" do
    test "returns a changeset" do
      assert %Ecto.Changeset{} = Canvas.new_changeset([])
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
             } = [] |> Canvas.new_changeset() |> Ecto.Changeset.apply_changes()
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
             } = opts |> Canvas.new_changeset() |> Ecto.Changeset.apply_changes()
    end

    test "returns an invalid changeset if width or height <= 0" do
      assert %Ecto.Changeset{valid?: false} = Canvas.new_changeset(width: -10, height: 0)
    end

    test "returns an invalid changeset if empty_character isn't ASCII printable" do
      assert %Ecto.Changeset{valid?: false} = Canvas.new_changeset(empty_character: [321])
    end

    test "returns an invalid changeset if empty_character isn't a charlist" do
      assert %Ecto.Changeset{valid?: false} = Canvas.new_changeset(empty_character: "+")
    end

    test "returns an invalid changeset if empty_character isn't a single character" do
      assert %Ecto.Changeset{valid?: false} = Canvas.new_changeset(empty_character: 'hello')
    end
  end

  # describe "apply_change/2" do
  #   test "applies given change and returns an updated Canvas" do
  #     change_1 = %VerticalLine{x: 3, y: 2, length: 2, character: '@'}
  #     change_2 = %VerticalLine{x: 1, y: 0, length: 10, character: '$'}

  #     assert %Canvas{} = canvas = Canvas.new_changeset())

  #     assert %Canvas{
  #              lines: [
  #                '+++++',
  #                '+++++',
  #                '+++@+',
  #                '+++@+',
  #                '+++++'
  #              ],
  #              canvas: "+++++\n+++++\n+++@+\n+++@+\n+++++"
  #            } = updated = Canvas.apply_change(canvas, change_1)

  #     assert %Canvas{
  #              lines: [
  #                '+$+++',
  #                '+$+++',
  #                '+$+@+',
  #                '+$+@+',
  #                '+$+++'
  #              ],
  #              canvas: "+$+++\n+$+++\n+$+@+\n+$+@+\n+$+++"
  #            } = Canvas.apply_change(updated, change_2)
  #   end
  # end
end
