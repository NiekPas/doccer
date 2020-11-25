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
    unless File.exists? "~/.doccer/doccer-library.json" do
      IO.puts "gotta innit"
      init_library()
    end

    case args[0] do
      "add" ->
        add_entry(args -- [args[0]])
      "export" -> IO.puts "TODO"
      _ -> IO.puts "Invalid command line argument"
    end
  end

  defp get_arg_value(args, flag) do
    index = Enum.index(args, fn arg -> arg == flag end)
    if index == nil, do: nil, else: args[index + 1]
  end

  defp get_title(args) do
      get_arg_value(args, "--title")
  end

  defp get_author_name(args) do
    get_arg_value(args, "--author")
  end

  defp get_year(args) do
      year_value = get_arg_value(args, "--year")
      # TODO validation
      # raise "Invalid year format for year #{year_value}. Years should be 1-4 digits." unless year_value.match?(/[0-9]{,4}/)
  end

  defp get_journal_name(args) do
      get_arg_value(args, "--journal")
  end

  defp get_tags(args) do
    get_arg_value(args, "--tags")
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

  defp add_entry(args) do
      filename = args[0]
      unless File.file?(filename), do: raise "#{filename} is not a file"

      title = get_title(args)
      author_name = get_author_name(args)
      year = get_year(args)
      journal_name = get_journal_name(args)

      item = %{
          title: title,
          author_name: author_name,
          year: year,
          journal_name: journal_name
      }

      IO.puts format_item_as(item)
  end

  defp init_library do
      IO.puts "init lib"
      File.open("~/.doccer/doccer-library.json")
  end
end
