defmodule Todo.Server do
    use GenServer

    def init(_) do
        {:ok, Todo.List.new}
    end

    def handle_cast({:add, entry}, state) do
        {:noreply, Todo.List.add_entry(state, entry)}
    end

    def handle_call({:list, date}, _, state) do
        {:reply, Todo.List.entries(state, date), state}
    end

    def start do
        GenServer.start(Todo.Server, nil)
    end

    def add_entry(pid, entry) do
        GenServer.cast(pid, {:add, entry})
    end

    def entries(pid, date) do
        GenServer.call(pid, {:list, date})
    end
end
