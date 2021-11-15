defmodule AsciiSketch.Test.Support.VerticalLine do
  @moduledoc """
  A simple implementation of a change for testing purposes
  """

  defstruct [:x, :y, :length, :character]

  defimpl AsciiSketch.Canvas.Change do
    def apply(
          %{x: x, y: y, length: length, character: character},
          lines
        ) do
      {head, modified} = Enum.split(lines, y)
      line_length = min(length, length(modified))
      {modified, tail} = Enum.split(modified, line_length)

      line =
        for index <- 0..(length(modified) - 1) do
          modified |> Enum.fetch!(index) |> List.replace_at(x, character) |> List.to_charlist()
        end

      head ++ line ++ tail
    end
  end
end
