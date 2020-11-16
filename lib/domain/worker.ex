defmodule Codebot.Domain.Worker do
    use Quantum, otp_app: :codebot

    alias Codebot.Domain.Intent.ListTasksIntent

    alias Codebot.Adapter.Slack

    def tell_joke() do
        {:ok, %{body: body}} = HTTPoison.get("https://sv443.net/jokeapi/v2/joke/Any")

        content = JSON.decode!(body)
        cond do
            Map.fetch!(content, "type") == "twopart" ->
                Slack.send_msg Map.fetch!(content, "setup")
                :timer.sleep 5000
                Slack.send_msg Map.fetch!(content, "delivery")
            Map.fetch!(content, "type") == "single" ->
                Slack.send_msg Map.fetch!(content, "joke")
            true -> nil
        end
    end

    @spec list_tasks :: nil
    def list_tasks() do
        ListTasksIntent.execute([]) |> Slack.send_msg

        nil
    end
end
