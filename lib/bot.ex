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

    defp pick_intent({:create_journal, entities}) do
        IO.inspect entities

        has_entity(entities)
    end

    defp pick_intent({:list_journals, entities}) do
        IO.inspect entities

        messages =
            Codebot.Repository.connect
            |> Codebot.Repository.find_many(:journals, %{})
            |> IO.inspect
            |> Enum.map(fn (journal)->
                Codebot.Web.Message.new(Map.fetch!(journal, "subject"))
            end)

        Codebot.Web.Response.new(
            "token",
            messages
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

    defp has_entity(%{"subject" => subject}) do
        Codebot.Repository.insert_one(
            Codebot.Repository.connect(),
            :journals,
            Codebot.Model.Journal.new(
                subject,
                "",
                ""
            )
        )

        Codebot.Web.Response.new(
            "token",
            [
                Codebot.Web.Message.new("Added a new journal for you"),
                Codebot.Web.Message.new("With the subject..."),
                Codebot.Web.Message.new(subject),
                Codebot.Web.Message.new("Anything else that I can help you with?"),
            ]
        )
    end

    # defp has_entity(%{"description" => description}) do
    #     Codebot.Repository.connect()
    #     |> Codebot.Repository.update_one(
    #         :journals,
    #         %{"_id" => }
    #     )

    #     Codebot.Web.Response.new(
    #         "token",
    #         [
    #             Codebot.Web.Message.new("Added a new journal for you"),
    #             Codebot.Web.Message.new("With the subject..."),
    #             Codebot.Web.Message.new(subject),
    #             Codebot.Web.Message.new("Anything else that I can help you with?"),
    #         ]
    #     )
    # end
end
