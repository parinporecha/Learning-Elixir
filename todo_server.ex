defmodule TodoServer do
    def start do
        spawn(fn ->
            todo_list = TodoList.new
            server(todo_list)
        end)
    end

    defp server(todo_list) do
        todo_list = receive do
            {:add, entry} ->
                TodoList.add_entry(todo_list, entry)

            {:list, date, caller} ->
                send(caller, {:response, TodoList.entries(todo_list, date)})
                todo_list
        end

        server(todo_list)
    end

    def add_entry(server_pid, entry), do: send(server_pid, {:add, entry})

    def entries(server_pid, date) do
        send(server_pid, {:list, date, self})

        receive do
            {:response, entries_list} -> entries_list
        after 5000 -> {:error, :timeout}
        end
    end
end


defmodule TodoServerRegistered do
    def start do
        server_pid = spawn(fn ->
            todo_list = TodoList.new
            server(todo_list)
        end)
        Process.register(server_pid, :todo_server)
    end

    defp server(todo_list) do
        todo_list = receive do
            {:add, entry} ->
                TodoList.add_entry(todo_list, entry)

            {:list, date, caller} ->
                send(caller, {:response, TodoList.entries(todo_list, date)})
                todo_list
        end

        server(todo_list)
    end

    def add_entry(entry), do: send(:todo_server, {:add, entry})

    def entries(date) do
        send(:todo_server, {:list, date, self})

        receive do
            {:response, entries_list} -> entries_list
        after 5000 -> {:error, :timeout}
        end
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
        todo_server = TodoServer.start

        TodoServer.add_entry(todo_server, %{date: {2013, 12, 19}, title: "Dentist"})
        TodoServer.add_entry(todo_server, %{date: {2013, 12, 20}, title: "Shopping"})
        TodoServer.add_entry(todo_server, %{date: {2013, 12, 19}, title: "Movies"})

        TodoServer.entries(todo_server, {2013, 12, 19})
    end

    def main_registered do
        TodoServerRegistered.start

        TodoServerRegistered.add_entry(%{date: {2013, 12, 19}, title: "Dentist"})
        TodoServerRegistered.add_entry(%{date: {2013, 12, 20}, title: "Shopping"})
        TodoServerRegistered.add_entry(%{date: {2013, 12, 19}, title: "Movies"})

        TodoServerRegistered.entries({2013, 12, 19})
    end
end
