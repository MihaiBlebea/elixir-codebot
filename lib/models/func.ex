defmodule Codebot.Model.Func do

    defstruct _id: nil, name: nil, url: nil, description: nil

    @spec new(binary, binary, binary) :: %Codebot.Model.Func{}
    def new(name, url, description) do
        %Codebot.Model.Func{
            _id: BSON.ObjectId.new(1, 1, 1, 1),
            name: name,
            url: url,
            description: description
        }
    end
end
