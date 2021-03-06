defmodule Codebot.Adapter.Slack do
    require Logger

    @base_url "https://slack.com/api"

    @hook_url "https://hooks.slack.com/services"

    @spec send_msg(binary, binary) :: :ok
    def send_msg(text, channel) when is_binary(text) do
        req_body = JSON.encode!(%{"text" => text, "channel" => channel})
        url = "#{ @base_url }/chat.postMessage"

        {:ok, resp} = HTTPoison.post(url, req_body, get_default_headers())
        code = Map.fetch!(resp, :status_code)

        case code do
            200 -> :ok
            _ ->
                Logger.error("Request failed with code " <> to_string(code))
                raise "Request failed with code " <> to_string(code)
        end
    end

    @spec send_msg(binary) :: :ok
    def send_msg(text) when is_binary(text) do
        req_body = JSON.encode!(%{"text" => text})
        url = "#{ @hook_url }/#{ get_bot_token() }"

        {:ok, resp} = HTTPoison.post(url, req_body, get_default_headers())
        code = Map.fetch!(resp, :status_code)

        case code do
            200 -> :ok
            _ ->
                Logger.error("Request failed with code " <> to_string(code))
                raise "Request failed with code " <> to_string(code)
        end
    end

    @spec handle_message(map) :: binary
    def handle_message(%{"challenge" => chanllenge}) do
        chanllenge
    end

    def handle_message(%{"event" => event}) do
        %{"text" => text, "type" => type} = event
        case type do
            ev_type when ev_type in ["message", "app_mention"] ->
                text
                |> strip_mentions
                |> String.trim
            _ -> nil
        end
    end

    @spec handle_command(binary) :: map
    def handle_command(payload) do
        payload
        |> String.split("&")
        |> Enum.map(fn (data)->
            parts = String.split(data, "=")
            Map.put(
                %{},
                Enum.at(parts, 0),
                URI.decode(Enum.at(parts, 1))
            )
        end)
        |> Enum.reduce(fn elem, accum ->
            Map.merge(elem, accum)
        end)
    end

    defp get_default_headers() do
        ["Authorization": "Bearer #{ get_app_token() }", "Content-Type": "application/json"]
    end

    defp strip_mentions(message) do
        Regex.replace(~r/<@[A-Z0-9]*>/, message, "")
    end

    defp get_app_token() do
        System.get_env("SLACK_APP_TOKEN")
    end

    defp get_bot_token() do
        System.get_env("SLACK_BOT_TOKEN")
    end

    # def send_block() do
    #     payload =
    #         "./store/task_ui_block.json"
    #         |> File.read!
    #         |> JSON.decode!
    #         |> JSON.encode!

    #     url = "#{ @base_url }/#{ get_slack_token() }"

    #     {:ok, resp} = HTTPoison.post(url, payload, get_default_headers())

    #     IO.inspect resp
    # end
end
