use Mix.Config

config :mongodb_driver,
    host: "localhost"

config :codebot,
    port: 3001,
    slack_token: "T01ECUVCAMN/B01ED2FCHJL/yWVRxJ8MGo0cyEXJD8BXqBxM",
    mongo_url: "mongodb://localhost:27015/",
    mongo_db: "codebot-v1",
    nlp_module: Witai

config :witai, token: "RSO37RX6O2NT3NCQWYF5CET4IJENJFCO"
