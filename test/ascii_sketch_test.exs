defmodule AsciiSketch.Test.AsciiSketchTest do
  use AsciiSketch.DataCase

  alias AsciiSketch.Canvas
  alias AsciiSketch.Canvas.Rectangle
  alias AsciiSketch.Canvas.FloodFill
  alias AsciiSketch.Repo

  describe "create/1" do
    test "returns an empty Canvas" do
      width = 3
      height = 3

      assert {:ok,
              %Canvas{
                width: ^width,
                height: ^height,
                lines: ['+++', '+++', '+++'],
                canvas: "+++\n+++\n+++",
                id: _,
                updated_at: _,
                inserted_at: _
              }} = AsciiSketch.create(width: width, height: height)
    end

    test "creates a canvas in the DB" do
      assert {:ok, %Canvas{id: id}} = AsciiSketch.create()
      assert [%Canvas{id: ^id}] = Repo.all(Canvas)
    end

    test "returns an error if opts validation fails" do
      assert {:error, _} = AsciiSketch.create(width: -10)
    end
  end

  describe "get/1" do
    test "fetches a canvas by id" do
      assert {:ok, %Canvas{id: id_1}} = AsciiSketch.create()
      assert {:ok, %Canvas{id: id_2}} = AsciiSketch.create()
      assert {:ok, %Canvas{id: id_3}} = AsciiSketch.create()

      assert %Canvas{id: ^id_1} = AsciiSketch.get(id_1)
      assert %Canvas{id: ^id_2} = AsciiSketch.get(id_2)
      assert %Canvas{id: ^id_3} = AsciiSketch.get(id_3)
    end

    test "returns an error if the id isn't binary" do
      assert {:error, :id_not_binary} = AsciiSketch.get(1)
      assert {:error, :id_not_binary} = AsciiSketch.get(nil)
    end
  end

  describe "draw/3" do
    setup do
      {:ok, %Canvas{id: id}} = AsciiSketch.create(width: 30, height: 10, empty_character: '+')

      {:ok, %{canvas_id: id}}
    end

    test "returns an error if canvas doesn't exist" do
      assert {:error, :canvas_not_found, _meta} =
               AsciiSketch.draw(Ecto.UUID.generate(), Rectangle, %{})
    end

    test "returns an error if change isn't correct", %{canvas_id: id} do
      assert {:error, %Ecto.Changeset{}, _meta} =
               AsciiSketch.draw(id, FloodFill, %{x: -1, y: 3000})

      assert {:error, %Ecto.Changeset{}, _meta} =
               AsciiSketch.draw(id, Rectangle, %{x: -1, y: 3000})
    end

    test "returns operation time in milliseconds", %{canvas_id: id} do
      rectangle = %{x: 3, y: 2, width: 5, height: 3, fill: 'X', outline: '@'}

      assert {:ok, _, %{time_ms: _}} = AsciiSketch.draw(id, Rectangle, rectangle)
    end

    test "updates the canvas in the DB", %{canvas_id: id} do
      rectangle = %{x: 3, y: 2, width: 5, height: 3, fill: 'X', outline: '@'}

      assert {:ok, _, _meta} = AsciiSketch.draw(id, Rectangle, rectangle)

      assert %Canvas{
               lines: [
                 '++++++++++++++++++++++++++++++',
                 '++++++++++++++++++++++++++++++',
                 '+++@@@@@++++++++++++++++++++++',
                 '+++@XXX@++++++++++++++++++++++',
                 '+++@@@@@++++++++++++++++++++++',
                 '++++++++++++++++++++++++++++++',
                 '++++++++++++++++++++++++++++++',
                 '++++++++++++++++++++++++++++++',
                 '++++++++++++++++++++++++++++++',
                 '++++++++++++++++++++++++++++++'
               ]
             } = Canvas |> Repo.get_by!(id: id) |> Canvas.deserialize()
    end
  end

  describe "drawing a rectangle" do
    setup do
      {:ok, %Canvas{id: id}} = AsciiSketch.create(width: 30, height: 10, empty_character: '+')

      {:ok, %{canvas_id: id}}
    end

    test "draws a rectangle on a an empty canvas", %{canvas_id: id} do
      rectangle = %{x: 3, y: 2, width: 5, height: 3, fill: 'X', outline: '@'}

      assert {:ok, updated, _meta} = AsciiSketch.draw(id, Rectangle, rectangle)

      assert %Canvas{
               lines: [
                 '++++++++++++++++++++++++++++++',
                 '++++++++++++++++++++++++++++++',
                 '+++@@@@@++++++++++++++++++++++',
                 '+++@XXX@++++++++++++++++++++++',
                 '+++@@@@@++++++++++++++++++++++',
                 '++++++++++++++++++++++++++++++',
                 '++++++++++++++++++++++++++++++',
                 '++++++++++++++++++++++++++++++',
                 '++++++++++++++++++++++++++++++',
                 '++++++++++++++++++++++++++++++'
               ]
             } = updated
    end

    test "draws a rectangle on a non-empty canvas", %{canvas_id: id_1} do
      rectangle_1 = %{x: 3, y: 2, width: 5, height: 3, fill: 'X', outline: '@'}
      rectangle_2 = %{x: 10, y: 3, width: 14, height: 6, fill: 'O', outline: 'X'}

      assert {:ok, %Canvas{id: id_2} = first_rect, _meta} =
               AsciiSketch.draw(id_1, Rectangle, rectangle_1)

      assert %Canvas{
               lines: [
                 '++++++++++++++++++++++++++++++',
                 '++++++++++++++++++++++++++++++',
                 '+++@@@@@++++++++++++++++++++++',
                 '+++@XXX@++++++++++++++++++++++',
                 '+++@@@@@++++++++++++++++++++++',
                 '++++++++++++++++++++++++++++++',
                 '++++++++++++++++++++++++++++++',
                 '++++++++++++++++++++++++++++++',
                 '++++++++++++++++++++++++++++++',
                 '++++++++++++++++++++++++++++++'
               ]
             } = first_rect

      assert {:ok, second_rect, _meta} = AsciiSketch.draw(id_2, Rectangle, rectangle_2)

      assert %Canvas{
               lines: [
                 '++++++++++++++++++++++++++++++',
                 '++++++++++++++++++++++++++++++',
                 '+++@@@@@++++++++++++++++++++++',
                 '+++@XXX@++XXXXXXXXXXXXXX++++++',
                 '+++@@@@@++XOOOOOOOOOOOOX++++++',
                 '++++++++++XOOOOOOOOOOOOX++++++',
                 '++++++++++XOOOOOOOOOOOOX++++++',
                 '++++++++++XOOOOOOOOOOOOX++++++',
                 '++++++++++XXXXXXXXXXXXXX++++++',
                 '++++++++++++++++++++++++++++++'
               ]
             } = second_rect
    end

    test "draws a rectangles over previous drawings", %{canvas_id: id_1} do
      rectangle_1 = %{x: 0, y: 3, width: 8, height: 4, outline: 'O'}
      rectangle_2 = %{x: 5, y: 5, width: 5, height: 3, fill: 'X'}

      assert {:ok, %Canvas{id: id_2} = first_rect, _meta} =
               AsciiSketch.draw(id_1, Rectangle, rectangle_1)

      assert %Canvas{
               lines: [
                 '++++++++++++++++++++++++++++++',
                 '++++++++++++++++++++++++++++++',
                 '++++++++++++++++++++++++++++++',
                 'OOOOOOOO++++++++++++++++++++++',
                 'O++++++O++++++++++++++++++++++',
                 'O++++++O++++++++++++++++++++++',
                 'OOOOOOOO++++++++++++++++++++++',
                 '++++++++++++++++++++++++++++++',
                 '++++++++++++++++++++++++++++++',
                 '++++++++++++++++++++++++++++++'
               ]
             } = first_rect

      assert {:ok, second_rect, _meta} = AsciiSketch.draw(id_2, Rectangle, rectangle_2)

      assert %Canvas{
               lines: [
                 '++++++++++++++++++++++++++++++',
                 '++++++++++++++++++++++++++++++',
                 '++++++++++++++++++++++++++++++',
                 'OOOOOOOO++++++++++++++++++++++',
                 'O++++++O++++++++++++++++++++++',
                 'O++++XXXXX++++++++++++++++++++',
                 'OOOOOXXXXX++++++++++++++++++++',
                 '+++++XXXXX++++++++++++++++++++',
                 '++++++++++++++++++++++++++++++',
                 '++++++++++++++++++++++++++++++'
               ]
             } = second_rect
    end
  end

  describe "drawing a flood fill" do
    setup do
      {:ok, %Canvas{id: id}} = AsciiSketch.create(width: 21, height: 8, empty_character: '+')

      {:ok, %{canvas_id: id}}
    end

    test "fills an empty canvas", %{canvas_id: id} do
      fill = %{x: 10, y: 5, character: '@'}

      assert {:ok,
              %Canvas{
                lines: [
                  '@@@@@@@@@@@@@@@@@@@@@',
                  '@@@@@@@@@@@@@@@@@@@@@',
                  '@@@@@@@@@@@@@@@@@@@@@',
                  '@@@@@@@@@@@@@@@@@@@@@',
                  '@@@@@@@@@@@@@@@@@@@@@',
                  '@@@@@@@@@@@@@@@@@@@@@',
                  '@@@@@@@@@@@@@@@@@@@@@',
                  '@@@@@@@@@@@@@@@@@@@@@'
                ]
              }, _meta} = AsciiSketch.draw(id, FloodFill, fill)
    end

    test "fills the canvas in all directions from the start point until a different character or the border is reached ",
         %{canvas_id: id} do
      fill_1 = %{x: 0, y: 0, character: '-'}
      fill_2 = %{x: 2, y: 5, character: '*'}

      rect_1 = %{x: 0, y: 3, width: 8, height: 4, outline: 'O'}
      rect_2 = %{x: 5, y: 5, width: 5, height: 3, fill: 'X', outline: 'X'}
      rect_3 = %{x: 14, y: 0, width: 7, height: 6, fill: '.'}

      assert canvas = AsciiSketch.get(id)

      assert {:ok, with_changes, _} =
               [rect_1, rect_2, rect_3]
               |> Enum.reduce({:ok, canvas, %{}}, fn
                 rect, {:ok, canvas, _} -> AsciiSketch.draw(canvas.id, Rectangle, rect)
                 _, err -> err
               end)

      assert [
               '++++++++++++++.......',
               '++++++++++++++.......',
               '++++++++++++++.......',
               'OOOOOOOO++++++.......',
               'O++++++O++++++.......',
               'O++++XXXXX++++.......',
               'OOOOOXXXXX+++++++++++',
               '+++++XXXXX+++++++++++'
             ] = with_changes.lines

      assert {:ok,
              %Canvas{
                lines: [
                  '--------------.......',
                  '--------------.......',
                  '--------------.......',
                  'OOOOOOOO------.......',
                  'O++++++O------.......',
                  'O++++XXXXX----.......',
                  'OOOOOXXXXX-----------',
                  '+++++XXXXX-----------'
                ]
              }, _meta} = AsciiSketch.draw(id, FloodFill, fill_1)

      assert {:ok,
              %Canvas{
                lines: [
                  '--------------.......',
                  '--------------.......',
                  '--------------.......',
                  'OOOOOOOO------.......',
                  'O******O------.......',
                  'O****XXXXX----.......',
                  'OOOOOXXXXX-----------',
                  '+++++XXXXX-----------'
                ]
              }, _meta} = AsciiSketch.draw(id, FloodFill, fill_2)
    end
  end
end
