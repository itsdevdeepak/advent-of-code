defmodule Main do
  @input_file "input.txt"

  def run do
    @input_file
    |> parse_input
    |> get_valid_instruction
    |> execute_instructions
    |> IO.inspect(label: "Result")
  end

  defp execute_instructions(instructions) do
    instructions
    |> Enum.reduce(0, fn instruction, total ->
      ~r/\d+/
      |> Regex.scan(instruction)
      |> Enum.flat_map(& &1)
      |> Enum.map(&String.to_integer/1)
      |> Enum.product()
      |> Kernel.+(total)
    end)
  end

  defp get_valid_instruction(input) do
    ~r/mul\(\d+,\d+\)|do\(\)|don\'t\(\)/
    |> Regex.scan(input)
    |> Enum.map(&hd/1)
    |> Enum.reduce({[], true}, fn instruction, {valid_list, is_enable} ->
      case {instruction, is_enable} do
        {"do()", _} -> {valid_list, true}
        {"don't()", _} -> {valid_list, false}
        {mul, true} -> {[mul | valid_list], true}
        {_, false} -> {valid_list, false}
      end
    end)
    |> elem(0)
  end

  defp parse_input(file_path) do
    File.read!(file_path)
  end
end

Main.run()
