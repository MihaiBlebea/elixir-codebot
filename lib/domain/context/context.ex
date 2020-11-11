defmodule Codebot.Domain.Context do
    @behaviour Codebot.Domain.Context.IKeepContext

    defstruct id: nil, intent: nil, props: nil

    @spec start_link(binary) :: pid
    def start_link(context_id) do
        name = {:via, Registry, {:context_registry, context_id}}
        case Agent.start_link(fn ()-> %__MODULE__{id: context_id} end, name: name) do
            {:error, {:already_started, pid}} -> pid
            {:ok, pid} -> pid
        end
    end

    @spec lookup(binary) :: pid | nil
    def lookup(context_id) do
        Registry.lookup(:context_registry, context_id) |> Enum.at(0, nil) |> extract_pid
    end

    defp extract_pid({intent, _props}), do: intent

    defp extract_pid(nil), do: nil

    @spec exists?(binary) :: boolean
    def exists?(context_id) do
        case lookup(context_id) do
            nil -> false
            _pid -> true
        end
    end

    @spec get(binary, binary | atom) :: any
    def get(context_id, key) when is_binary(context_id) do
        lookup(context_id) |> Agent.get(fn (state)-> Map.get(state, key) end)
    end

    @spec put(binary, binary | atom, any) :: :ok | :fail
    def put(context_id, key, value) when is_binary(key) do
        put(context_id, String.to_atom(key), value)
    end

    def put(context_id, key, value) when is_atom(key) do
        pid = lookup(context_id)
        cond do
            key == :intent -> Agent.update(pid, fn (state)-> Map.put(state, :intent, value) end)
            key == :props and is_map(value) -> Agent.update(pid, fn (state)-> Map.put(state, :props, value) end)
            true -> :fail
        end
    end

    @spec del(binary, binary) :: :ok
    def del(context_id, key) do
        pid = lookup(context_id)
        Agent.update(pid, fn (state)-> Map.delete(state, key) end)
    end

    @spec update_intent(binary, any) :: :fail | :ok | :nochange
    def update_intent(context_id, intent) do
        case get(context_id, :intent) == intent do
            true -> :nochange
            false -> case put(context_id, :intent, intent) do
                :ok -> put(context_id, :props, nil)
                :fail -> :fail
            end
        end
    end
end
