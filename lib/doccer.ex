defmodule Doccer do
  def main([]), do: IO.puts("Please provide a command-line argument")

  def main(args) do
    library_path = "#{System.fetch_env!("HOME")}/.doccer/doccer-library.json"

    unless File.exists?(library_path) do
      init_library(library_path)
    end

    case command = Enum.at(args, 0) do
      "add" ->
        fields = get_fields_from_args(args -- [command])

        if Enum.all?(fields, fn {field_name, value} -> field_name == :id or value == nil end) do
          raise "Please provide at least one field for this entry."
        end

        json_entry = format_json_entry(fields)

        write_to_library(json_entry, library_path)

      "export" ->
        bibtex = export_bibtex_library(library_path)

        if Enum.member?(args, "--copy") do
          copy_to_clipboard(bibtex)
        else
          IO.puts(bibtex)
        end

      "remove" ->
        library = Jason.decode!(File.read!(library_path))

        fields =
          get_fields_from_args(args -- [command])
          |> Enum.reject(fn {field_name, field_value} -> field_value == nil end)

        updated_library =
          Enum.reject(library, fn entry ->
            Enum.all?(fields, fn {field_name, field_value} ->
              String.downcase(Map.fetch!(entry, Atom.to_string(field_name))) ==
                String.downcase(field_value)
            end)
          end)

      write_content_to_file(Jason.encode!(updated_library), library_path)
      _ ->
        IO.puts("Invalid command line argument")
    end
  end

  defp copy_to_clipboard(value) when is_binary(value) do
    path = System.find_executable("pbcopy")
    port = Port.open({:spawn_executable, path}, [])
    send(port, {self(), {:command, value}})
    :ok
  end

  @spec get_fields_from_args(list(), list()) :: map()
  defp get_fields_from_args(
         args,
         fields \\ [
           :title,
           :author,
           :year,
           :journal,
           :folder,
           :publisher,
           :type,
           :tags
         ]
       )
       when is_list(fields) do
    fields
    |> Enum.map(fn field ->
      %{field => get_field(field, args)}
    end)
    |> Enum.reduce(fn val, acc ->
      Map.merge(acc, val)
    end)
  end

  defp get_field(:title, args), do: get_flag_value(args, "--title")
  defp get_field(:author, args), do: get_flag_value(args, "--author")
  defp get_field(:year, args), do: get_flag_value(args, "--year")
  defp get_field(:journal, args), do: get_flag_value(args, "--journal")
  defp get_field(:folder, args), do: get_flag_value(args, "--folder")
  defp get_field(:publisher, args), do: get_flag_value(args, "--publisher")
  defp get_field(:type, args), do: get_flag_value(args, "--type")

  defp get_field(:tags, args) do
    case get_flag_value(args, "--tags") do
      nil ->
        nil

      # Transform comma-seperated tags to list
      args ->
        args
        |> String.split(",")
        |> Enum.map(fn tag -> String.trim(tag) end)
    end
  end

  @spec get_flag_value([...], String.t()) :: String.t() | nil
  defp get_flag_value(args, flag) do
    index = Enum.find_index(args, fn arg -> arg == flag end)
    if index == nil, do: nil, else: Enum.at(args, index + 1)
  end

  defp format_bibtex_entry(entry) when is_binary(entry),
    do: format_bibtex_entry(Jason.decode!(entry))

  defp format_bibtex_entry(entry) do
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

  def format_json_entry([]), do: nil

  def format_json_entry(fields) do
    unless Enum.member?(bibtex_types(), fields[:type]) or fields[:type] == nil do
      raise "Invalid bibtex entry type: #{fields[:type]}.\n\nType should be one of: #{
              bibtex_types() |> Enum.join(", ")
            }.\n\nFor more information, see: https://www.bibtex.com/e/entry-types/\n"
    end

    %{
      title: fields[:title],
      author: fields[:author],
      year: fields[:year],
      journal_name: fields[:journal],
      folder: fields[:folder],
      tags: fields[:tags],
      publisher: fields[:publisher],
      type: fields[:type],
      id: UUID.uuid1()
    }
  end

  defp init_library(path) do
    library_directory = Path.dirname(path)
    unless File.dir?(library_directory), do: File.mkdir(library_directory)
    IO.puts("No library file found at #{path}, creating.")
    write_content_to_file("[]\n", path)
  end

  defp write_to_library(entry, path) do
    library = Jason.decode!(File.read!(path)) ++ [entry]

    write_content_to_file(Jason.encode!(library), path)
  end

  defp export_bibtex_library(path) do
    library = Jason.decode!(File.read!(path))

    bibtex_list =
      Enum.map(library, fn entry ->
        format_bibtex_entry(entry)
      end)

    Enum.join(bibtex_list, "\n")
  end

  defp write_content_to_file(content, path) when is_binary(content) and is_binary(path) do
    File.write(path, content)
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
