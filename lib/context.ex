defmodule Codebot.Context do

    defstruct name: nil, props: nil

    @spec new(map, atom) :: %Codebot.Context{}
    def new(props, :create_journal) do
        %Codebot.Context{
            name: :create_journal,
            props: props
        }
    end
end
