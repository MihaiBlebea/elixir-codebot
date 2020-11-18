use Mix.Config

alias Codebot.Domain.Worker

config :codebot,
    port: "8080",
    # slack_token: "xoxb-1488981418736-1474758082119-iFuy2LcNDFH3Ik6mByH2diTN",
    nlp_module: Witai,
    intents: [
        {:hello, Codebot.Domain.Intent.HelloIntent},
        {:bye, Codebot.Domain.Intent.ByeIntent},
        {:create_task, Codebot.Domain.Intent.CreateTaskIntent},
        {:list_tasks, Codebot.Domain.Intent.ListTasksIntent},
        {:complete_task, Codebot.Domain.Intent.CompleteTaskIntent}
    ]

config :codebot,
    mysql_user: "root",
    mysql_password: "root",
    mysql_root: "root",
    mysql_host: "srv-captain--platform-db-db",
    mysql_port: 3306,
    mysql_database: "codebot"

config :witai, token: "RSO37RX6O2NT3NCQWYF5CET4IJENJFCO"

# config :codebot, Worker,
#     jobs: [
#         {"1,30 8-17 * * *", &Worker.tell_joke/0 },
#         {"0 8-17/1 * * *", &Worker.list_tasks/0 }
#     ]

import_config "config.#{ Mix.env() }.exs"
