defmodule Doccer do
  def main([]), do: IO.puts("Please provide a command-line argument")

  def main(args) do
    library_path = "#{System.fetch_env!("HOME")}/.doccer/doccer-library.json"

    unless File.exists?(library_path) do
      Library.init(library_path)
    end

    case Enum.at(args, 0) do
      "add" ->
        fields =
          Field.get_from_args(args)
          |> Enum.filter(fn {flag, _value} ->
            Enum.member?(fields(), flag)
          end)

        json_entry = Entry.create_entry(fields)
        Library.append(json_entry, library_path)

      "export" ->
        bibtex = Library.export_as_bibtex(library_path)

        if Enum.member?(args, "--copy") do
          Library.copy_to_clipboard(bibtex)
        else
          IO.puts(bibtex)
        end

      "remove" ->
        library = Jason.decode!(File.read!(library_path))
        fields = Field.get_from_args(args)

        # Remove entries with the matching fields (case-insensitive) from the map.
        updated_library =
          Enum.reject(library, fn entry ->
            Enum.all?(fields, fn {field_name, field_value} ->
              String.downcase(Map.fetch!(entry, Atom.to_string(field_name))) ==
                String.downcase(field_value)
            end)
          end)

        Library.write_content_to_file(Jason.encode!(updated_library), library_path)

      "show" ->
        # TODO refactor this into function after completion
        # (TODO) For each column, we get the longest cell length by running through the entries
        # and checking their String.length/1, then set each column to its max length
        # by calculating padding around the headers and entries
        library = Library.export(library_path)

        # Set the minimum column with to 5 characters for aesthetic purposes.
        minimum_column_width = 5

        # def calculate_column_widths
        columns =
          fields()
          |> Enum.reduce(%{}, fn field_type, acc ->
            # For each column, we calculate its width by
            # retrieving the string length of its longest entry.

            column_width =
              library
              |> Enum.reduce(minimum_column_width, fn entry, acc ->
                case Map.fetch(entry, field_type) do
                  :error ->
                    max(acc, minimum_column_width)

                  {:ok, nil} ->
                    max(acc, minimum_column_width)

                  {:ok, field_value} when is_binary(field_value) ->
                    max(acc, String.length(field_value))

                  {:ok, year} when is_integer(year) ->
                    max(acc, year |> Integer.to_string() |> String.length())
                end
              end)

            Map.merge(acc, %{field_type => column_width})
          end)

        IO.puts("*****************************************")
        IO.inspect(columns)
        IO.puts("*****************************************")

        """
        +--------+------+-------+---------+--------+------+
        | Author | Year | Title | Journal | Folder | Tags |
        +--------+------+-------+---------+--------+------+
        |        |      |       |         |        |      |
        +--------+------+-------+---------+--------+------+
        |        |      |       |         |        |      |
        +--------+------+-------+---------+--------+------+
        |        |      |       |         |        |      |
        +--------+------+-------+---------+--------+------+
        """
        |> IO.puts()

        library
        |> Enum.each(fn entry ->
          IO.inspect(entry)
          # TODO pretty table
        end)

        resp = IO.gets("Press <Enter> to close")

      _ ->
        IO.puts("Invalid command line argument")
    end
  end

  defp fields,
    do: [
      :title,
      :author,
      :year,
      :journal,
      :folder,
      :publisher,
      :type,
      :tags
    ]
end
