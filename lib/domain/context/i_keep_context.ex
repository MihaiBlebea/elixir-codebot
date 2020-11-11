defmodule Codebot.Domain.Context.IKeepContext do
    @callback get(binary, binary | atom) :: any

    @callback put(binary, binary | atom, any) :: :ok | :fail

    @callback del(binary, binary) :: :ok
end
