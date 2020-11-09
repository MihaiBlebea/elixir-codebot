defmodule Codebot.Web.Router do
    use Plug.Router
    require Logger

    alias Codebot.Adapter.Slack

    # plug CORSPlug, origin: ["http://localhost:8080"]
    plug Plug.Logger
    plug Plug.Static,
        at: "/",
        from: "./doc"
    plug :match
    plug :dispatch

    get "test" do
        send_resp(conn, 200, "All working fine")
    end

    get "/docs" do
        conn
        |> put_resp_header("content-type", "text/html; charset=utf-8")
        |> send_file(200, "./doc/index.html")
    end

    post "/slack" do
        {:ok, request, _} = Plug.Conn.read_body(conn)

        request
        |> JSON.decode!
        |> handleSlackMessage
        |> Codebot.Bot.query
        |> Slack.send_msg

        send_resp(conn, 200, [])
    end

    post "/slack/command" do
        {:ok, request, _} = Plug.Conn.read_body(conn)

        request
        |> Slack.handle_command

        send_resp(conn, 200, [])
    end

    match _ do
        send_resp(conn, 404, "Route not found")
    end

    defp handleSlackMessage(%{"challenge" => challenge}) do
        send_resp(conn, 200, challenge)
    end

    defp handleSlackMessage(%{"event" => _event} = body) do
        Slack.handle_message(body)
    end
end
