defmodule Field do
  @spec get_from_args(maybe_improper_list) :: list(any)
  def get_from_args(args) when is_list(args) do
    args
    |> Enum.chunk_every(2, 1)
    |> Enum.reduce([], fn
      ["--" <> flag, val], acc ->
        acc ++ [{String.to_atom(flag), val}]

      _, acc ->
        acc
    end)
  end
end
