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
                |> build(:utterance)
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

            defp build(template, :utterance) do
                intent_name = Map.fetch!(template, "intent")
                utterances =
                    template
                    |> Map.fetch!("utterances")
                    |> Enum.map(fn (utterance)->
                        case Map.has_key?(utterance, "entities") do
                            true -> add_entity_missing_param(utterance)
                            false -> Map.put(utterance, "entities", [])
                        end
                    end)
                    |> Enum.map(fn (utterance)-> Map.merge(utterance, %{"traits" => [], "intent" => intent_name}) end)

                Map.put(template, "utterances", utterances)
            end

            defp entity_start_index(utterance, entity) when is_binary(utterance) and is_binary(entity) do
                case String.split(utterance, entity, parts: 2) do
                    [left, _] -> String.length(left)
                    [_] -> nil
                end
            end

            defp entity_end_index(utterance, entity) when is_binary(utterance) and is_binary(entity) do
                case entity_start_index(utterance, entity) do
                    nil -> nil
                    start_index -> start_index + String.length(entity)
                end
            end

            defp add_entity_missing_param(utterance) do
                utterance_body = Map.fetch!(utterance, "text")
                entities =
                    Map.fetch!(utterance, "entities")
                    |> Enum.map(fn (entity)->
                        entity_body = Map.fetch!(entity, "body")
                        Map.merge(entity, %{
                            "start" => entity_start_index(utterance_body, entity_body),
                            "end" => entity_end_index(utterance_body, entity_body),
                            "entities" => []
                        })
                    end)

                Map.put(utterance, "entities", entities)
            end


            def drop() do
                [intent: intent] = unquote(args)

                intent
                |> drop(:intent)
                |> drop(:entity)
                |> strip(:utterance)
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
                # |> IO.inspect

                template
            end

            defp drop(template, :utterance) do
                template
                |> Map.fetch!("utterances")
                |> Witai.delete_utterances
                # |> IO.inspect

                template
            end

            defp drop_intents(list) when is_list(list) do
                list |> Enum.map(fn (intent_name)-> Witai.delete_intent(intent_name) end)
            end

            defp drop_intents(intent) when is_binary(intent) do
                Witai.delete_intent(intent)
            end

            defp strip(template, :utterance) do
                stripped =
                    template
                    |> Map.fetch!("utterances")
                    |> Enum.map(fn (utterance)-> Map.drop(utterance, ["entities"]) end)
                    # |> IO.inspect

                Map.put(template, "utterances", stripped)
            end
        end
    end

    @spec start_link(list) :: {:error, any} | {:ok, pid}
    def start_link(intents) do
        Agent.start_link(fn ()-> intents end, [name: @agent_name])
    end

    @spec lookup(atom) :: any
    def lookup(intent) do
        Agent.get(@agent_name, fn (state)->
            Enum.filter(state, fn (itnt)->
                {atom, _module} = itnt
                atom === intent
            end) |> Enum.at(0, nil)
        end)
    end

    @spec pick({:no_intent, map}) :: any
    def pick({:no_intent, props}) do
        "I did not understand that last one :hear_no_evil:..."
    end

    @spec pick({atom, map}) :: any
    def pick({intent, props}) do
        {_intent, module} = lookup(intent)

        module.execute(props)
    end

    @spec deploy_all :: any
    def deploy_all() do
        Agent.get(@agent_name, fn (state)-> state end)
        |> Enum.map(fn (intent)->
            {_atom, module} = intent
            module.deploy()
        end)
    end

    @spec destroy_all :: any
    def destroy_all() do
        Agent.get(@agent_name, fn (state)-> state end)
        |> Enum.map(fn (intent)->
            {_atom, module} = intent
            module.destroy()
        end)
    end
end
