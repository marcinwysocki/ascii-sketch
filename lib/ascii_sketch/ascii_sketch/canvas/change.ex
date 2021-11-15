defprotocol AsciiSketch.Canvas.Change do
  @doc """
  Applies the change to given canvas' lines
  """
  @spec apply(term(), list()) :: list()
  def apply(change, canvas)
end
