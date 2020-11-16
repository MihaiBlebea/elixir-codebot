defmodule Codebot do
    use Application

    require Logger

    @spec start(any, any) :: {:error, any} | {:ok, pid}
    def start(_type, _args) do
        port =
            Application.get_env(:codebot, :port)
            |> String.to_integer()

        IO.puts "Application starting on port #{ to_string(port) }..."

        Application.get_all_env(:codebot)
        |> inspect
        |> Logger.debug

        children = [
            {Plug.Cowboy, scheme: :http, plug: Codebot.Web.Router, options: [port: port]},
            Codebot.Domain.Worker,
            {Registry, [keys: :unique, name: :context_registry]},
            %{
                id: Codebot.Domain.Intent,
                start: {Codebot.Domain.Intent, :start_link, [Application.get_env(:codebot, :intents)]}
            },
            {
                MyXQL,
                username: Application.get_env(:codebot, :mysql_user),
                password: Application.get_env(:codebot, :mysql_password),
                hostname: Application.get_env(:codebot, :mysql_host),
                port: Application.get_env(:codebot, :mysql_port),
                database: Application.get_env(:codebot, :mysql_database),
                name: :codebot_db
            }
        ]

        supervisor = Supervisor.start_link(children, strategy: :one_for_one)

        migrate_db()

        supervisor
    end

    defp migrate_db() do
        Codebot.Adapter.TaskRepository.create_table
    end
end
