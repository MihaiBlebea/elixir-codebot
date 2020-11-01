defmodule WitaiTest do
    use ExUnit.Case

    alias Codebot.Adapter.Witai, as: Witai

    test "can send a message and get a response" do
        resp = Witai.message("hey")

        assert resp == {:hello, %{"metric" => "metric_visitor"}}
    end

    test "can create an intent" do
        resp = Witai.create_intent("buy_flowers")

        assert resp == Codebot.Mock.WitaiRequestClient.post_intent_res_body
    end

    test "can delete an intent" do
        resp = Witai.delete_intent("buy_flowers")

        assert resp == :ok
    end

    test "can create an entity" do
        resp = Witai.create_entity(%{
            "name" => "flower_color",
            "roles" => [],
            "lookups" => [
                "free-text"
            ]
        })

        assert resp == Codebot.Mock.WitaiRequestClient.post_entity_res_body
    end

    test "can delete an entity" do
        resp = Witai.delete_entity("flower_color")

        assert resp == :ok
    end

    test "can create an utterance" do
        resp = Witai.create_utterances([
            %{
                "text" => "I want to buy a bread",
                "intent" => "buy_bread",
                "entities" => [
                    %{
                        "entity" => "wit$location:to",
                        "start" => 17,
                        "end" => 20,
                        "body" => "sfo",
                        "entities" => []
                    }
                ],
                "traits" => []
            }
        ])

        assert resp == Codebot.Mock.WitaiRequestClient.post_utterance_resp_body
    end

    test "can delete an utterance" do
        resp = Witai.delete_utterances([
            %{
                "text" => "I want to buy a bread"
            }
        ])

        assert resp == :ok
    end
end
