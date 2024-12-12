alias AdventOfCode.Day11, as: Main

defmodule AdventOfCode.Day11 do
  @moduledoc """
  Advent of Code 2020 - Day 11

  https://adventofcode.com/2020/day/11
  """
  require Integer
  @input_file "input.txt"

  @type stones :: %{integer() => integer()}

  @spec run() :: integer()
  def run() do
    @input_file
    |> parse_file()
    |> blink(300)
    |> Map.values()
    |> Enum.sum()
  end

  @spec blink(stones(), integer()) :: stones()
  defp blink(stones, 0), do: stones

  @spec blink(stones(), integer()) :: stones()
  defp blink(stones, times) do
    stones
    |> process_stones()
    |> blink(times - 1)
  end

  @spec process_stones(stones()) :: stones()
  defp process_stones(stones) do
    Map.keys(stones)
    |> Enum.reduce(%{}, fn stone, acc ->
      stone_freq = Map.get(stones, stone)

      cond do
        stone == 0 ->
          acc
          |> Map.update(1, stone_freq, &(&1 + stone_freq))

        even_digit?(stone) ->
          {first, second} = split_digit_equally(stone)

          acc
          |> Map.update(first, stone_freq, &(&1 + stone_freq))
          |> Map.update(second, stone_freq, &(&1 + stone_freq))

        true ->
          acc
          |> Map.update(stone * 2024, stone_freq, &(&1 + stone_freq))
      end
    end)
  end

  @spec split_digit_equally(integer()) :: {integer(), integer()}
  defp split_digit_equally(num) do
    digits = Integer.digits(num)
    half = div(length(digits), 2)
    {first, second} = Enum.split(digits, half)
    {Integer.undigits(first), Integer.undigits(second)}
  end

  @spec even_digit?(integer()) :: boolean()
  defp even_digit?(stone) do
    Integer.digits(stone) |> length() |> Integer.is_even()
  end

  @spec parse_file(Path.t()) :: stones()
  defp parse_file(file_path) do
    file_path
    |> File.read!()
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.frequencies()
  end
end

IO.puts("Day 11 Solution: #{Main.run()}")
