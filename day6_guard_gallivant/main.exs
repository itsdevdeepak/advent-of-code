alias AdventOfCode.Day6, as: Main

defmodule Guard do
  @type real_map :: list(list(char))
  @type direction :: :up | :down | :left | :right
  @type position :: {integer, integer}

  @spec guard_trail(real_map) :: real_map()
  def guard_trail(map) do
    {position, direction} = guard_position(map)
    move(map, position, direction)
  end

  @spec guard_in_loop?(real_map, {position(), direction()}) :: boolean
  def guard_in_loop?(map, {position, direction}) do
    guard_in_loop?(map, position, direction)
  end

  @spec guard_in_loop?(real_map, position(), direction()) :: boolean
  defp guard_in_loop?(map, {y, x}, direction, step \\ 0, seen_o \\ 0) do
    next_position = next_position({y, x}, direction)
    next_cell = get_cell(map, next_position)

    case next_cell do
      nil ->
        false

      "#" ->
        guard_in_loop?(map, {y, x}, turn_90_degree(direction), step + 1, seen_o)

      "O" ->
        guard_in_loop?(map, {y, x}, turn_90_degree(direction), step + 1, seen_o + 1)

      _ ->
        if seen_o > 4 || step > 100_000 do
          true
        else
          map
          |> guard_in_loop?(next_position({y, x}, direction), direction, step, seen_o)
        end
    end
  end

  @spec move(real_map, position(), direction()) :: real_map()
  defp move(map, {y, x}, direction) do
    next_position = next_position({y, x}, direction)
    next_cell = get_cell(map, next_position)

    case next_cell do
      nil ->
        map |> mark_cell({y, x}, "X")

      "#" ->
        move(map, {y, x}, turn_90_degree(direction))

      _ ->
        next_position = next_position({y, x}, direction)
        map |> mark_cell({y, x}, "X") |> move(next_position, direction)
    end
  end

  @spec guard_position(real_map) :: {position(), direction()}
  def guard_position(map) do
    direction_symbols = %{
      ">" => :right,
      "<" => :left,
      "^" => :up,
      "v" => :down
    }

    for(
      {row, y} <- Enum.with_index(map),
      {cell, x} <- Enum.with_index(row),
      Map.has_key?(direction_symbols, cell),
      do: {{y, x}, direction_symbols[cell]}
    )
    |> hd()
  end

  @spec mark_cell(real_map, position(), char) :: real_map
  defp mark_cell(map, {y, x}, marker) do
    List.update_at(map, y, fn row ->
      List.update_at(row, x, fn _ -> marker end)
    end)
  end

  @spec get_cell(real_map, position()) :: char | nil
  defp get_cell(_map, {y, x}) when y < 0 or x < 0, do: nil

  defp get_cell(map, {y, x}) do
    map |> Enum.at(y, []) |> Enum.at(x, nil)
  end

  @spec next_position(position(), direction()) :: position()
  defp next_position({y, x}, :up), do: {y - 1, x}
  defp next_position({y, x}, :down), do: {y + 1, x}
  defp next_position({y, x}, :left), do: {y, x - 1}
  defp next_position({y, x}, :right), do: {y, x + 1}

  @spec turn_90_degree(direction()) :: direction()
  defp turn_90_degree(:up), do: :right
  defp turn_90_degree(:right), do: :down
  defp turn_90_degree(:down), do: :left
  defp turn_90_degree(:left), do: :up
end

defmodule AdventOfCode.Day6 do
  @moduledoc """
  Advent of Code 2018 Day 6

  https://adventofcode.com/2018/day/6
  """
  @input_file "input.txt"

  @type lab_map :: list(list(char))
  @type direction :: :up | :down | :left | :right
  @type position :: {integer, integer}

  @spec part_one() :: integer
  def part_one do
    lab_map = @input_file |> parse_file()

    guard_trail = lab_map |> Guard.guard_trail()

    for row <- guard_trail do
      Enum.count(row, fn cell -> cell == "X" end)
    end
    |> Enum.sum()
  end

  @spec part_two() :: integer
  def part_two do
    lab_map =
      @input_file
      |> parse_file()

    guard_position = lab_map |> Guard.guard_position()

    lab_map
    |> Guard.guard_trail()
    |> obstacles_causing_guard_to_loop(guard_position)
  end

  @spec obstacles_causing_guard_to_loop(lab_map(), position()) :: integer
  defp obstacles_causing_guard_to_loop(guard_trail, guard_position) do
    guard_trail
    |> Enum.with_index()
    |> Enum.reduce(0, fn {row, row_idx}, acc ->
      row
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {cell, col_idx}, acc_inner ->
        if cell == "X" do
          updated_map = mark_obstacle(guard_trail, {row_idx, col_idx})

          if Guard.guard_in_loop?(updated_map, guard_position) do
            acc_inner + 1
          else
            acc_inner
          end
        else
          acc_inner
        end
      end)
    end)
  end

  @spec mark_obstacle(lab_map, position()) :: lab_map()
  defp mark_obstacle(map, {y, x}) do
    List.update_at(map, y, fn row ->
      List.update_at(row, x, fn _ -> "O" end)
    end)
  end

  @spec parse_file(Path.t()) :: lab_map()
  defp parse_file(file_path) do
    file_path
    |> File.read!()
    |> String.split("\n")
    |> Enum.map(&String.split(&1, "", trim: true))
  end
end

IO.puts("Part 1 Solution: #{Main.part_one()}")
IO.puts("Part 2 Solution: #{Main.part_two()}")
