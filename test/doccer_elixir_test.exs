defmodule DoccerTest do
  use ExUnit.Case
  # doctest Doccer

  test "adds an entry to the library" do
    args = ["add", "--author", "Niek"]
    assert Doccer.main(args) == :ok
  end

  test "does not add an entry without fields to the library" do
    args = ["add"]
    assert catch_error(Doccer.main(args))
  end

  test "adds an entry with a folder to the library" do
    args = ["add", "--author", "Niek", "--folder", "SomeFolder"]
    assert Doccer.main(args) == :ok
  end

  test "exports the library" do
    args = ["export"]
    assert Doccer.main(args) == :ok
  end

  test "exports the library with coping" do
    args = ["export", "--copy"]
    assert Doccer.main(args) == :ok
  end
end
