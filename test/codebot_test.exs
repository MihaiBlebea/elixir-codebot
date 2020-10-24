defmodule CodebotTest do
    use ExUnit.Case
    doctest Codebot

    test "greets the world" do
        assert Codebot.hello() == :world
    end
end
