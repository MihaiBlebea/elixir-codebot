defmodule Codebot.Web.Router do
    use Plug.Router
    require Logger

    # plug CORSPlug, origin: ["http://localhost:8080"]
    plug Plug.Logger
    plug Plug.Static,
        at: "/static",
        from: "./front/dist/static"
    plug Plug.Static,
        at: "/",
        from: "./doc"
    plug :match
    plug :dispatch

    get "test" do
        send_resp(conn, 200, "All working fine")
    end

    get "/" do
        conn
        |> put_resp_header("content-type", "text/html; charset=utf-8")
        |> send_file(200, "./front/dist/index.html")
    end

    get "/docs" do
        conn
        |> put_resp_header("content-type", "text/html; charset=utf-8")
        |> send_file(200, "./doc/index.html")
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

    post "/slack" do
        {:ok, request, _} = Plug.Conn.read_body(conn)

        request
        |> decode_request
        |> Codebot.Slack.handle_message
        |> Codebot.Bot.query
        |> Codebot.Slack.send_msg

        send_response(conn, 200)
    end

    post "/slack/command" do
        {:ok, request, _} = Plug.Conn.read_body(conn)

        request
        |> IO.inspect
        |> Codebot.Slack.handle_command
        |> IO.inspect
        # |> Codebot.Slack.handle_call
        # |> Codebot.Bot.query
        # |> Codebot.Slack.send_msg

        send_response(conn, 200)
    end

    match _ do
        send_resp(conn, 404, "Route not found")
    end

    defp decode_request(request) do
        case JSON.decode(request) do
            {:ok, body} -> body
            _ -> raise "Could not decode the request body"
        end
    end

    defp send_response(resp, conn, 200) when is_binary(resp) do
        send_resp(conn, 200, resp)
    end

    defp send_response(resp, conn, 200) when is_map(resp) do
        send_resp(conn, 200, encode_response(resp))
    end

    defp send_response(err, conn, 500) do
        IO.inspect err
        Logger.error(err)
        send_resp(conn, 500, "Server error")
    end

    defp send_response(conn, 200) do
        send_resp(conn, 200, [])
    end

    def encode_response(response) when is_map(response) do
        case JSON.encode(response) do
            {:ok, body} -> body
            _ -> raise "Could not encode the response"
        end
    end
end
