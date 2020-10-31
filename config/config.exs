use Mix.Config

config :mongodb_driver,
    host: "localhost"

config :codebot,
    port: 3001,
    witai_token: "RSO37RX6O2NT3NCQWYF5CET4IJENJFCO",
    slack_token: "T01ECUVCAMN/B01ED2FCHJL/yWVRxJ8MGo0cyEXJD8BXqBxM",
    mongo_url: "mongodb://localhost:27015/",
    mongo_db: "codebot-v1",
    nlp_module: Codebot.Adapter.Witai

import_config "config.#{ Mix.env() }.exs"
