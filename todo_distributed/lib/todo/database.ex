defmodule Todo.Database do
    @pool_size 3

    def start_link(db_folder) do
        IO.puts("Starting TodoDatabase")
        Todo.PoolSupervisor.start_link(db_folder, @pool_size)
    end

    def get(key) do
        key
        |> get_worker
        |> Todo.DBWorker.get(key)
    end

    def store(key, value) do
        {results, bad_nodes} =
            :rpc.multicall(__MODULE__, :store_local, [key, value], :timer.seconds(5))

        Enum.each(bad_nodes, &IO.puts("Store failed on node #{&1}"))
        :ok
    end

    def store_local(key, value) do
        key
        |> get_worker
        |> Todo.DBWorker.store(key, value)
    end

    defp get_worker(key), do: :erlang.phash2(key, @pool_size) + 1
end
