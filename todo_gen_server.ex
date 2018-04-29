defmodule TodoServer do
    use GenServer

    def init(_) do
        {:ok, TodoList.new}
    end

    def handle_cast({:add, entry}, state) do
        {:noreply, TodoList.add_entry(state, entry)}
    end

    def handle_call({:list, date}, _, state) do
        {:reply, TodoList.entries(state, date), state}
    end

    def start do
        GenServer.start(TodoServer, nil)
    end

    def add_entry(pid, entry) do
        GenServer.cast(pid, {:add, entry})
    end

    def entries(pid, date) do
        GenServer.call(pid, {:list, date})
    end
end


defmodule TodoList do
    defstruct auto_id: 1, entries: HashDict.new

    def new(entries \\ []) do
        Enum.reduce(
            entries,
            %TodoList{},
            fn(entry, todo_list_acc) -> add_entry(todo_list_acc, entry) end
        )
    end

    def add_entry(
        %TodoList{entries: entries, auto_id: auto_id} = todo_list,
        entry
    ) do
        entry = Map.put(entry, :id, auto_id)
        new_entries = HashDict.put(entries, auto_id, entry)

        %TodoList{todo_list |
            entries: new_entries,
            auto_id: auto_id + 1
        }
    end

    def update_entry(
        %TodoList{entries: entries, auto_id: auto_id} = todo_list,
        entry_id,
        updater_fn
    ) do
        case entries[entry_id] do
            nil -> todo_list

            old_entry ->
                old_entry_id = old_entry.id
                new_entry = %{id: ^old_entry_id} = updater_fn.(old_entry)
                new_entries = HashDict.put(entries, new_entry.id, new_entry)
                %TodoList{todo_list | entries: new_entries}
        end
    end

    def delete_entry(
        %TodoList{entries: entries, auto_id: auto_id} = todo_list,
        entry_id
    ) do
        case entries[entry_id] do
            nil -> todo_list

            to_delete ->
                new_entries = HashDict.delete(entries, entry_id)
                %TodoList{todo_list | entries: new_entries}
        end
    end

    def entries(%TodoList{entries: entries, auto_id: auto_id} = todo_list, date) do
        entries
        |> Stream.filter(fn({_, entry}) -> entry.date == date end)
        |> Enum.map(fn({_, entry}) -> entry end)
    end
end


defmodule Main do
    def main do
        {:ok, todo_server} = TodoServer.start

        TodoServer.add_entry(todo_server, %{date: {2013, 12, 19}, title: "Dentist"})
        TodoServer.add_entry(todo_server, %{date: {2013, 12, 20}, title: "Shopping"})
        TodoServer.add_entry(todo_server, %{date: {2013, 12, 19}, title: "Movies"})

        TodoServer.entries(todo_server, {2013, 12, 19})
    end
end
