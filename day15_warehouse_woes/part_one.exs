alias AdventOfCode.Day15.PartOne, as: Main

defmodule AdventOfCode.Day15.PartOne do
  @moduledoc """
    Advent Of Code 2024 Day 15 Part One

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

  @spec box_gps_coordinates(warehouse_map()) :: list(integer())
  def box_gps_coordinates(warehouse_map) do
    for {row, row_idx} <- Enum.with_index(warehouse_map),
        {cell, column_idx} <- Enum.with_index(row),
        cell == "O" do
      gps_coordinate({row_idx, column_idx})
    end
  end

  @spec gps_coordinate(position()) :: integer()
  def gps_coordinate({y, x}) do
    100 * y + x
  end

  @spec warehouse_map_after_movement(%{
          warehouse_map: warehouse_map(),
          directions: list(direction())
        }) :: warehouse_map()
  defp warehouse_map_after_movement(%{warehouse_map: warehouse_map, directions: directions}) do
    robot_position = get_robot_position(warehouse_map)
    move(warehouse_map, robot_position, directions)
  end

  defp move(warehouse_map, _position, []) do
    warehouse_map
  end

  defp move(warehouse_map, position, [direction | rest]) do
    next_empty_area = get_next_empty_area(warehouse_map, position, direction)

    if next_empty_area do
      next_position = next_position(position, direction)
      warehouse_map = update_warehouse_map(warehouse_map, position, next_empty_area, direction)
      move(warehouse_map, next_position, rest)
    else
      move(warehouse_map, position, rest)
    end
  end

  @spec update_warehouse_map(warehouse_map(), position(), position(), direction()) ::
          warehouse_map()
  defp update_warehouse_map(warehouse_map, current_position, next_empty_position, direction) do
    warehouse_map = mark_cell(warehouse_map, current_position, ".")
    next_position = next_position(current_position, direction)

    if next_position == next_empty_position do
      mark_cell(warehouse_map, next_empty_position, "@")
    else
      mark_cell(warehouse_map, next_position, "@")
      |> mark_cell(next_empty_position, "O")
    end
  end

  @spec get_next_empty_area(warehouse_map(), position(), direction()) :: position() | nil
  defp get_next_empty_area(warehouse_map, position, direction) do
    next_position = next_position(position, direction)

    case get_cell(warehouse_map, next_position) do
      "." ->
        next_position

      "#" ->
        nil

      _ ->
        get_next_empty_area(warehouse_map, next_position, direction)
    end
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
    direction = print_direction(raw_direction)
    %{warehouse_map: warehouse_map, directions: direction}
  end

  @spec parse_map(String.t()) :: warehouse_map()
  defp parse_map(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes/1)
  end

  @spec print_direction(String.t()) :: list(direction())
  defp print_direction(input) do
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

Main.run() |> IO.inspect(label: "Day 15 Part One Solution")
