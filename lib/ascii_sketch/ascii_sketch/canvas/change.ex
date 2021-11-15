defprotocol AsciiSketch.Canvas.Change do
  @doc """
  Applies the change to given canvas
  """
  def apply(change, canvas)
end
