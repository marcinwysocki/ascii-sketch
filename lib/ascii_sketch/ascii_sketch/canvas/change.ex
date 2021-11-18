defmodule AsciiSketch.Canvas.Change.Validator do
  @callback changeset(params :: %{atom() => term()}, canvas :: Canvas.t()) :: Ecto.Changeset.t()

  def changeset(mod, params, canvas) do
    apply(mod, :changeset, [params, canvas])
  end
end

defprotocol AsciiSketch.Canvas.Change do
  @doc """
  Applies the change to given canvas' lines
  """
  @spec apply(term(), list()) :: list()
  def apply(change, canvas)
end
