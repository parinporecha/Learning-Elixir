defmodule Todo.PoolSupervisor do
    use Supervisor

    def start_link(db_folder, pool_size) do
        Supervisor.start_link(__MODULE__, {db_folder, pool_size})
    end

    def init({db_folder, pool_size}) do
        1..pool_size
        |> Enum.map(
            fn(worker_id) ->
                worker(Todo.DBWorker, [db_folder, worker_id], id: {:database_worker, worker_id})
            end)
        |> supervise(strategy: :one_for_one)
    end
end
