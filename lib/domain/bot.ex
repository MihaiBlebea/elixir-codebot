defmodule Codebot.Bot do

    alias Codebot.Domain.Intent

    alias Codebot.Domain.Context

    @spec query(binary, binary) :: binary
    def query(term, context_id) do
        term
        |> get_client().message
        |> handle_context(context_id)
        |> Intent.pick
    end

    defp get_client() do
        Application.fetch_env!(:codebot, :nlp_module)
    end

    defp handle_context({intent, props} = payload, context_id) do
        Context.start_link(context_id)
        Context.update_intent(context_id, intent)
        Context.put(context_id, :props, props)

        payload
    end
end
