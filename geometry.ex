defmodule Geometry do
    @pi 3.14159

    def rectangle_area(a, b) do
        a * b
    end

    def square_area(a) do
        rectangle_area(a, a)
    end

    def circle_area(a) do
        a * a * @pi
    end
end


defmodule NumLines do

    defp num_lines({:error, _}), do: 0
    defp num_lines({:ok, content}) do
        content
        |> String.split("\n")
        |> length
    end

    def main(s) do
        File.read(s) |> num_lines
    end

end
