defmodule Library do
  def init(path) do
    library_directory = Path.dirname(path)
    unless File.dir?(library_directory), do: File.mkdir(library_directory)
    IO.puts("No library file found at #{path}, creating.")
    write_content_to_file("[]\n", path)
  end

  @spec append(any, binary) :: :ok | {:error, atom}
  @doc """
  Appends `entry` to the library at `path`.
  """
  def append(entry, path) do
    library = Jason.decode!(File.read!(path)) ++ [entry]

    write_content_to_file(Jason.encode!(library), path)
  end

  def export_as_bibtex(path) do
    library = Jason.decode!(File.read!(path))

    bibtex_list =
      Enum.map(library, fn entry ->
        Entry.format_as_bibtex(entry)
      end)

    Enum.join(bibtex_list, "\n")
  end

  def write_content_to_file(content, path) when is_binary(content) and is_binary(path) do
    File.write(path, content)
  end

  def copy_to_clipboard(value) when is_binary(value) do
    path = System.find_executable("pbcopy")
    port = Port.open({:spawn_executable, path}, [])
    send(port, {self(), {:command, value}})
    :ok
  end
end
