defmodule Codebot.Web.Router do
    use Plug.Router

    plug Plug.Logger
    plug Plug.Static,
        at: "/public",
        from: "public"
    plug :match
    plug :dispatch

    get "test" do
        send_resp(conn, 200, "All working fine")
    end

    # get "/callback" do
    #     IO.inspect(Plug.Conn.fetch_query_params(conn).query_params)

    #     %{"hub.challenge" => challenge, "hub.mode" => mode, "hub.verify_token" => verify_token} = Plug.Conn.fetch_query_params(conn).query_params
    #     case mode == "subscribe" and verify_token == "mihaiblebea" do
    #         true -> send_resp(conn, 200, challenge)
    #         false -> send_resp(conn, 403, "Unauthorized")
    #     end
    # end
    get "/" do
        conn
        |> put_resp_header("content-type", "text/html; charset=utf-8")
        |> send_file(200, "./public/index.html")
    end

    post "/message" do
        {:ok, encoded_body, _} = Plug.Conn.read_body(conn)
        case JSON.decode(encoded_body) do
            {:ok, %{"message" => message}} -> send_resp(conn, 200, message)
            _ -> send_resp(conn, 500, "Server error")
        end
    end

    match _ do
        send_resp(conn, 404, "Route not found")
    end
end
