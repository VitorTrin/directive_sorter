defmodule AliasSorter do
  @moduledoc """
  Documentation for AliasSorter.
  """
  @spec sort_string!(String.t()) :: String.t()
  def sort_string!(string) when is_binary(string) do
    lines =
      string
      |> String.split(~r<\n>)
      |> Enum.with_index()

    alias_lines =
      lines
      |> Enum.flat_map(fn {line, number} ->
        if line |> String.trim() |> String.starts_with?("alias") do
          [{number, line}]
        else
          []
        end
      end)
      |> Enum.into(%{})

    alias_lines_numbers = Map.keys(alias_lines)

    sorted_alias =
      Enum.sort(alias_lines, fn {_number1, line1}, {_number2, line2} ->
        String.trim(line1) <= String.trim(line2)
      end)

    lines
    |> Enum.reduce({0, []}, fn {current_line, line_number},
                               {sorted_alias_tracker, lines_so_far} ->
      if line_number in alias_lines_numbers do
        {sorted_alias_tracker + 1,
         [sorted_alias |> Enum.at(sorted_alias_tracker) |> elem(1) | lines_so_far]}
      else
        {sorted_alias_tracker, [current_line | lines_so_far]}
      end
    end)
    |> elem(1)
    |> Enum.reverse()
    |> Enum.join("\n")
  end
end
