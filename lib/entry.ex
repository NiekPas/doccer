defmodule Entry do
  # TODO make this a struct
  def format_as_bibtex(entry) when is_binary(entry),
    do: format_as_bibtex(Jason.decode!(entry))

  def format_as_bibtex(entry) do
    bibtex_base = """
    @#{if entry[:type] == nil, do: "article", else: entry[:type]}{#{
      String.replace(entry[:author], " ", "")
    }#{entry[:year]},
    """

    Enum.reduce(entry, bibtex_base, fn
      {_k, nil}, acc -> acc
      # Id nor type should not be included in bibtex output
      {:id, _v}, acc -> acc
      {:type, _v}, acc -> acc
      # Years should not be enclosed in quotes
      {k, v}, acc when is_binary(v) -> acc <>   "    #{k} = \"#{v}\",\n"
      {k, v}, acc when is_integer(v) -> acc <>  "    #{k} = #{v},\n"
    end)
    |> Kernel.<>("}\n")
  end

  @spec create_entry(list(any)) :: list(any) | nil
  def create_entry([]), do: nil

  def create_entry(fields) when is_list(fields) do
    entry_type = Keyword.get(fields, :type)
    |> (fn
      type when is_binary(type) -> String.to_atom(type)
      type when is_atom(type) -> type
    end).()

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
      :article,
      :book,
      :booklet,
      :conference,
      :inbook,
      :incollection,
      :inproceedings,
      :manual,
      :masterthesis,
      :misc,
      :phdthesis,
      :proceedings,
      :techreport,
      :unpublished
    ]
end
