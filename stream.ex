defmodule Streaming do
    def len(path) when is_bitstring(path) do
        File.stream!(path)
        |> Stream.map(fn(line) -> String.replace(line, "\n", "") end)
        |> Enum.map(&String.length/1)
    end

    defp get_max(line, acc) when is_bitstring(line) and is_bitstring(acc) do
        case String.length(line) > String.length(acc) do
            true -> line
            false -> acc
        end
    end

    defp get_max(n, sum) when is_number(n) and is_number(sum) and n > sum, do: n
    defp get_max(_, sum) when is_number(sum), do: sum

    def longest(path) do
        File.stream!(path)
        |> Stream.map(&String.replace(&1, "\n", ""))
        |> Stream.map(&String.length/1)
        |> Enum.reduce(0, &get_max/2)
    end

    def longest_line(path) do
        File.stream!(path)
        |> Stream.map(&String.replace(&1, "\n", ""))
        |> Enum.reduce("", &get_max/2)
    end

    def words_per_line(path) do
        File.stream!(path)
        |> Stream.map(&String.split/1)
        |> Enum.map(&length/1)
    end
end
