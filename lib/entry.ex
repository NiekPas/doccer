defmodule Entry do
  def format_as_bibtex(entry) when is_binary(entry),
    do: format_as_bibtex(Jason.decode!(entry))

  def format_as_bibtex(entry) do
    """
    @#{if entry["type"] == nil, do: "article", else: entry["type"]}{#{entry["author"]} #{
      entry["year"]
    },
        author    = "#{entry["author"]},
        title     = "#{entry["title"]},
        year      =  #{entry["year"]},
        jounal    =  "#{entry["journal"]}
        publisher =  "#{entry["publisher"]}
    }
    """
  end

  @spec create_entry(list(any)) :: list(any) | nil
  def create_entry([]), do: nil

  def create_entry(fields) when is_list(fields) do
    entry_type = Keyword.get(fields, :type)

    unless Enum.member?(bibtex_types(), entry_type) or entry_type == nil do
      raise "Invalid bibtex entry type: #{fields[:type]}.\n\nType should be one of: #{
              bibtex_types() |> Enum.join(", ")
            }.\n\nFor more information, see: https://www.bibtex.com/e/entry-types/\n"
    end

    fields
    |> Enum.reduce(%{"id" => UUID.uuid1()}, fn {field_type, field_value}, acc ->
      Map.merge(acc, %{field_type => field_value})
    end)
  end

  defp bibtex_types,
    do: [
      "article",
      "book",
      "booklet",
      "conference",
      "inbook",
      "incollection",
      "inproceedings",
      "manual",
      "masterthesis",
      "misc",
      "phdthesis",
      "proceedings",
      "techreport",
      "unpublished"
    ]
end
