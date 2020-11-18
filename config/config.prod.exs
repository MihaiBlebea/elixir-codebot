use Mix.Config

alias Codebot.Domain.Worker

config :codebot,
    mysql_user: "root",
    mysql_password: "root",
    mysql_root: "root",
    mysql_host: "srv-captain--platform-db-db",
    mysql_port: 3306,
    mysql_database: "codebot"

config :codebot, Worker,
    jobs: [
        {"1,30 8-17 * * *", &Worker.tell_joke/0 },
        {"0 8-17/1 * * *", &Worker.list_tasks/0 }
    ]
