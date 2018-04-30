defmodule Todo.Cache do
    use GenServer

    def init(_) do
        {:ok, HashDict.new}
    end

    def handle_call({:server_process, todo_list_name}, _, todo_servers) do
        case HashDict.get(todo_servers, todo_list_name) do
            nil ->
                {:ok, new_server} = Todo.Server.start
                {:reply, new_server, HashDict.put(todo_servers, todo_list_name, new_server)}

            server ->
                {:reply, server, todo_servers}
        end
    end

    def start do
        GenServer.start(__MODULE__, nil)
    end

    def server_process(server_pid, todo_list_name) do
        GenServer.call(server_pid, {:server_process, todo_list_name})
    end
end
