defmodule Todo.Database do
    use GenServer

    def init(db_folder) do
        worker_map = 0..2 |> Enum.reduce(
            HashDict.new,
            fn(id, acc) ->
                {:ok, pid} = Todo.DBWorker.start(db_folder)
                HashDict.put(acc, id, pid)
            end
        )
        {:ok, worker_map}
    end

    def start(db_folder) do
        GenServer.start(__MODULE__, db_folder, name: :database_server)
    end

    def handle_call({:get, key}, _, worker_map) do
        data = Todo.DBWorker.get(HashDict.get(worker_map, get_worker(key)), key)

        {:reply, data, worker_map}
    end

    def handle_cast({:store, key, value}, worker_map) do
        Todo.DBWorker.store(HashDict.get(worker_map, get_worker(key)), key, value)

        {:noreply, worker_map}
    end

    def get(key) do
        GenServer.call(:database_server, {:get, key})
    end

    def store(key, value) do
        GenServer.cast(:database_server, {:store, key, value})
    end

    defp file_name(db_folder, key), do: "#{db_folder}/#{key}"

    defp get_worker(key), do: :erlang.phash2(key, 3)
end
