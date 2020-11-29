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

        # Ensure there is at least one field given
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
