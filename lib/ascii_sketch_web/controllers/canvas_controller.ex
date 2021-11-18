defmodule AsciiSketchWeb.CanvasController do
  use AsciiSketchWeb, :controller

  alias AsciiSketch.Canvas

  def create(conn, params) do
    case params |> prepare_create_params() |> AsciiSketch.create() do
      {:ok, canvas} ->
        conn
        |> put_status(201)
        |> json(%{id: canvas.id})

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

  def draw(conn, params) do
    with {canvas_id, params} <- Map.pop(params, "id"),
         {change, params} <- Map.pop(params, "change"),
         {:ok, mod, params} <- prepare_change(change, params) do
      case AsciiSketch.draw(canvas_id, mod, params) do
        {:ok, _canvas, meta} ->
          conn
          |> put_status(200)
          |> json(%{meta: meta})

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
    else
      {:error, msg} ->
        conn
        |> put_status(400)
        |> json(%{errors: %{details: msg}})
    end
  end

  defp prepare_create_params(params) do
    keys = ["width", "height", "empty_character"]

    params
    |> known_keys_to_existsing_atoms(keys)
    |> characters_to_charlist(:empty_character)
  end

  defp prepare_change("rectangle", params) do
    {:ok, Canvas.Rectangle, prepare_rectangle_params(params)}
  end

  defp prepare_change("flood_fill", params) do
    {:ok, Canvas.FloodFill, prepare_fill_params(params)}
  end

  defp prepare_change(_, _), do: {:error, "unsupported change"}

  defp prepare_rectangle_params(params) do
    keys = ["width", "height", "x", "y", "fill", "outline"]

    params
    |> known_keys_to_existsing_atoms(keys)
    |> characters_to_charlist(:fill)
    |> characters_to_charlist(:outline)
    |> Enum.into(%{})
  end

  defp prepare_fill_params(params) do
    keys = ["x", "y", "character"]

    params
    |> known_keys_to_existsing_atoms(keys)
    |> characters_to_charlist(:character)
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
