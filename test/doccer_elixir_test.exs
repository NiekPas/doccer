defmodule DoccerTest do
  use ExUnit.Case
  doctest Doccer

  test "greets the world" do
    assert Doccer.hello() == :world
  end
end
