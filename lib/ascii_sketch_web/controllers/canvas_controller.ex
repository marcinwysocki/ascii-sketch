defmodule AsciiSketchWeb.CanvasController do
  use AsciiSketchWeb, :controller

  alias AsciiSketch.Canvas

  def create(conn, params) do
    case params |> prepare_create_params() |> AsciiSketch.create() do
      {:ok, canvas} ->
        conn
        |> put_status(201)
        |> json(canvas)

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(400)
        |> render("400.json", %{changeset: changeset})

      {:error, error} ->
        error
        |> put_status(500)
        |> json(%{errors: %{detail: "#{inspect(error)}"}})
    end
  end

  def get(conn, %{"id" => id}) do
    case AsciiSketch.get(id) do
      %Canvas{} = canvas ->
        conn
        |> put_status(200)
        |> json(canvas)

      _ ->
        conn
        |> put_status(404)
        |> render("404.json")
    end
  end

  def rectangle(conn, params) do
    {canvas_id, params} = Map.pop(params, "id")
    params = prepare_rectangle_params(params)

    case AsciiSketch.draw_rectangle(canvas_id, params) do
      {:ok, canvas, meta} ->
        conn
        |> put_status(200)
        |> json(%{canvas: canvas, meta: meta})

      {:error, %Ecto.Changeset{} = changeset, _} ->
        conn
        |> put_status(400)
        |> render("400.json", %{changeset: changeset})

      {:error, :canvas_not_found, _} ->
        conn
        |> put_status(404)
        |> render("404.json")

      {:error, error, _} ->
        conn
        |> put_status(500)
        |> json(%{errors: %{detail: "#{inspect(error)}"}})
    end
  end

  defp prepare_create_params(params) do
    keys = ["width", "height", "empty_character"]

    known_keys_to_existsing_atoms(params, keys)
  end

  def prepare_rectangle_params(params) do
    keys = ["width", "height", "x", "y", "fill", "outline"]

    params
    |> known_keys_to_existsing_atoms(keys)
    |> Enum.into(%{})
  end

  defp known_keys_to_existsing_atoms(params, keys) do
    params
    |> Map.keys()
    |> Enum.filter(&(&1 in keys))
    |> Enum.map(&{String.to_existing_atom(&1), Map.get(params, &1)})
  end
end
