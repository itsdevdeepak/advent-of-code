alias AdventOfCode.Day4, as: Main

defmodule AdventOfCode.Day4 do
  @moduledoc """
  Advent of Code 2024: Day 4 - Ceres Search

  https://adventofcode.com/2024/day/4
  """
  @input_file "input.txt"

  @type coordinate :: [row: integer, column: integer]
  @type puzzle :: [[char()]]

  @spec part_one() :: integer()
  def part_one() do
    puzzle = @input_file |> parse_input()
    coordinates = extract_coordinates(:part1, puzzle)

    total_xmas_appearances(:part1, {puzzle, coordinates})
  end

  @spec part_two() :: integer()
  def part_two() do
    puzzle = @input_file |> parse_input()
    coordinates = extract_coordinates(:part2, puzzle)

    total_xmas_appearances(:part2, {puzzle, coordinates})
  end

  @spec total_xmas_appearances(:part1 | :part2, {puzzle(), [coordinate()]}) :: integer()
  defp total_xmas_appearances(part, {puzzle, coordinates}) do
    coordinates
    |> Enum.map(fn coordinate ->
      count_xmas(part, {puzzle, coordinate})
    end)
    |> Enum.sum()
  end

  @spec count_xmas(:part1 | :part2, {puzzle(), coordinate()}) :: integer()

  defp count_xmas(:part1, {puzzle, coordinate}) do
    directions = [
      {1, 0},
      {-1, 0},
      {0, 1},
      {0, -1},
      {1, 1},
      {-1, 1},
      {-1, -1},
      {1, -1}
    ]

    for {dx, dy} <- directions do
      Enum.map(0..3, fn x ->
        next_row = coordinate[:row] + dy * x
        next_column = coordinate[:column] + dx * x
        get_cell(puzzle, next_row, next_column)
      end)
      |> List.to_tuple()
    end
    |> Enum.count(fn x -> x == {"X", "M", "A", "S"} end)
  end

  defp count_xmas(:part2, {puzzle, coordinate}) do
    directions = [
      {1, 1},
      {1, -1},
      {-1, 1},
      {-1, -1}
    ]

    target =
      directions
      |> Enum.map(fn {dx, dy} ->
        next_row = coordinate[:row] + dy
        next_column = coordinate[:column] + dx

        get_cell(puzzle, next_row, next_column)
      end)

    case target do
      ["M", "M", "S", "S"] -> 1
      ["M", "S", "M", "S"] -> 1
      ["S", "S", "M", "M"] -> 1
      ["S", "M", "S", "M"] -> 1
      _ -> 0
    end
  end

  @spec extract_coordinates(:part1 | :part2, puzzle()) :: [coordinate()]

  defp extract_coordinates(:part1, puzzle) do
    extract_coordinates(puzzle, "X")
  end

  defp extract_coordinates(:part2, puzzle) do
    extract_coordinates(puzzle, "A")
  end

  @spec extract_coordinates(puzzle :: puzzle(), target :: char()) :: [coordinate()]
  defp extract_coordinates(puzzle, target) do
    for {row, row_index} <- Enum.with_index(puzzle),
        {column, column_index} <- Enum.with_index(row),
        column == target,
        do: [row: row_index, column: column_index]
  end

  @spec get_cell(puzzle :: puzzle(), integer(), integer()) :: char()

  defp get_cell(_, row, column) when row < 0 or column < 0 do
    nil
  end

  defp get_cell(puzzle, row, column) do
    Enum.at(puzzle, row, []) |> Enum.at(column, nil)
  end

  @spec parse_input(Path.t()) :: puzzle()
  defp parse_input(file_path) do
    file_path
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.graphemes/1)
    |> Enum.to_list()
  end
end

Main.part_one() |> IO.inspect(label: "Day 4 Part 1 Solution:")
Main.part_two() |> IO.inspect(label: "Day 4 Part 2 Solution:")
