use Mix.Config

alias Codebot.Domain.Worker

config :codebot,
    port: "8080",
    slack_token: System.get_env("SLACK_TOKEN"),
    nlp_module: Witai,
    intents: [
        {:hello, Codebot.Domain.Intent.HelloIntent},
        {:bye, Codebot.Domain.Intent.ByeIntent},
        {:noreply, Codebot.Domain.Intent.NoreplyIntent},
        {:create_task, Codebot.Domain.Intent.CreateTaskIntent}
    ]

config :witai, token: "RSO37RX6O2NT3NCQWYF5CET4IJENJFCO"

config :codebot, Worker,
    jobs: [
        {"1,30 8-17 * * *", &Worker.tell_joke/0 }
    ]

import_config "config.#{ Mix.env() }.exs"
