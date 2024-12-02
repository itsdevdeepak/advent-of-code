defmodule Main do
  def run do
    reports = parse_file("input.txt")
    safe_reports = safe_reports(reports)
    safe_count = Enum.count(safe_reports)
    IO.puts("#{safe_count} reports are safe")
  end

  defp safe_reports(reports) do
    Enum.filter(reports, fn report -> is_safe(report) end)
  end

  defp is_safe(report) do
    increasing =
      Enum.any?(0..(length(report) - 1), fn idx ->
        is_safely_increasing(List.delete_at(report, idx))
      end)

    decreasing =
      Enum.any?(0..(length(report) - 1), fn idx ->
        is_safely_decreasing(List.delete_at(report, idx))
      end)

    increasing || decreasing
  end

  def is_safely_increasing(levels) do
    Enum.chunk_every(levels, 2, 1, :discard)
    |> Enum.all?(fn [a, b] ->
      diff = b - a
      diff >= 1 && diff <= 3
    end)
  end

  def is_safely_decreasing(levels) do
    Enum.chunk_every(levels, 2, 1, :discard)
    |> Enum.all?(fn [a, b] ->
      diff = a - b
      diff >= 1 && diff <= 3
    end)
  end

  defp parse_file(file) do
    File.stream!(file)
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.split/1)
    |> Enum.map(fn list -> Enum.map(list, fn report -> String.to_integer(report) end) end)
  end
end

Main.run()
