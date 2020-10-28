defmodule Codebot.Bot do

    @spec query(binary) :: %Codebot.Web.Response{}
    def query(term) do
        term
        |> Codebot.Witai.message
        |> pick_intent
    end

    defp pick_intent({:hello, _entities}) do
        msg = select_random_message([
            "Hey! How are you buddy?",
            "What's new?",
            "How are you today?",
            "All good?"
        ])

        Codebot.Web.Response.new(
            "token",
            [
                Codebot.Web.Message.new(msg),
                Codebot.Web.Message.new("How can I help you today?"),
            ]
        )
    end

    defp pick_intent({:bye, _entities}) do
        msg = select_random_message([
            "See you soon",
            "Take care",
            "Glad I could help",
            "Have a good day"
        ])

        Codebot.Web.Response.new(
            "token",
            [
                Codebot.Web.Message.new(msg)
            ]
        )
    end

    defp pick_intent({:search, entities}) do
        IO.inspect entities
        # _response = Codebot.Intent.SearchIntent.get_response(entities)

        Codebot.Web.Response.new(
            "token",
            [
                Codebot.Web.Message.new("I am looking for some functions for you"),
                Codebot.Web.Message.new("How about this one?"),
                Codebot.Web.Message.new("String.split/1"),
                Codebot.Web.Message.new("Seems like a good piece of code"),
                Codebot.Web.Message.new("Can I help you with something more?")
            ]
        )
    end

    defp pick_intent(_anything) do
        Codebot.Web.Response.new(
            "token",
            [
                "Could not get that sorry"
            ]
        )
    end

    defp select_random_message(msg_list) do
        msg_list
        |> Enum.take_random(1)
        |> Enum.at(0)
    end
end
