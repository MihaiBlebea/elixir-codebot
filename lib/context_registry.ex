defmodule Codebot.Context.Registry do
    def start_link() do
        case Registry.start_link(keys: :unique, name: Codebot.Context.Registry) do
            {:error, _term} -> raise "Could not start the context registry"
            {:ok, pid} -> pid
        end
    end

    def register(pid, context_id, context_pid) when is_binary(context_id) do
        case Registry.register(pid, context_id, context_pid) do
            {:error, _} -> raise "Could not register context in registry"
            {:ok, _} -> :ok
        end
    end

    @spec spawn_context(pid | atom) :: none
    def spawn_context(pid) do
        spawn_context(pid, nil, %{})
    end

    def spawn_context(pid, name, props) when is_map(props) do
        context_pid = Codebot.Context.start_link
        id = Codebot.Context.getId(context_pid)

        case Registry.register(pid, id, context_pid) do
            {:error, _} -> raise "Could not register context in registry"
            {:ok, _} -> :ok
        end
    end

    def lookup(pid, context_id) when is_binary(context_id) do
        case Registry.lookup(pid, context_id) do
            [{pid, value} | _] -> IO.inspect pid, value
            _ -> raise "Could not look up after repository"
        end
    end
end
