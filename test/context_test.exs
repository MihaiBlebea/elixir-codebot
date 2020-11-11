defmodule ContextTest do
    use ExUnit.Case

    alias Codebot.Domain.Context

    test "can create a context with a custom context id" do
        pid = Context.start_link("serban")
        assert is_pid(pid) == true
    end

    test "will return the same context if trying to create a context wth the same context id" do

    end

    test "can not create a context with empty string as context id" do

    end

    test "can not create a context with an integer as context id" do

    end

    test "can add and fetch an intent to an existing context" do

    end

    test "can add and fetch props to an existing context" do

    end

    test "will delete the existing props once the intent is changed" do

    end
end
