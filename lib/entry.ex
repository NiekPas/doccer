defmodule Entry do
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

  @spec create_entry(list(any)) :: map | {:error, String.t()}
  def create_entry([]), do: {:error, "Empty fieldset"}

  def create_entry(fields) when is_list(fields) do
    case validate_fields(fields) do
      {:error, error_info} -> {:error, error_info}
      :ok -> fields_to_entry(fields)
    end
  end

  defp validate_fields(fields) do
    if Enum.all?(fields, fn {field_name, value} -> field_name == :id or value == nil end) do
      {:error, "No fields for entry"}
    else
      validate_entry_type(Keyword.get(fields, :type))
    end
  end

  defp validate_entry_type(type) do
    entry_type = type
      |> (fn
        type when is_binary(type) -> String.to_atom(type)
        type when is_atom(type) -> type
      end).()

      # Allow nil types as they default to :article
      if Enum.member?(bibtex_types(), entry_type) or entry_type == nil do
        :ok
      else
        {:error, "Invalid BibTeX type: #{type}"}
      end
  end

  defp fields_to_entry(fields) do
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
