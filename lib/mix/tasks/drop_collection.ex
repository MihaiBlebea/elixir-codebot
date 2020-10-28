defmodule Mix.Tasks.DropCollection do
    use Mix.Task

    alias Codebot.Repository, as: Repo

    @shortdoc "Drop the mongo db collection"
    def run(_) do
        Mix.Task.run("app.start")

        Repo.connect()
        |> Repo.drop(:journals)
    end
end
