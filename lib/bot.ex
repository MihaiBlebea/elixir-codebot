defmodule Codebot.Bot do

    @spec query(binary) :: binary
    def query(term) do
        term
        |> Codebot.Witai.message
        |> pick_intent
    end

    defp pick_intent({:noreply, _entities}) do
        select_random_message([
            "Sorry! Could not get that. Can you say that again?",
            "Sorry. Again?",
            "What was that?",
            "I beg your pardon"
        ])
    end

    defp pick_intent({:hello, _entities}) do
        select_random_message([
            "Hey! How are you buddy?",
            "What's new?",
            "How are you today?",
            "All good?"
        ])
    end

    defp pick_intent({:bye, _entities}) do
        select_random_message([
            "See you soon",
            "Take care",
            "Glad I could help",
            "Have a good day"
        ])
    end

    defp pick_intent(_anything) do
        select_random_message([
            "Sorry! Could not get that. Can you say that again?",
            "Sorry. Again?",
            "What was that?",
            "I beg your pardon"
        ])
    end

    defp select_random_message(msg_list) do
        msg_list
        |> Enum.take_random(1)
        |> Enum.at(0)
    end
end
