defmodule Codebot.Model.Journal do

    @spec new(binary, binary, binary) :: %{}
    def new(subject, details, expire) do
        %{
            _id: Mongo.object_id(),
            subject: subject,
            details: details,
            expire: expire
        }
    end
end
