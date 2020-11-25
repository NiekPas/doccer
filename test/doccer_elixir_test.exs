defmodule DoccerTest do
  use ExUnit.Case
  # doctest Doccer

  test "adds an entry to the library" do
    args = ["add", "--author", "Niek"]
    assert Doccer.main args == :world
  end
end
