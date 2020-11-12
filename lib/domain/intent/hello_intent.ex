defmodule Codebot.Domain.Intent.HelloIntent do
    @intent "hello"

    @entities []

    @utterances [
        %{
            "text" => "Hey",
            "intent" => @intent,
            "entities" => @entities,
            "traits" => []
        },
        %{
            "text" => "Hey hey",
            "intent" => @intent,
            "entities" => @entities,
            "traits" => []
        },
        %{
            "text" => "Hello",
            "intent" => @intent,
            "entities" => @entities,
            "traits" => []
        },
        %{
            "text" => "Good morning",
            "intent" => @intent,
            "entities" => @entities,
            "traits" => []
        },
        %{
            "text" => "Morning",
            "intent" => @intent,
            "entities" => @entities,
            "traits" => []
        },
        %{
            "text" => "How are you?",
            "intent" => @intent,
            "entities" => @entities,
            "traits" => []
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
