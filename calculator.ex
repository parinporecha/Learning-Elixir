defmodule Calculator do
    def start do
        spawn(fn ->
            initial_state = 0
            server(initial_state)
        end)
    end

    defp server(state) do
        new_state = receive do
            {:value, caller} ->
                send(caller, {:response, state})
                state

            {:add, value} -> state + value
            {:sub, value} -> state - value
            {:mul, value} -> state * value
            {:div, value} -> state / value

            invalid_request ->
                IO.puts("Received invalid request #{inspect invalid_request}")
                state

        end

        server(new_state)
    end

    def value(server_pid) do
        send(server_pid, {:value, self})

        receive do
            {:response, value} -> value
        end
    end

    def add(server_pid, value) do
        send(server_pid, {:add, value})
    end

    def sub(server_pid, value) do
        send(server_pid, {:sub, value})
    end

    def mul(server_pid, value) do
        send(server_pid, {:mul, value})
    end

    def div(server_pid, value) do
        send(server_pid, {:div, value})
    end
end


defmodule Main do
    def main do
        calculator_pid = Calculator.start

        IO.puts(Calculator.value(calculator_pid))

        Calculator.add(calculator_pid, 10)
        Calculator.sub(calculator_pid, 5)
        Calculator.mul(calculator_pid, 3)
        Calculator.div(calculator_pid, 5)

        IO.puts(Calculator.value(calculator_pid))
    end
end
