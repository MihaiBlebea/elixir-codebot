defmodule Codebot.Context do

    defstruct id: nil, name: nil, props: nil

    @spec start_link :: pid
    def start_link() do
        id = UUID.uuid1()
        case Agent.start_link(fn ()-> %Codebot.Context{id: id} end) do
            {:error, _} -> raise "Could not start a new context"
            {:ok, pid} -> pid
        end
    end

    @spec get(atom | pid, binary | atom) :: any
    def get(pid, key) do
        Agent.get(pid, fn (state)-> Map.get(state, key) end)
    end

    def getId(pid) do
        get(pid, :id)
    end

    @spec put(atom | pid, binary | atom, any) :: :ok
    def put(pid, key, value) do
        Agent.update(pid, fn (state)-> Map.put(state, key, value) end)
    end

    @spec del(pid | atom, binary) :: :ok
    def del(pid, key) do
        Agent.update(pid, fn (state)-> Map.delete(state, key) end)
    end
end
