defmodule ServerProcess do
    def start(callback_module) do
        spawn(fn ->
            initial_state = callback_module.init
            loop(callback_module, initial_state)
        end)
    end

    def loop(callback_module, state) do
        receive do
            {:call, request, caller} ->
                {response, new_state} = callback_module.handle_call(request, state)
                send(caller, {:response, response})

            {:cast, request} ->
                new_state = callback_module.handle_cast(request, state)

            loop(callback_module, new_state)
        end
    end

    def call(server_pid, request) do
        send(server_pid, {:call, request, self})

        receive do
            {:response, response} -> response
        end
    end

    def cast(server_pid, request) do
        send(server_pid, {:cast, request})
    end
end


defmodule TodoServer do
    def init do
        TodoList.new
    end

    def handle_cast({:add, entry}, todo_list) do
        TodoList.add_entry(todo_list, entry)
    end

    def handle_call({:get, date}, todo_list) do
        {TodoList.entries(todo_list, date), todo_list}
    end

    def start do
        ServerProcess.start(TodoServer)
    end

    def add_entry(server_pid, entry), do: ServerProcess.cast(server_pid, {:add, entry})

    def entries(server_pid, date), do: ServerProcess.call(server_pid, {:get, date})
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
