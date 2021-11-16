defmodule AsciiSketch.Test.Support.BrokenChange do
  @moduledoc """
  A broken implementation of a change for testing purposes
  """
  defstruct [:x, :y, :character]

  defimpl AsciiSketch.Canvas.Change do
    def apply(_, _), do: "hello world"
  end
end
