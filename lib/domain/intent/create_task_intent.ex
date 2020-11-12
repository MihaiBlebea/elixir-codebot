defmodule Codebot.Domain.Intent.CreateTaskIntent do
    @intent "create_task"

    @entities [
        %{
            "name"=> "task_title",
            "roles"=> []
        },
        %{
            "name"=> "task_description",
            "roles"=> []
        }
    ]

    @utterances [
        %{
            "text" => "I want to create a new task get milk today",
            "entities" => [
                %{
                    "entity" => "task_title:task_title",
                    "body" => "get milk today",
                }
            ]
        },
        %{
            "text" => "Add this task talk with Simon",
            "entities" => [
                %{
                    "entity" => "task_title:task_title",
                    "body" => "talk with Simon",
                }
            ]
        },
        %{
            "text" => "Add task Complete database migration",
            "entities" => [
                %{
                    "entity" => "task_title:task_title",
                    "body" => "Complete database migration",
                }
            ]
        }
    ]

    use Codebot.Domain.Intent, intent: template()

    @spec execute(map) :: binary
    def execute(_params) do
        task = %{"title" => "This is a new task", "description" => "This is a description", "done" => false}
        Codebot.Adapter.TaskMock.store_task(task)

        "New task was created"
    end

    defp template() do
        %{"intent" => @intent, "entities" => @entities, "utterances" => @utterances}
    end
end
