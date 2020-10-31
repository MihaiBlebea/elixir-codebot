defmodule Codebot.Intent.HelloIntent do
    @behaviour Codebot.Intent.IExecuteIntent

    def execute(_params) do
        get_messages()
        |> pick_message
    end

    defp get_messages() do
        [
            "Hey! How are you buddy?",
            "What's new?",
            "How are you today?",
            "All good?"
        ]
    end

    defp pick_message(messages) do
        messages
        |> Enum.take_random(1)
        |> Enum.at(0)
    end
end
