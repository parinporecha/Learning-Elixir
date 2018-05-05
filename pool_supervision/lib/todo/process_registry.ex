defmodule Todo.ProcessRegistry do
    import Kernel, except: [send: 2]
    use GenServer

    def init(_) do
        {:ok, HashDict.new}
    end

    def handle_call({:register_name, key, pid}, _, process_registry) do
        case HashDict.get(process_registry, key) do
            nil ->
                Process.monitor(pid)
                {:reply, :yes, HashDict.put(process_registry, key, pid)}
            _ ->
                {:reply, :no, process_registry}
        end
    end

    def handle_cast({:unregister_name, key}, process_registry) do
        {:noreply, HashDict.delete(process_registry, key)}
    end

    def handle_call({:whereis_name, key}, _, process_registry) do
        {
            :reply,
            HashDict.get(process_registry, key, :undefined),
            process_registry
        }
    end

    def handle_info({:DOWN, _, :process, pid, _}, process_registry) do
        {:noreply, deregister_pid(process_registry, pid)}
    end

    def send(key, message) do
        case whereis_name(key) do
            :undefined -> {:badarg, {key, message}}
            pid ->
                Kernel.send(pid, message)
                pid
        end
    end

    def register_name(key, pid) do
        GenServer.call(:process_registry, {:register_name, key, pid})
    end

    def unregister_name(key) do
        GenServer.cast(:process_registry, {:unregister_name, key})
    end

    def whereis_name(key) do
        GenServer.call(:process_registry, {:whereis_name, key})
    end

    def start_link do
        IO.puts("Starting Process Registry")
        GenServer.start_link(__MODULE__, nil, name: :process_registry)
    end

    defp deregister_pid(process_registry, pid) do
        process_registry
        |> Stream.filter(fn({_, process_pid}) -> process_pid != pid end)
        |> Enum.reduce(HashDict.new, fn({key, val}, acc) -> HashDict.put(acc, key, val) end)
    end
end
