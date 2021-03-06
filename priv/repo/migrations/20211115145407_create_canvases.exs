defmodule AsciiSketch.Repo.Migrations.CreateCanvases do
  use Ecto.Migration

  def change do
    create table(:canvases, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :canvas, :text, null: false

      timestamps()
    end
  end
end
