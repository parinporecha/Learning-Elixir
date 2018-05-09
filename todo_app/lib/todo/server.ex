defmodule Todo.Server do
    use GenServer

    def init(todo_list_name) do
        send(self, :real_init)
        {:ok, {todo_list_name, nil}}
    end

    def handle_cast({:add, entry}, {todo_list_name, state}) do
        state = Todo.List.add_entry(state, entry)
        Todo.Database.store(todo_list_name, state)
        {:noreply, {todo_list_name, state}}
    end

    def handle_call({:list, date}, _, {todo_list_name, state}) do
        {:reply, Todo.List.entries(state, date), {todo_list_name, state}}
    end

    def handle_info(:real_init, {todo_list_name, state}) do
        {:noreply, {todo_list_name, Todo.Database.get(todo_list_name) || Todo.List.new}}
    end

    def start_link(todo_list_name) do
        IO.puts("Starting TodoServer for #{todo_list_name}")
        GenServer.start_link(Todo.Server, todo_list_name, name: via_tuple(todo_list_name))
    end

    def add_entry(pid, entry) do
        GenServer.cast(pid, {:add, entry})
    end

    def entries(pid, date) do
        GenServer.call(pid, {:list, date})
    end

    defp via_tuple(name) do
        {:via, :gproc, {:n, :l, {:todo_server, name}}}
    end

    def whereis(name) do
        :gproc.whereis_name({:n, :l, {:todo_server, name}})
    end
end
