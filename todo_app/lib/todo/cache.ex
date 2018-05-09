defmodule Todo.Cache do
    use GenServer

    def init(_) do
        {:ok, HashDict.new}
    end

    def handle_call({:server_process, todo_list_name}, _, todo_servers) do
        case Todo.Server.whereis(todo_list_name) do
            :undefined ->
                {:ok, new_server} = Todo.ServerSupervisor.start_child(todo_list_name)
                {:reply, new_server, HashDict.put(todo_servers, todo_list_name, new_server)}

            server_pid ->
                {:reply, server_pid, todo_servers}
        end
    end

    def start_link do
        IO.puts("Starting TodoCache")

        GenServer.start_link(__MODULE__, nil, name: :todo_cache)
    end

    def server_process(todo_list_name) do
        case Todo.Server.whereis(todo_list_name) do
            :undefined ->
                GenServer.call(:todo_cache, {:server_process, todo_list_name})
            server_pid -> server_pid
        end
    end
end
