defmodule Mix.Tasks.Scrape do
    use Mix.Task

    alias Codebot.Repository, as: Repo

    @shortdoc "Scrape the docs site and saves results in database"
    def run(_) do
        Mix.Task.run("app.start")

        pid = Repo.connect()
        Codebot.Scraper.scrape()
        |> Enum.map(fn (entry)-> Repo.insert_one(pid, entry) end)
    end
end
