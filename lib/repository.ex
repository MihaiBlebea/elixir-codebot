defmodule Codebot.Repository do
    # https://github.com/zookzook/elixir-mongodb-driver

    @collection "elixir"

    @spec connect :: pid
    def connect() do
        case Mongo.start_link(url: "mongodb://localhost:27015/codebot-v1") do
            {:ok, pid} -> pid
            {:error, _} -> raise "Could not connect to mongo db"
        end
    end

    def drop(pid, collection) do
        Mongo.drop_collection(pid, collection)
    end

    @spec insert_one(pid | atom, map) :: {:error, Mongo.Error.t()} | {:ok, Mongo.InsertOneResult.t()}
    def insert_one(pid, doc) do
        Mongo.insert_one(pid, @collection, doc)
    end

    @spec find_one(pid | atom, map) :: map
    def find_one(pid, query) when is_map(query) do
        Mongo.find_one(pid, @collection, query)
    end
end
