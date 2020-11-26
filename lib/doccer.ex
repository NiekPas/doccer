defmodule Doccer do
  def main([]), do: IO.puts("Please provide a command-line argument")

  def main(args) do
    library_path = "#{System.fetch_env!("HOME")}/.doccer/doccer-library.json"

    unless File.exists?(library_path) do
      init_library(library_path)
    end

    case arg_value = Enum.at(args, 0) do
      "add" ->
        json_entry = format_json_entry(args -- [arg_value])

        if json_entry == nil do
          raise "Please provide at least one field for this entry."
        else
          write_to_library(json_entry, library_path)
        end

      "export" ->
        bibtex = export_bibtex_library(library_path)

        if Enum.member?(args, "--copy") do
          copy_to_clipboard(bibtex)
        else
          IO.puts(bibtex)
        end

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
    @#{if entry["type"] == nil, do: "article", else: entry["type"]}{#{entry["author_name"]} #{
      entry["year"]
    },
        author    = "#{entry["author_name"]},
        title     = "#{entry["title"]},
        year      =  #{entry["year"]},
        jounal    =  "#{entry["journal"]}
        publisher =  "#{entry["publisher"]}
    }
    """
  end

  def format_json_entry([]), do: nil

  def format_json_entry(args) do
    title = get_field(:title, args)
    author = get_field(:author, args)
    year = get_field(:year, args)
    journal = get_field(:journal, args)
    folder = get_field(:folder, args)
    tags = get_field(:tags, args)
    publisher = get_field(:publisher, args)
    type = get_field(:type, args)

    unless Enum.member?(bibtex_types(), type) or type == nil do
      raise "Invalid bibtex entry type: #{type}.\n\nType should be one of: #{
              bibtex_types() |> Enum.join(", ")
            }.\n\nFor more information, see: https://www.bibtex.com/e/entry-types/\n"
    end

    %{
      title: title,
      author_name: author,
      year: year,
      journal_name: journal,
      folder: folder,
      tags: tags,
      publisher: publisher,
      type: type,
      id: UUID.uuid1()
    }
    |> Jason.encode!()
  end

  defp init_library(path) do
    library_directory = Path.dirname(path)
    unless File.dir?(library_directory), do: File.mkdir(library_directory)
    IO.puts("No library file found at #{path}, creating.")
    File.write(path, "[]\n")
  end

  @spec write_to_library(String.t(), String.t()) :: :ok | {:error, atom}
  defp write_to_library(entry, path) do
    data_arr = Jason.decode!(File.read!(path)) ++ [entry]

    File.write(path, Jason.encode!(data_arr))
  end

  defp export_bibtex_library(path) do
    library = Jason.decode!(File.read!(path))

    bibtex_list =
      Enum.map(library, fn entry ->
        format_bibtex_entry(entry)
      end)

    Enum.join(bibtex_list, "\n")
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
