defmodule Codebot.Bot do

    @base_url "https://api.wit.ai/message?v=20201023&q="

    @token "RSO37RX6O2NT3NCQWYF5CET4IJENJFCO"

    def query(term) do
        url = @base_url <> URI.encode(term)
        headers = ["Authorization": "Bearer #{ @token }", "Content-Type": "application/json"]
        %HTTPoison.Response{body: body, status_code: code} = HTTPoison.get!(url, headers, follow_redirect: true)

        {body, code}
        |> IO.inspect
        |> decode_body
        |> process_intent
    end

    defp decode_body({body, 200}) do
        case JSON.decode body do
            {:ok, body} -> body
            _ -> raise "Something bad happens"
        end
    end

    defp decode_body({_body, _code}) do
        raise "Something bad happens"
    end

    def process_intent(body) do
        %{"entities" => entities, "intents" => intents, "text" => _text, "traits" => %{}} = body

        intents
        |> Enum.filter(fn (%{"id" => _, "name" => _name, "confidence" => confidence})-> confidence > 0.5 end)
        |> Enum.at(0)
        |> to_atom
        |> pick_intent(entities)
    end

    def to_atom(%{"id" => _, "name" => name, "confidence" => _}) do
        String.to_existing_atom(name)
    end

    def to_atom(nil) do
        raise "No valid intent found"
    end

    def pick_intent(:hello, _entities) do
        select_response([
            "Hey! How are you buddy?",
            "What's new?",
            "How are you today?",
            "All good?"
        ])
    end

    def pick_intent(:bye, _entities) do
        select_response([
            "See you soon",
            "Take care",
            "Glad I could help",
            "Have a good day"
        ])
    end

    def pick_intent(:search, entities) do

        response = Codebot.Intent.SearchIntent.get_response(entities)
        # Codebot.Web.Response.newMessage(
        #     "This is all I could find",
        #     :card,
        #     "https://images.unsplash.com/photo-1525609004556-c46c7d6cf023?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=800&q=60",
        #     "article title",
        #     "article description here",
        #     "https://www.google.com"
        # )

        Codebot.Web.Response.newMessage(
            "Here is the response",
            :list,
            response.base_link,
            response.list
        )
    end

    def pick_intent(_anything) do
        "Could not get that sorry"
    end

    def select_response(list) do
        list
        |> Enum.take_random(1)
        |> Enum.at(0)
        |> Codebot.Web.Response.newMessage(:message)
    end
end
