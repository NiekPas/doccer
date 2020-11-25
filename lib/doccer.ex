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

  @spec get_flag_value([...], String.t()) :: String.t() | nil
  defp get_flag_value(args, flag) do
    index = Enum.find_index(args, fn arg -> arg == flag end)
    if index == nil, do: nil, else: Enum.at(args, index + 1)
  end

  defp get_title(args) do
    get_flag_value(args, "--title")
  end

  defp get_author_name(args) do
    get_flag_value(args, "--author")
  end

  defp get_year(args) do
    get_flag_value(args, "--year")
    # TODO validation
    # raise "Invalid year format for year #{year_value}. Years should be 1-4 digits."
    # unless year_value.match?(/[0-9]{,4}/)
  end

  defp get_journal_name(args) do
    get_flag_value(args, "--journal")
  end

  defp get_folder(args) do
    get_flag_value(args, "--folder")
  end

  @spec get_tags([...]) :: [...] | nil
  defp get_tags(args) do
    case get_flag_value(args, "--tags") do
      nil ->
        nil

      args ->
        args
        |> String.split(",")
        |> Enum.map(fn tag -> String.trim(tag) end)
    end
  end

  defp format_item_as(item) when is_binary(item), do: format_item_as(Jason.decode!(item))

  defp format_item_as(item) do
    """
    @article{#{item["author_name"]} #{item["year"]},
        author    = "#{item["author_name"]},
        title     = "#{item["title"]},
        year      =  #{item["year"]},
        jounal    =  "#{item["journal"]}
    }
    """
  end

  def format_json_entry([]), do: nil

  def format_json_entry(args) do
    title = get_title(args)
    author_name = get_author_name(args)
    year = get_year(args)
    journal_name = get_journal_name(args)
    folder = get_folder(args)
    tags = get_tags(args)

    %{
      title: title,
      author_name: author_name,
      year: year,
      journal_name: journal_name,
      folder: folder,
      tags: tags
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
  @doc """
  Appends `entry` to the library at `path`
  """
  defp write_to_library(entry, path) do
    data_arr = Jason.decode!(File.read!(path))
    data_arr = data_arr ++ [entry]

    File.write(path, Jason.encode!(data_arr))
  end

  defp export_bibtex_library(path) do
    library = Jason.decode!(File.read!(path))

    bibtex_list =
      Enum.map(library, fn entry ->
        format_item_as(entry)
      end)

    Enum.join(bibtex_list, "\n")
  end
end
