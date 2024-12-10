alias AdventOfCode.Day10.HoofIt, as: Main

defmodule AdventOfCode.Day10.HoofIt do
  @moduledoc """
  Advent of Code 2016 Day 10

  https://adventofcode.com/2016/day/10
  """
  @input_file "input.txt"
  @type topographic_map :: list(list(integer))
  @type position :: {integer, integer}

  @spec part_one() :: integer
  def part_one do
    map =
      @input_file
      |> parse_file()

    trail_heads =
      map
      |> trail_heads()

    trail_heads
    |> Enum.map(&hiking_trails(map, &1))
    |> Enum.reduce(0, fn x, acc ->
      unique_count = x |> Enum.uniq() |> length()
      acc + unique_count
    end)
  end

  @spec part_two() :: integer
  def part_two do
    map =
      @input_file
      |> parse_file()

    trail_heads =
      map
      |> trail_heads()

    trail_heads
    |> Enum.map(&hiking_trails(map, &1))
    |> Enum.reduce(0, fn x, acc ->
      count = x |> length()
      acc + count
    end)
  end

  @spec hiking_trails(topographic_map(), position()) :: list(position())
  defp hiking_trails(map, {row_idx, col_idx}) do
    current = Enum.at(map, row_idx, []) |> Enum.at(col_idx)
    hiking_trails(map, current, {row_idx, col_idx})
  end

  @spec hiking_trails(topographic_map(), integer, position()) :: list(position())
  defp hiking_trails(_map, current, pos) when current == 9 do
    pos
  end

  @spec hiking_trails(topographic_map(), integer, position()) :: list(position())
  defp hiking_trails(map, current, {row_idx, col_idx}) do
    directions = [
      {0, -1},
      {0, 1},
      {-1, 0},
      {1, 0}
    ]

    row_bound = length(map) - 1
    col_bound = length(Enum.at(map, 0)) - 1

    directions
    |> Enum.map(fn direction ->
      next_position(map, current, {row_idx, col_idx}, direction, {row_bound, col_bound})
    end)
    |> List.flatten()
    |> Enum.reject(&is_nil/1)
  end

  @spec next_position(
          topographic_map(),
          integer,
          position(),
          {integer, integer},
          {integer, integer}
        ) :: position() | nil
  defp next_position(
         map,
         current,
         {row_idx, col_idx},
         {row_diff, col_diff},
         {row_bound, col_bound}
       ) do
    new_row_idx = row_idx + row_diff
    new_col_idx = col_idx + col_diff

    if is_valid_position(new_row_idx, new_col_idx, row_bound, col_bound) do
      next = map |> Enum.at(new_row_idx, []) |> Enum.at(new_col_idx, nil)

      if current + 1 == next do
        hiking_trails(map, next, {new_row_idx, new_col_idx})
      else
        nil
      end
    else
      nil
    end
  end

  @spec trail_heads(topographic_map()) :: list(position())
  defp trail_heads(map) do
    for {row, row_index} <- Enum.with_index(map),
        {cell, col_index} <- Enum.with_index(row),
        cell == 0,
        do: {row_index, col_index}
  end

  @spec is_valid_position(integer, integer, integer, integer) :: boolean
  defp is_valid_position(row_idx, col_idx, row_bound, col_bound) do
    row_idx >= 0 and col_idx >= 0 and row_idx <= row_bound and col_idx <= col_bound
  end

  @spec parse_file(Path.t()) :: topographic_map()
  defp parse_file(file_path) do
    file_path
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)
    end)
  end
end

IO.puts("Part One: #{Main.part_one()}")
IO.puts("Part Two: #{Main.part_two()}")
