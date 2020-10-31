defmodule Codebot.Bot do

    @spec query(binary) :: binary
    def query(term) do
        term
        |> get_nlp_module().message
        |> Codebot.Intent.pick
    end

    defp get_nlp_module() do
        Application.fetch_env!(:codebot, :nlp_module)
    end
end
