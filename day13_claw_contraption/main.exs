alias AdventOfCode.Day13, as: Main

defmodule AdventOfCode.Day13 do
  @moduledoc """
  Advent of Code 2020 - Day 13

  https://adventofcode.com/2020/day/13
  """

  @file_input "input.txt"

  @type vector :: {integer(), integer()}
  @type claw_machine_instruction :: %{a: vector(), b: vector(), prize: vector()}

  @spec run() :: integer()
  def run() do
    @file_input
    |> parse_input()
    |> min_token_to_win_all()
  end

  @spec min_token_to_win_all(list(claw_machine_instruction())) :: integer()
  defp min_token_to_win_all(instructions) do
    instructions
    |> Enum.map(&min_token_to_win_prize/1)
    |> Enum.sum()
  end

  @spec min_token_to_win_prize(claw_machine_instruction()) :: integer()
  defp min_token_to_win_prize(instruction) do
    {ax, ay} = Map.get(instruction, :button_a)
    {bx, by} = Map.get(instruction, :button_b)
    {px, py} = Map.get(instruction, :prize)
    px = px + 10_000_000_000_000
    py = py + 10_000_000_000_000

    b = (py - px / ax * ay) / (by - bx / ax * ay)
    a = (px - b * bx) / ax

    a = round(a)
    b = round(b)

    if a * ax + b * bx == px && a * ay + b * by == py do
      3 * a + b
    else
      0
    end
  end

  @spec parse_input(Path.t()) :: list(claw_machine_instruction())
  defp parse_input(file_path) do
    file_path
    |> File.read!()
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn content ->
      [a_x, a_y, b_x, b_y, prize_x, prize_y] =
        Regex.scan(~r/(?:X|Y)[=+](\d+)/, content)
        |> Enum.map(fn match ->
          match
          |> List.last()
          |> String.to_integer()
        end)

      %{
        button_a: {a_x, a_y},
        button_b: {b_x, b_y},
        prize: {prize_x, prize_y}
      }
    end)
  end
end

IO.puts("Day 13 Solution: #{Main.run()}")
