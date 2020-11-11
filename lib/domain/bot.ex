defmodule Codebot.Bot do

    alias Codebot.Domain.Intent

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

    defp handle_context({_intent, props} = payload, context_id) do
        Codebot.Domain.Context.start_link(context_id)

        props
        |> Map.keys
        |> IO.inspect
        |> Enum.map(fn (key)->
            value = Map.fetch!(props, key)
            Codebot.Domain.Context.put(context_id, key, value)
        end)

        payload
    end
end
