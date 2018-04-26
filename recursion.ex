defmodule ListSummer do

    def sum(l), do: sum(0, l)

    defp sum(total, []), do: total
    defp sum(total, [hd | tl]) do
        sum(total + hd, tl)
    end

end


defmodule NumPrinter do
    def print(1), do: IO.puts(1)

    def print(n) when n > 1 do
        print(n-1)
        IO.puts(n)
    end

    def print(_), do: 0
end


defmodule TailRecursion do
    def len(l), do: len(0, l)

    defp len(cur_len, []), do: cur_len
    defp len(cur_len, [hd | tl]) do
        len(cur_len+1, tl)
    end


    def range(a, b), do: range([], a, b)

    def range(cur_list, a, a), do: cur_list
    def range(cur_list, a, b) when a > b, do: []
    def range(cur_list, a, b) do
        range(a ++ cur_list, a+1, b)
    end
end


defmodule EnumUse do
    def sum(l) when is_list(l) do
        Enum.reduce(
            l,
            0,
            fn
                element, sum when is_number(element) -> sum + element
                _, sum -> sum
            end
        )
    end

end
