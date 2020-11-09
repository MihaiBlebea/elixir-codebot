defmodule Codebot.Domain.Intent.ListTasksIntent do
    @behaviour Codebot.Domain.Intent.IExecuteIntent

    def execute(_params) do
        # Pick tasks from database for today
        # Transform the data coming from db into the format required by slack
        # If the task is completed, add the task to the initial_options array
        # return the map to slack module to send
    end

    defp build_option_map() do
        %{
            "text" => %{
                "type" => "mrkdwn",
                "text" => "*this is mrkdwn text*"
            },
            "description" => %{
                "type" => "mrkdwn",
                "text" => "*this is mrkdwn text*"
            },
            "value" => "value-1"
        }
    end

    defp build_response_map() do
        %{
            "blocks" => [
                %{
                    "type" => "section",
                    "text" => %{
                        "type" => "plain_text",
                        "text" => "Here are your tasks for the day",
                        "emoji" => true
                    }
                },
                %{
                    "type" => "actions",
                    "elements" => [
                        %{
                            "type" => "checkboxes",
                            "options" => [],
                            "initial_options" => [],
                            "action_id" => "actionId-1"
                        }
                    ]
                }
            ]
        }
    end
end
