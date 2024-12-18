alias AdventOfCode.Day14, as: Main

defmodule AdventOfCode.Day14 do
  @moduledoc """
  Advent Of Code 2024 Day 14

  https://adventofcode.com/2024/day/14
  """
  @input_file "input.txt"
  @room_size {101, 103}

  @type position :: {integer, integer}
  @type velocity :: {integer, integer}
  @type robot :: %{position: position, velocity: velocity}

  @spec part_one() :: integer()
  def part_one do
    @input_file
    |> parse_input()
    |> robot_states_after_moving(100)
    |> group_by_quadrant()
    |> Map.delete(:middle)
    |> Map.values()
    |> Enum.map(&length/1)
    |> Enum.product()
  end

  @spec part_two() :: integer()
  def part_two do
    @input_file
    |> parse_input()
    |> second_when_christmas_tree_appears()
  end

  defp second_when_christmas_tree_appears(robots) do
    total_robot = length(robots)
    {w, h} = @room_size
    max_steps = w * h
    second_when_christmas_tree_appears(robots, total_robot, 1, max_steps)
  end

  @spec second_when_christmas_tree_appears(list(robot()), integer, integer, integer) ::
          integer() | nil

  defp second_when_christmas_tree_appears(_robots, _total_robot, current_step, max_steps)
       when current_step > max_steps do
    nil
  end

  defp second_when_christmas_tree_appears(robots, total_robot, current_step, max_steps) do
    set =
      robots
      |> Enum.reduce(MapSet.new(), fn robot, acc ->
        %{position: {px, py}, velocity: _velocity} = move_robot(robot, current_step)
        MapSet.put(acc, {px, py})
      end)

    if MapSet.size(set) == total_robot do
      current_step
    else
      second_when_christmas_tree_appears(robots, total_robot, current_step + 1, max_steps)
    end
  end

  @spec group_by_quadrant(list(robot())) :: %{atom() => list(robot())}
  defp group_by_quadrant(robot) do
    {w, h} = @room_size
    col_mid = div(w, 2)
    row_mid = div(h, 2)

    Enum.group_by(robot, fn %{position: {px, py}} ->
      cond do
        px == col_mid or py == row_mid -> :middle
        px < col_mid and py < row_mid -> :top_left
        px >= col_mid and py < row_mid -> :top_right
        px < col_mid and py >= row_mid -> :bottom_left
        px >= col_mid and py >= row_mid -> :bottom_right
      end
    end)
  end

  @spec robot_states_after_moving(list(robot()), integer) :: list(robot())
  defp robot_states_after_moving(robots, times) do
    robots |> Enum.map(&move_robot(&1, times))
  end

  @spec move_robot(robot(), integer) :: robot()
  defp move_robot(robot, times) do
    %{position: {px, py}, velocity: {vx, vy}} = robot

    new_px = Integer.mod(px + vx * times, @room_size |> elem(0))
    new_py = Integer.mod(py + vy * times, @room_size |> elem(1))

    %{position: {new_px, new_py}, velocity: {vx, vy}}
  end

  @spec parse_input(Path.t()) :: list(robot())
  defp parse_input(file_path) do
    file_path
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [px, py, vx, vy] =
        Regex.scan(~r/p=(-?\d+),(-?\d+) v=(-?\d+),(-?\d+)/, line, capture: :all_but_first)
        |> hd()
        |> Enum.map(&String.to_integer/1)

      %{position: {px, py}, velocity: {vx, vy}}
    end)
  end
end

Main.part_one() |> IO.inspect(label: "Day14 Part One Solution:")
Main.part_two() |> IO.inspect(label: "Day14 Part Two Solution:")
