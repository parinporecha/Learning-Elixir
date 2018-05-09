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
        key
        |> get_worker
        |> Todo.DBWorker.store(key, value)
    end

    defp get_worker(key), do: :erlang.phash2(key, @pool_size) + 1
end
