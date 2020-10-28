defmodule Codebot.Web.Message do
    defstruct text: nil, created: nil

    @spec new(binary) :: %Codebot.Web.Message{}
    def new(text) do
        {:ok, date_time} = DateTime.now("Etc/UTC")
        %Codebot.Web.Message{
            text: text,
            created: date_time
        }
    end

    @spec encode(%Codebot.Web.Message{}) :: map
    def encode(message) do
        message
        |> Map.drop([:__struct__])
        |> Map.put("created", DateTime.to_string(message.created))
    end
end
