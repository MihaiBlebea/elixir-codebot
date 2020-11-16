defmodule Codebot.Domain.Intent.ByeIntent do
    @intent "bye"

    @entities []

    @utterances [
        %{
            "text" => "Bye bye"
        },
        %{
            "text" => "Bye"
        },
        %{
            "text" => "See you later"
        },
        %{
            "text" => "Nighr"
        },
        %{
            "text" => "Laters"
        },
        %{
            "text" => "Bye bot"
        }
    ]

    use Codebot.Domain.Intent, intent: %{"intent" => @intent, "entities" => @entities, "utterances" => @utterances}

    @spec execute(map) :: binary
    def execute(_params) do
        get_messages()
        |> pick_message
    end

    defp get_messages() do
        [
            "See you soon",
            "Take care",
            "Glad I could help",
            "Have a good day"
        ]
    end

    defp pick_message(messages) do
        messages
        |> Enum.take_random(1)
        |> Enum.at(0)
    end
end
