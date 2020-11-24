defmodule DoccerElixirTest do
  use ExUnit.Case
  doctest DoccerElixir

  test "greets the world" do
    assert DoccerElixir.hello() == :world
  end
end
