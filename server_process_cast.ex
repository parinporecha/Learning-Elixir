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


defmodule KeyValueStore do
    def init do
        HashDict.new
    end

    def handle_call({:get, key}, state) do
        {HashDict.get(state, key), state}
    end

    def handle_cast({:put, key, value}, state) do
        HashDict.put(state, key, value)
    end

    def handle_call(_, state) do
        {:ok, state}
    end

    def handle_cast(_, state) do
        state
    end

    def put(pid, key, value) do
        ServerProcess.cast(pid, {:put, key, value})
    end
end
