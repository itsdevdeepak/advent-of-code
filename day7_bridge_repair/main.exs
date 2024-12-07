alias AdventOfCode.Day7, as: Main

defmodule AdventOfCode.Day7 do
  @moduledoc """
  Advent of Code Day 7

  https://adventofcode.com/2017/day/7
  """
  @input_file "input.txt"

  def run() do
    @input_file
    |> parse_file()
    |> Enum.reduce(0, fn {target, operands}, acc ->
      if results_to_target(operands, target) do
        acc + target
      else
        acc
      end
    end)
  end

  defp results_to_target([], _target), do: false

  defp results_to_target([head | tail], target) do
    results_to_target(tail, target, head)
  end

  defp results_to_target([], target, result), do: result == target

  defp results_to_target([head | tail], target, result) do
    results_to_target(tail, target, concatenate_numbers(result, head)) or
      results_to_target(tail, target, result + head) or
      results_to_target(tail, target, result * head)
  end

  defp concatenate_numbers(num1, num2) do
    String.to_integer("#{num1}#{num2}")
  end

  defp parse_file(file_path) do
    file_path
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [target, operands] = String.split(line, ": ", trim: true)
      operands = operands |> String.split(" ", trim: true) |> Enum.map(&String.to_integer/1)
      target = String.to_integer(target)
      {target, operands}
    end)
  end
end

IO.puts("Part 2 Solution: #{Main.run()}")
