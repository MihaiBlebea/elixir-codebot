defmodule Codebot.Web.Response do

    defstruct token: nil, messages: nil

    @spec new(binary, list) :: %Codebot.Web.Response{}
    def new(token, messages) do
        %Codebot.Web.Response{
            token: token,
            messages: messages
        }
    end

    @spec encode(%Codebot.Web.Response{}) :: bitstring
    def encode(response) do
        resp = Map.drop(response, [:__struct__])
        r = Map.put(
            resp,
            "messages",
            Enum.map(
                resp.messages,
                fn (message)-> Codebot.Web.Message.encode(message) end)
        )
        case JSON.encode(r) do
            {:ok, body} -> body
            _ -> raise "Could not encode the response"
        end
    end
end
