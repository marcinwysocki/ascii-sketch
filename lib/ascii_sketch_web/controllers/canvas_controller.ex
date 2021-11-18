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

    case AsciiSketch.draw(canvas_id, Canvas.Rectangle, params) do
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

    params
    |> known_keys_to_existsing_atoms(keys)
    |> characters_to_charlist(:empty_character)
  end

  def prepare_rectangle_params(params) do
    keys = ["width", "height", "x", "y", "fill", "outline"]

    params
    |> known_keys_to_existsing_atoms(keys)
    |> characters_to_charlist(:fill)
    |> characters_to_charlist(:outline)
    |> Enum.into(%{})
  end

  defp known_keys_to_existsing_atoms(params, keys) do
    params
    |> Map.keys()
    |> Enum.filter(&(&1 in keys))
    |> Enum.map(&{String.to_existing_atom(&1), Map.get(params, &1)})
  end

  defp characters_to_charlist(params, key) do
    case get_in(params, [key]) do
      char when is_binary(char) -> put_in(params, [key], String.to_charlist(char))
      _ -> params
    end
  end
end
