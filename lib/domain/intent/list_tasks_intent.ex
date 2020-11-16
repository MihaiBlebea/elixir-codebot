defmodule Codebot.Domain.Intent.ListTasksIntent do

    alias Codebot.Adapter.TaskRepository

    @intent "list_tasks"

    @entities []

    @utterances [
        %{
            "text" => "Show me all the tasks for today"
        },
        %{
            "text" => "Let me see the tasks for today"
        },
        %{
            "text" => "What tasks do we have for today?"
        },
        %{
            "text" => "What is the plan for today?"
        },
        %{
            "text" => "What are we doing today?"
        },
        %{
            "text" => "Any tasks for today?"
        }
    ]

    use Codebot.Domain.Intent, intent: %{"intent" => @intent, "entities" => @entities, "utterances" => @utterances}

    def execute(_params) do
        case TaskRepository.find_today_tasks() do
            :fail -> ":face_palm: Sorry I just had an issue with the database"
            tasks -> ":arrow_down: Here are your tasks for today :arrow_down: \n\n #{ build_options(tasks) }"
        end
    end

    def build_options(tasks, options \\ [], index \\ 0) do
        case Enum.at(tasks, index, nil) do
            nil -> options
            %{"id" => id, "title"=> title, "description" => description, "completed" => completed} ->
                IO.inspect completed
                build_options(
                    tasks,
                    options ++ [build_option(id, title, description, completed)],
                    index + 1
                )
        end
    end

    @spec build_option(integer, binary, boolean, integer) :: binary
    def build_option(id, title, _description, completed) do
        "#{ is_completed?(completed) } #{ title } - `#{ id }` \n\n"
    end

    @spec is_completed?(boolean) :: binary
    def is_completed?(true) do
        ":white_check_mark:"
    end

    def is_completed?(false) do
        ":point_right:"
    end
end
