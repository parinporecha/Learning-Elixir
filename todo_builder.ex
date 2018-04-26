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
        todo_list = TodoList.new
        |> TodoList.add_entry(%{date: {2018, 5, 14}, title: "Dentist"})
        |> TodoList.add_entry(%{date: {2018, 5, 14}, title: "Shopping"})
        |> TodoList.add_entry(%{date: {2018, 5, 16}, title: "Movies"})

        todo_list
        |> TodoList.entries({2018, 5, 14})
    end

    def list_all(todo_list, date),  do: TodoList.entries(todo_list, date)
end
