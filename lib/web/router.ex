defmodule Codebot.Web.Router do
    use Plug.Router
    require Logger

    plug CORSPlug, origin: ["http://localhost:8080"]
    plug Plug.Logger
    plug Plug.Static,
        at: "/public",
        from: "public"
    plug :match
    plug :dispatch

    get "test" do
        send_resp(conn, 200, "All working fine")
    end

    get "/" do
        conn
        |> put_resp_header("content-type", "text/html; charset=utf-8")
        |> send_file(200, "./public/index.html")
    end

    post "/message" do
        try do
            {:ok, request, _} = Plug.Conn.read_body(conn)

            request
            |> decode_request
            |> Codebot.Bot.query
            |> IO.inspect
            |> send_response(conn, 200)
        rescue
            err -> send_response(err, conn, 500)
        end
    end

    match _ do
        send_resp(conn, 404, "Route not found")
    end

    defp decode_request(request) do
        case JSON.decode(request) do
            {:ok, %{"message" => message}} -> message
            _ -> raise "Could not decode the request body"
        end
    end


    defp send_response(resp, conn, 200) do
        send_resp(
            conn,
            200,
            Codebot.Web.Response.encode(resp)
        )
    end

    defp send_response(err, conn, 500) do
        IO.inspect err
        Logger.error("Something bad happened")
        send_resp(conn, 500, "Server error")
    end
end
