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

        resp =
            request
            |> JSON.decode!
            |> IO.inspect
            |> handleSlackMessage

        send_resp(conn, 200, resp)
    end

    post "/slack/command" do
        {:ok, request, _} = Plug.Conn.read_body(conn)

        request
        |> Slack.handle_command

        send_resp(conn, 200, [])
    end

    post "/slack/interactive" do
        {:ok, request, _} = Plug.Conn.read_body(conn)

        content =
            request
            |> String.replace("payload=", "")
            |> URI.decode
            |> JSON.decode!
            # |> IO.inspect

        File.write!("./store/test.json", JSON.encode!(content))

        send_resp(conn, 200, [])
    end

    match _ do
        send_resp(conn, 404, "Route not found")
    end

    defp handleSlackMessage(%{"challenge" => _challenge} = body) do
        Slack.handle_message(body)
    end

    defp handleSlackMessage(%{"event" => %{"bot_id" => _bot_id, "bot_profile" => _bot_profile}}) do
        []
    end

    defp handleSlackMessage(%{"event" => event} = body) do
        %{"user" => user_id, "channel" => channel} = event

        body
        |> Slack.handle_message
        |> log
        |> Codebot.Bot.query(user_id)
        |> log
        |> Slack.send_msg(channel)

        []
    end

    defp log(body) do
        body |> inspect |> Logger.debug

        body
    end
end
