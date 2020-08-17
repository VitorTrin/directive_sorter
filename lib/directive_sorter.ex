defmodule DirectiveSorter do
  @moduledoc """
  Documentation for DirectiveSorter.
  """

  @spec format_string!(String.t()) :: String.t()
  def format_string!(string) when is_binary(string) do
    string
    |> split_string_into_lines()
    |> remove_blank_lines_between_blocks()
    |> sort_lines()
    |> rebuild_string()
  end

  def split_string_into_lines(string) when is_binary(string) do
    lines =
      string
      |> String.split(~r<\n>)
      |> Enum.with_index()

    alias_lines = alias_lines(lines)

    {lines, alias_lines}
  end

  def remove_blank_lines_between_blocks({lines, alias_lines}) do
    alias_lines_numbers = Map.keys(alias_lines)

    shifted_alias_line_numbers = alias_lines_numbers |> Enum.drop(1) |> Enum.concat([0])

    blank_lines_around_blocks =
      alias_lines_numbers
      |> Enum.zip(shifted_alias_line_numbers)
      |> Enum.flat_map(fn {alias_line, next_alias_line} ->
        Enum.flat_map(lines, fn {line, number} ->
          with true <- number > alias_line,
               true <- number < next_alias_line,
               "" <- String.trim(line) do
            [number]
          else
            _ ->
              []
          end
        end)
      end)

    lines =
      lines
      |> Enum.reject(fn {_current_line, line_number} ->
        line_number in blank_lines_around_blocks
      end)
      |> Enum.map(fn {current_line, _line_number} -> current_line end)
      |> Enum.with_index()

    {lines, alias_lines(lines)}
  end

  def sort_lines({lines, alias_lines}) do
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
    |> Enum.with_index()
  end

  def rebuild_string(lines) do
    lines
    |> Enum.map(fn {line, _number} -> line end)
    |> Enum.join("\n")
  end

  defp alias_lines(lines) do
    lines
    |> Enum.flat_map(fn {line, number} ->
      if line |> String.trim() |> String.starts_with?("alias") do
        [{number, line}]
      else
        []
      end
    end)
    |> Enum.into(%{})
  end
end
