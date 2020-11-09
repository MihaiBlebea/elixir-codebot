use Mix.Config

alias Codebot.Domain.Worker

config :mongodb_driver,
    host: "localhost"

config :codebot,
    # port: System.get_env("HTTP_PORT"),
    port: "8080",
    slack_token: System.get_env("SLACK_TOKEN"),
    mongo_url: "mongodb://localhost:27015/",
    mongo_db: "codebot-v1",
    nlp_module: Witai

config :witai, token: "RSO37RX6O2NT3NCQWYF5CET4IJENJFCO"

config :codebot, Worker,
    jobs: [
        {"1,30 8-17 * * *", &Worker.tell_joke/0 }
    ]

import_config "config.#{ Mix.env() }.exs"
