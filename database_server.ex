
defmodule DatabaseServer do
    def start do
        spawn(&loop/0)
    end

    defp loop do
        receive do
            {:run_query, caller, query_str} ->
                send(caller, {:query_result, run_query(query_str)})
        end

        loop
    end

    def run_async(server_pid, query_str) do
        send(server_pid, {:run_query, self, query_str})
    end

    defp run_query(query_str) do
        :timer.sleep(2000)
        "#{query_str} result"
    end

    def get_result do
        receive do
            {:query_result, result} -> result
        after 5000 ->
            {:error, :timeout}
        end
    end
end

defmodule Main do
    def main do
        server_pid = DatabaseServer.start
        DatabaseServer.run_async(server_pid, "Query 1")
        IO.puts(DatabaseServer.get_result)

        DatabaseServer.run_async(server_pid, "Query 2")
        IO.puts(DatabaseServer.get_result)
    end
end
