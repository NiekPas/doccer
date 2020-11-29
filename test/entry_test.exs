defmodule EntryTest do
  use ExUnit.Case

  test "Formats an entry as bibtex" do
    entry = %{
      id: "7d4131fa-3264-11eb-8f16-acbc32cbdb21",
      author: "John Doe",
      year: 1984,
      type: "article",
      title: "Article title"
    }

    expected = """
    @article{JohnDoe1984,
        author = "John Doe",
        title = "Article title",
        year = 1984,
    }
    """

    assert Entry.format_as_bibtex(entry) == expected
  end

  test "creates an entry from a fieldset" do
    fields = [author: "John Doe", year: 1984, title: "Article title", type: "article"]
    expected = %{:author => "John Doe", :title => "Article title", :type => "article", :year => 1984, "id" => "ecd54e92-326a-11eb-9657-acbc32cbdb21"}
    entry = Entry.create_entry(fields)

    assert Enum.all?(fields, fn
      {:author, v} -> v == "John Doe"
      {:year, v} -> v == 1984
      {:title, v} -> v == "Article title"
      {:type, v} -> v == "article"
    end)
  end

  test "returns nil when asked to format an empty array as JSON" do
    assert Entry.create_entry([]) == nil
  end
end
