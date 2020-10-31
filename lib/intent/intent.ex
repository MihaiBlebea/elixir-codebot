defmodule Codebot.Intent do

    @spec pick({:hello, any}) :: binary
    def pick({:noreply, _params }) do
        Codebot.Intent.NoreplyIntent.execute(%{})
    end

    def pick({:hello, _params }) do
        Codebot.Intent.HelloIntent.execute(%{})
    end

    def pick({:bye, _params }) do
        Codebot.Intent.ByeIntent.execute(%{})
    end
end
