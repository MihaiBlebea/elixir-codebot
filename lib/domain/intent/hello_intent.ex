defmodule Codebot.Domain.Intent.HelloIntent do
    @intent "hello"

    @entities []

    @utterances [
        %{
            "text" => "Hey"
        },
        %{
            "text" => "Hey hey"
        },
        %{
            "text" => "Hello"
        },
        %{
            "text" => "Good morning"
        },
        %{
            "text" => "Morning"
        },
        %{
            "text" => "How are you?"
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
