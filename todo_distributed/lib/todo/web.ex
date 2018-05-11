defmodule Todo.Web do
    use Plug.Router

    plug :match
    plug :dispatch

    def start_server do
        port = case Application.get_env(:todo, :port) do
            nil -> 5454
            port -> port
        end
        Plug.Adapters.Cowboy.http(__MODULE__, nil, port: port)
    end

    post "/add_entry" do
        conn
        |> Plug.Conn.fetch_query_params
        |> add_entry
        |> respond
    end

    get "/entries" do
        conn
        |> Plug.Conn.fetch_query_params
        |> get_entries
        |> respond
    end

    defp add_entry(conn) do
        conn.params["list"]
        |> Todo.Cache.server_process
        |> Todo.Server.add_entry(
            %{date: parse_date(conn.params["date"]), title: conn.params["title"]}
        )

        Plug.Conn.assign(conn, :response, "OK")
    end

    defp get_entries(conn) do
        entries = conn.params["list"]
        |> Todo.Cache.server_process
        |> Todo.Server.entries(parse_date(conn.params["date"]))
        |> concat_entries

        Plug.Conn.assign(conn, :response, entries)
    end

    defp parse_date(date_str) do
        {String.slice(date_str, 0..3), String.slice(date_str, 4..5), String.slice(date_str, 6..7)}
    end

    defp concat_entries(entries) do
        Enum.reduce(
            entries,
            "",
            fn(entry, acc) ->
                date_str = entry.date
                |> Tuple.to_list
                |> Enum.join("-")

                acc <> "\n" <> "#{date_str}\t#{entry.title}"
            end
        )
    end

    defp respond(conn) do
        conn
        |> Plug.Conn.put_resp_content_type("text/plain")
        |> Plug.Conn.send_resp(200, conn.assigns[:response])
    end
end
