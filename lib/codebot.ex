defmodule Codebot do
    use Application

    @spec start(any, any) :: {:error, any} | {:ok, pid}
    def start(_type, _args) do
        port = Application.get_env(:codebot, :port)
        IO.puts "Application starting on port #{ to_string(port) }..."

        children = [
            Plug.Cowboy.child_spec(
                scheme: :http,
                plug: Codebot.Web.Router,
                options: [
                    dispatch: dispatch(),
                    port: port
                ]
            ),
            Registry.child_spec(
                keys: :duplicate,
                name: Registry.Codebot
            )
        ]

        Supervisor.start_link(children, strategy: :one_for_one)
    end

    defp dispatch do
        [
            {:_,
                [
                    {"/ws/[...]", Codebot.Web.Socket, []},
                    {:_, Plug.Cowboy.Handler, {Codebot.Web.Router, []}}
                ]
            }
        ]
    end
end
