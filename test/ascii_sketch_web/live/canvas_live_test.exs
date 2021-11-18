defmodule AsciiSketchWeb.CanvasLiveTest do
  use AsciiSketchWeb.ConnCase

  import Phoenix.LiveViewTest
  import AsciiSketch.CanvasesFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  defp create_canvas(_) do
    canvas = canvas_fixture()
    %{canvas: canvas}
  end

  describe "Index" do
    setup [:create_canvas]

    test "lists all canvases", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, Routes.canvas_index_path(conn, :index))

      assert html =~ "Listing Canvases"
    end

    test "saves new canvas", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.canvas_index_path(conn, :index))

      assert index_live |> element("a", "New Canvas") |> render_click() =~
               "New Canvas"

      assert_patch(index_live, Routes.canvas_index_path(conn, :new))

      assert index_live
             |> form("#canvas-form", canvas: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#canvas-form", canvas: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.canvas_index_path(conn, :index))

      assert html =~ "Canvas created successfully"
    end

    test "updates canvas in listing", %{conn: conn, canvas: canvas} do
      {:ok, index_live, _html} = live(conn, Routes.canvas_index_path(conn, :index))

      assert index_live |> element("#canvas-#{canvas.id} a", "Edit") |> render_click() =~
               "Edit Canvas"

      assert_patch(index_live, Routes.canvas_index_path(conn, :edit, canvas))

      assert index_live
             |> form("#canvas-form", canvas: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#canvas-form", canvas: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.canvas_index_path(conn, :index))

      assert html =~ "Canvas updated successfully"
    end

    test "deletes canvas in listing", %{conn: conn, canvas: canvas} do
      {:ok, index_live, _html} = live(conn, Routes.canvas_index_path(conn, :index))

      assert index_live |> element("#canvas-#{canvas.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#canvas-#{canvas.id}")
    end
  end

  describe "Show" do
    setup [:create_canvas]

    test "displays canvas", %{conn: conn, canvas: canvas} do
      {:ok, _show_live, html} = live(conn, Routes.canvas_show_path(conn, :show, canvas))

      assert html =~ "Show Canvas"
    end

    test "updates canvas within modal", %{conn: conn, canvas: canvas} do
      {:ok, show_live, _html} = live(conn, Routes.canvas_show_path(conn, :show, canvas))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Canvas"

      assert_patch(show_live, Routes.canvas_show_path(conn, :edit, canvas))

      assert show_live
             |> form("#canvas-form", canvas: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#canvas-form", canvas: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.canvas_show_path(conn, :show, canvas))

      assert html =~ "Canvas updated successfully"
    end
  end
end
