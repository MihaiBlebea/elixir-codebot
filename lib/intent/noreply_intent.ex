defmodule Codebot.Intent.NoreplyIntent do
    @behaviour Codebot.Intent.IExecuteIntent

    def execute(_params) do
        get_messages()
        |> pick_message
    end

    defp get_messages() do
        [
            "Sorry! Could not get that. Can you say that again?",
            "Sorry. Again?",
            "What was that?",
            "I beg your pardon"
        ]
    end

    defp pick_message(messages) do
        messages
        |> Enum.take_random(1)
        |> Enum.at(0)
    end
end
