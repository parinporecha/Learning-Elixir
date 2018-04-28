defmodule ServerProcess do
    def start(callback_module) do
        spawn(fn ->
            initial_state = callback_module.init
            loop(callback_module, initial_state)
        end)
    end

    def loop(callback_module, state) do
        receive do
            {request, caller} ->
                {response, new_state} = callback_module.handle_call(request, state)

            send(caller, {:response, response})
            loop(callback_module, new_state)
        end
    end

    def call(server_pid, request) do
        send(server_pid, {request, self})

        receive do
            {:response, response} -> response
        end
    end
end


defmodule KeyValueStore do
    def init do
        HashDict.new
    end

    def handle_call({:put, key, value}, state) do
        {:ok, HashDict.put(state, key, value)}
    end

    def handle_call({:get, key}, state) do
        {HashDict.get(state, key), state}
    end

    def handle_call(_, state) do
        {:ok, state}
    end


    def start do
        ServerProcess.start(KeyValueStore)
    end

    def put(server_pid, key, value) do
        ServerProcess.call(server_pid, {:put, key, value})
    end

    def get(server_pid, key) do
        ServerProcess.call(server_pid, {:get, key})
    end
end


defmodule Main do
    def main do
        server_pid = ServerProcess.start(KeyValueStore)

        ServerProcess.call(server_pid, {:put, :a, "a"})
        ServerProcess.call(server_pid, {:put, :b, "b"})
        ServerProcess.call(server_pid, {:put, :c, "c"})

        ServerProcess.call(server_pid, {:get, :a})
    end

    def main_abstract do
        pid = KeyValueStore.start

        KeyValueStore.put(pid, :a, "a")
        KeyValueStore.put(pid, :b, "b")
        KeyValueStore.put(pid, :c, "c")

        KeyValueStore.get(pid, :a)
    end
end
