alias AdventOfCode.Day15.PartTwo, as: Main

defmodule AdventOfCode.Day15.PartTwo do
  @moduledoc """
    Advent Of Code 2024 Day 15 Part Two

    https://adventofcode.com/2024/day/15
  """

  @input_file "input.txt"
  @type warehouse_map :: list(list(char()))
  @type direction :: :up | :down | :left | :right
  @type position :: {integer, integer}

  @spec run() :: integer()
  def run() do
    @input_file
    |> parse_input()
    |> warehouse_map_after_movement()
    |> box_gps_coordinates()
    |> Enum.sum()
  end

  @spec warehouse_map_after_movement(%{
          warehouse_map: warehouse_map(),
          directions: list(direction())
        }) :: warehouse_map()
  defp warehouse_map_after_movement(%{warehouse_map: warehouse_map, directions: directions}) do
    robot_position = get_robot_position(warehouse_map)
    move(warehouse_map, robot_position, directions)
  end

  @spec move(warehouse_map(), position(), list(direction())) :: warehouse_map()
  defp move(warehouse_map, _position, []), do: warehouse_map

  @spec move(warehouse_map(), position(), list(direction())) :: warehouse_map()
  defp move(warehouse_map, position, [direction | rest]) do
    warehouse_map = push(warehouse_map, [position], direction)
    move(warehouse_map, get_robot_position(warehouse_map), rest)
  end

  @spec push(warehouse_map(), list(position()), direction()) :: warehouse_map()
  defp push(warehouse_map, positions, direction) do
    next_positions =
      next_marking_positions(warehouse_map, positions, direction)
      |> Enum.reject(&(&1 in positions))
      |> Enum.uniq()

    cond do
      contain_wall?(warehouse_map, next_positions) ->
        warehouse_map

      all_empty?(warehouse_map, next_positions) ->
        update_warehouse_map(warehouse_map, positions, direction)

      true ->
        updated_map = push_boxes(warehouse_map, next_positions, direction)

        if can_move?(updated_map, positions, direction) do
          update_warehouse_map(updated_map, positions, direction)
        else
          updated_map
        end
    end
  end

  @spec push_boxes(warehouse_map(), list(position()), direction()) :: warehouse_map()
  defp push_boxes(warehouse_map, positions, direction) do
    non_empty_position = Enum.reject(positions, &(get_cell(warehouse_map, &1) == "."))
    push(warehouse_map, non_empty_position, direction)
  end

  @spec next_position(list(position()), direction()) :: list(position())
  defp next_marking_positions(warehouse_map, positions, direction) do
    positions
    |> Enum.flat_map(fn position ->
      next_position = next_position(position, direction)

      case get_cell(warehouse_map, next_position) do
        "[" ->
          [next_position, next_position(next_position, :right)]

        "]" ->
          [next_position(next_position, :left), next_position]

        _ ->
          [next_position]
      end
    end)
  end

  @spec contain_wall?(warehouse_map(), list(position())) :: boolean()
  defp contain_wall?(warehouse_map, positions) do
    Enum.any?(positions, fn position ->
      get_cell(warehouse_map, position) == "#"
    end)
  end

  @spec all_empty?(warehouse_map(), list(position())) :: boolean()
  defp all_empty?(warehouse_map, positions) do
    Enum.all?(positions, fn position ->
      get_cell(warehouse_map, position) == "."
    end)
  end

  @spec can_move?(warehouse_map(), list(position()), direction()) :: boolean()
  defp can_move?(warehouse_map, positions, direction) do
    if direction in [:left, :right] do
      can_move_horizontally?(warehouse_map, positions, direction)
    else
      can_move_vertically?(warehouse_map, positions, direction)
    end
  end

  @spec can_move_horizontally?(warehouse_map(), list(position()), direction()) :: boolean()
  defp can_move_horizontally?(warehouse_map, positions, direction) do
    Enum.any?(positions, fn position ->
      get_cell(warehouse_map, next_position(position, direction)) == "."
    end)
  end

  @spec can_move_vertically?(warehouse_map(), list(position()), direction()) :: boolean()
  defp can_move_vertically?(warehouse_map, positions, direction) do
    Enum.all?(positions, fn position ->
      get_cell(warehouse_map, next_position(position, direction)) == "."
    end)
  end

  @spec update_warehouse_map(warehouse_map(), list(position()), direction()) ::
          warehouse_map()
  defp update_warehouse_map(warehouse_map, positions, direction) do
    positions =
      if direction == :right do
        Enum.reverse(positions)
      else
        positions
      end

    Enum.reduce(positions, warehouse_map, fn current_position, acc ->
      next_position = next_position(current_position, direction)

      mark_cell(acc, next_position, get_cell(warehouse_map, current_position))
      |> mark_cell(current_position, ".")
    end)
  end

  @spec box_gps_coordinates(warehouse_map()) :: list(integer())
  defp box_gps_coordinates(warehouse_map) do
    for {row, row_idx} <- Enum.with_index(warehouse_map),
        {cell, column_idx} <- Enum.with_index(row),
        cell == "[" do
      gps_coordinate({row_idx, column_idx})
    end
  end

  @spec gps_coordinate(position()) :: integer()
  def gps_coordinate({y, x}) do
    100 * y + x
  end

  @spec get_robot_position(warehouse_map()) :: position()
  defp get_robot_position(warehouse_map) do
    for {row, row_idx} <- Enum.with_index(warehouse_map),
        {cell, column_idx} <- Enum.with_index(row),
        cell == "@" do
      {row_idx, column_idx}
    end
    |> hd()
  end

  @spec mark_cell(warehouse_map(), position(), char()) :: warehouse_map()
  defp mark_cell(warehouse_map, {y, x}, marker) do
    List.update_at(warehouse_map, y, fn row ->
      List.update_at(row, x, fn _ -> marker end)
    end)
  end

  @spec get_cell(warehouse_map(), position()) :: char()
  defp get_cell(warehouse_map, {y, x}) do
    warehouse_map
    |> Enum.at(y)
    |> Enum.at(x)
  end

  @spec next_position(position(), direction()) :: position()
  defp next_position({y, x}, :up), do: {y - 1, x}
  defp next_position({y, x}, :down), do: {y + 1, x}
  defp next_position({y, x}, :left), do: {y, x - 1}
  defp next_position({y, x}, :right), do: {y, x + 1}

  @spec parse_input(Path.t()) :: %{warehouse_map: warehouse_map(), directions: list(direction())}
  defp parse_input(file_path) do
    [raw_warehouse_map, raw_direction] =
      file_path
      |> File.read!()
      |> String.split("\n\n", trim: true)

    warehouse_map = parse_map(raw_warehouse_map)
    direction = parse_direction(raw_direction)
    %{warehouse_map: warehouse_map, directions: direction}
  end

  @spec parse_map(String.t()) :: warehouse_map()
  defp parse_map(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.graphemes()
      |> Enum.flat_map(fn char ->
        case char do
          "#" -> ["#", "#"]
          "." -> [".", "."]
          "@" -> ["@", "."]
          "O" -> ["[", "]"]
          _ -> raise "Invalid character in map"
        end
      end)
    end)
  end

  @spec parse_direction(String.t()) :: list(direction())
  defp parse_direction(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.flat_map(&String.graphemes/1)
    |> Enum.map(fn char ->
      case char do
        "^" -> :up
        "v" -> :down
        "<" -> :left
        ">" -> :right
        _ -> raise "Invalid direction"
      end
    end)
  end
end

Main.run() |> IO.inspect(label: "Day 15 Part Two Solution")
