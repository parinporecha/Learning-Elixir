defmodule Todo.Cache do
    use GenServer

    def init(_) do
        Todo.Database.start_link('./persist')
        {:ok, HashDict.new}
    end

    def handle_call({:server_process, todo_list_name}, _, todo_servers) do
        case HashDict.get(todo_servers, todo_list_name) do
            nil ->
                {:ok, new_server} = Todo.Server.start_link(todo_list_name)
                {:reply, new_server, HashDict.put(todo_servers, todo_list_name, new_server)}

            server ->
                {:reply, server, todo_servers}
        end
    end

    def start_link do
        IO.puts("Starting TodoCache")

        GenServer.start_link(__MODULE__, nil, name: :todo_cache)
    end

    def server_process(todo_list_name) do
        GenServer.call(:todo_cache, {:server_process, todo_list_name})
    end
end
