defmodule AsciiSketch.Test.AsciiSketchTest do
  use AsciiSketch.DataCase

  alias AsciiSketch.Canvas
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
end
