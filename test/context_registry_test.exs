defmodule ContextRegistryTest do
    use ExUnit.Case

    setup_all do
        pid = Codebot.Context.Registry.start_link
        {:ok, registry_pid: pid}
    end

    test "can create an empty context from registry" do
        {:ok, id} = Codebot.Context.Registry.spawn_context()

        assert is_binary(id)
    end

    test "can create a context from registry with intent and params" do
        {:ok, id} = Codebot.Context.Registry.spawn_context(:foo, %{"name" => "Mihai"})
        {:ok, c_pid} = Codebot.Context.Registry.lookup(id)
        intent = Codebot.Context.get(c_pid, :intent)
        props = Codebot.Context.get(c_pid, :props)

        assert is_binary(id) == true
        assert intent == :foo
        assert Map.fetch!(props, "name") == "Mihai"
    end
end
