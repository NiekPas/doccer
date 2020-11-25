defmodule Doccer do
  @moduledoc """
  Documentation for `Doccer`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Doccer.hello()
      :world

  """

  def main([]), do: IO.puts("Please provide a command-line argument")

  def main(args) do
    library_path = "/Users/niekvandepas/.doccer/doccer-library.json"

    unless File.exists?(library_path) do
      IO.puts("gotta innit")
      init_library()
    end

    case arg_value = Enum.at(args, 0) do
      "add" ->
        json_entry = format_json_entry(args -- [arg_value])
        write_to_library(json_entry, library_path)

      "export" ->
        IO.puts("TODO")

      _ ->
        IO.puts("Invalid command line argument")
    end
  end

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
    year_value = get_flag_value(args, "--year")
    # TODO validation
    # raise "Invalid year format for year #{year_value}. Years should be 1-4 digits." unless year_value.match?(/[0-9]{,4}/)
  end

  defp get_journal_name(args) do
    get_flag_value(args, "--journal")
  end

  defp get_tags(args) do
    get_flag_value(args, "--tags")
    |> String.split(",")
    |> Enum.map(fn tag -> String.trim(tag) end)
  end

  defp format_item_as(item) do
    """
    @article{#{item[:author_name]} #{item[:year]},
        author    = "#{item[:author_name]}",
        title     = "#{item[:title]}",
        year      =  #{item[:year]},
        jounal    =  "#{item[:year]}"
    }
    """
  end

  def format_json_entry(args) do
    title = get_title(args)
    author_name = get_author_name(args)
    year = get_year(args)
    journal_name = get_journal_name(args)
    # folder = get_folder(args)
    tags = get_tags(args)

    %{
      title: title,
      author_name: author_name,
      year: year,
      journal_name: journal_name,
      # folder: folder,
      tags: tags
    }
    |> Jason.encode!()
  end

  defp init_library do
    IO.puts("init lib")
    File.open("~/.doccer/doccer-library.json")
  end

  @doc """
  Appends `entry` to the library at `path`
  """
  def write_to_library(entry, path) do
    data_arr = Jason.decode!(File.read!(path))
    data_arr = data_arr ++ entry

    File.open(path, ["append"], fn file ->
      IO.write(file, Jason.encode!(data_arr))
      :ok
    end)
  end
end
