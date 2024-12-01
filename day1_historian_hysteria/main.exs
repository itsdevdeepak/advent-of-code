defmodule HistorianHysteria do
  def main() do
    list = parseFileToTupleList("input.txt")
    {left, right} = Enum.unzip(list)
    difference = getSumOfDifferences(left, right)
    similarity = getSumOfSimilarities(left, right)

    IO.inspect(left, label: "Left")
    IO.inspect(right, label: "Right")
    IO.inspect(difference, label: "Difference")
    IO.inspect(similarity, label: "Similarity")
  end

  def getSumOfSimilarities(left, right) do
    similarities = Enum.map(left, fn x -> x * length(Enum.filter(right, fn y -> x == y end)) end)
    Enum.sum(similarities)
  end

  def getSumOfDifferences(left, right) do
    left_sorted = Enum.sort(left)
    right_sorted = Enum.sort(right)
    difference = Enum.zip(left_sorted, right_sorted) |> Enum.map(fn {a, b} -> abs(a - b) end)
    Enum.sum(difference)
  end

  def parseFileToTupleList(file) do
    File.stream!(file)
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.split(&1, " ", trim: true))
    |> Enum.map(fn [a, b] -> {String.to_integer(a), String.to_integer(b)} end)
  end
end

HistorianHysteria.main()
