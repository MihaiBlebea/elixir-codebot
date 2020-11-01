defmodule Mix.Tasks.DeployIntents do
    use Mix.Task

    alias Codebot.Adapter.Witai, as: Witai

    @shortdoc "Deploy the intents to Witai using the API"
    @spec run(any) :: none
    def run(_) do
        Mix.Task.run("app.start")

        # Witai.create_intent("create_task")
        # foo = Witai.create_entity(%{
        #     "name" => "foo_bar",
        #     "roles" => [],
        #     "lookups" => [
        #         "free-text"
        #     ]
        # })
        # IO.inspect foo
        Witai.create_utterances([
            %{
                "text" => "I want to buy a bread",
                "intent" => "create_task",
                "entities" => [
                    %{
                        "entity" => "foo_bar:foo_bar",
                        "start" => 14,
                        "end" => 21,
                        "body" => "a bread",
                        "entities" => []
                    }
                ],
                "traits" => []
            }
        ])
    end
end
