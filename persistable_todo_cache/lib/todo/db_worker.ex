defmodule Todo.DBWorker do
    use GenServer

    def init(db_folder) do
        File.mkdir_p(db_folder)
        {:ok, db_folder}
    end

    def start(db_folder) do
        GenServer.start(__MODULE__, db_folder)
    end

    def handle_call({:get, key}, _, db_folder) do
        data = case File.read(file_name(db_folder, key)) do
            {:ok, contents} -> :erlang.binary_to_term(contents)
            _ -> nil
        end

        {:reply, data, db_folder}
    end

    def handle_cast({:store, key, value}, db_folder) do
        file_name(db_folder, key)
        |> File.write!(:erlang.term_to_binary(value))

        {:noreply, db_folder}
    end

    def get(server_pid, key) do
        GenServer.call(server_pid, {:get, key})
    end

    def store(server_pid, key, value) do
        GenServer.cast(server_pid, {:store, key, value})
    end

    defp file_name(db_folder, key), do: "#{db_folder}/#{key}"
end
