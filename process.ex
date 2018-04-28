
defmodule Query do
    run_query = fn(query_str) ->
        :timer.sleep(2000)
        "#{query_str} result"
    end

    async_query = fn(query_str) ->
        caller = self
        spawn(fn -> send(caller, {:query_result, run_query.(query_str)}) end)
    end

    get_result = fn ->
        receive do
            {:query_result, result} -> result
        end
    end
end

defmodule Main do
    def main do
        Query.run_query.("Query 1")
    end
end
