defmodule Codebot.Model.Mod do
    defstruct _id: nil, name: nil, url: nil, description: nil

    @spec new(binary, binary, binary) :: %Codebot.Model.Mod{}
    def new(name, url, description) do
        %Codebot.Model.Mod{
            _id: Mongo.object_id,
            name: name,
            url: url,
            description: description
        }
    end
end
