defmodule Codebot.Domain.Intent do
    use Agent

    @agent_name :intent_agent

    @spec __using__(any) :: any
    defmacro __using__(args) do
        quote do
            @behaviour Codebot.Domain.Intent.IExecuteIntent

            def deploy() do
                [intent: intent] = unquote(args)

                intent
                |> deploy(:intent)
                |> deploy(:entity)
                |> deploy(:utterance)
            end

            defp deploy(template, :intent) do
                template
                |> Map.fetch!("intent")
                |> deploy_intents

                template
            end

            defp deploy(template, :entity) do
                template
                |> Map.fetch!("entities")
                |> Enum.map(fn (entity)-> Witai.create_entity(entity) end)
                |> IO.inspect

                template
            end

            defp deploy(template, :utterance) do
                template
                |> Map.fetch!("utterances")
                |> Witai.create_utterances
                |> IO.inspect

                template
            end

            defp deploy_intents(list) when is_list(list) do
                list |> Enum.map(fn (intent_name)-> Witai.create_intent(intent_name) end)
            end

            defp deploy_intents(intent) when is_binary(intent) do
                Witai.create_intent(intent)
            end

            def drop() do
                [intent: intent] = unquote(args)

                intent
                |> drop(:intent)
                |> drop(:entity)
                |> drop(:utterance)
            end

            defp drop(template, :intent) do
                template
                |> Map.fetch!("intent")
                |> drop_intents

                template
            end

            defp drop(template, :entity) do
                template
                |> Map.fetch!("entities")
                |> Enum.map(fn (entity)-> Map.fetch!(entity, "name") |> Witai.delete_entity end)
                |> IO.inspect

                template
            end

            defp drop(template, :utterance) do
                template
                |> Map.fetch!("utterances")
                |> Enum.map(fn (utterance)-> Map.fetch!(utterance, "text") end)
                |> Witai.delete_utterances
                |> IO.inspect

                template
            end

            defp drop_intents(list) when is_list(list) do
                list |> Enum.map(fn (intent_name)-> Witai.delete_intent(intent_name) end)
            end

            defp drop_intents(intent) when is_binary(intent) do
                Witai.delete_intent(intent)
            end
        end
    end

    @spec start_link(list) :: {:error, any} | {:ok, pid}
    def start_link(intents) do
        Agent.start_link(fn ()-> intents end, [name: @agent_name])
    end

    @spec lookup(atom | pid, atom) :: any
    def lookup(pid, intent) do
        Agent.get(pid, fn (state)->
            Enum.filter(state, fn (itnt)->
                {atom, _module} = itnt
                atom === intent
            end) |> Enum.at(0, nil)
        end)
    end

    @spec pick({atom, map}) :: any
    def pick({intent, props}) do
        {_intent, module} = lookup(@agent_name, intent)

        module.execute(props)
    end
end
