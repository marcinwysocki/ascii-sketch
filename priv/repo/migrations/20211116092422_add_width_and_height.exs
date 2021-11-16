defmodule AsciiSketch.Repo.Migrations.AddWidthAndHeight do
  use Ecto.Migration

  def change do
    alter table("canvases") do
      add :width, :integer, null: false
      add :height, :integer, null: false
    end
  end
end
