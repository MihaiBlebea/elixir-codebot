defmodule Codebot.Domain.Intent.CompleteTaskIntent do

    alias Codebot.Adapter.TaskRepository

    @intent "complete_task"

    @entities [
        %{
            "name"=> "task_id",
            "roles"=> []
        },
    ]

    @utterances [
        %{
            "text" => "Complete the task 1234",
            "entities" => [
                %{
                    "entity" => "task_id:task_id",
                    "body" => "1234",
                }
            ]
        },
        %{
            "text" => "Mark task 12345 as completed",
            "entities" => [
                %{
                    "entity" => "task_id:task_id",
                    "body" => "12345",
                }
            ]
        },
        %{
            "text" => "Complete 123456",
            "entities" => [
                %{
                    "entity" => "task_id:task_id",
                    "body" => "123456",
                }
            ]
        }
    ]

    use Codebot.Domain.Intent, intent: %{"intent" => @intent, "entities" => @entities, "utterances" => @utterances}

    @spec execute(map) :: binary
    def execute(params) do
        %{ "task_id" => id } = params

        id
        |> String.to_integer
        |> TaskRepository.find_by_id
        |> Map.fetch!("id")
        |> TaskRepository.complete_task()

        ":white_check_mark: Completed task #{ id }"
    end
end
