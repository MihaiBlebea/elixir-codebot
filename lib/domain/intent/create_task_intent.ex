defmodule Codebot.Domain.Intent.CreateTaskIntent do
    # @behaviour Codebot.Domain.Intent.IExecuteIntent

    @intent "create_task"

    @entities []

    @utterances [
        %{
            "text" => "I want to create a new task",
            "intent" => @intent,
            "entities" => @entities,
            "traits" => []
        },
        %{
            "text" => "Add this task",
            "intent" => @intent,
            "entities" => @entities,
            "traits" => []
        },
        %{
            "text" => "Store this task",
            "intent" => @intent,
            "entities" => @entities,
            "traits" => []
        }
    ]

    use Codebot.Domain.Intent, intent: %{"intent" => @intent, "entities" => @entities, "utterances" => @utterances}

    @spec execute(map) :: binary
    def execute(_params) do
        task = %{"title" => "This is a new task", "description" => "This is a description", "done" => false}
        Codebot.Adapter.TaskMock.store_task(task)

        "New task was created"
    end
end
