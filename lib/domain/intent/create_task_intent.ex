defmodule Codebot.Domain.Intent.CreateTaskIntent do

    alias Codebot.Adapter.TaskRepository

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

    use Codebot.Domain.Intent, intent: %{"intent" => @intent, "entities" => @entities, "utterances" => @utterances}

    @spec execute(map) :: binary
    def execute(params) do
        %{ "task_title" => task_title } = params

        case TaskRepository.add_task(%{"title" => task_title}) do
            :fail -> "I tried to create this task but something went wrong"
            _ -> "I have created the task for you"
        end
    end
end
