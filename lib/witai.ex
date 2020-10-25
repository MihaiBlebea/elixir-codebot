defmodule Codebot.Witai do
    require Logger

    @base_url "https://api.wit.ai"

    @varsion "20201023"

    @token "RSO37RX6O2NT3NCQWYF5CET4IJENJFCO"

    @long_timeout 10000

    # Shared

    @spec get(binary) :: map | list | binary
    def get(url) when is_binary(url) do
        %HTTPoison.Response{body: body, status_code: code} = HTTPoison.get!(url, get_default_headers())
        decode_body(body, code)
    end

    @spec post(binary, map) :: map | list
    def post(url, req_body) when is_binary(url) and is_map(req_body) do
        {:ok, req_body} = JSON.encode(req_body)
        %HTTPoison.Response{body: body, status_code: code} = HTTPoison.post!(url, req_body, get_default_headers())
        decode_body(body, code)
    end

    @spec delete(binary) :: :ok
    def delete(url) when is_binary(url) do
        %HTTPoison.Response{body: _body, status_code: code} = HTTPoison.delete!(url, get_default_headers(), recv_timeout: @long_timeout)
        case code do
            200 -> :ok
            _ ->
                Logger.error("Request failed with code " <> to_string(code))
                raise "Request failed with code " <> to_string(code)
        end
    end

    @spec put(binary, map) :: :ok
    def put(url, req_body) when is_binary(url) and is_map(req_body) do
        {:ok, body} = JSON.encode(req_body)
        %HTTPoison.Response{body: _body, status_code: code} = HTTPoison.put!(url, body, get_default_headers(), recv_timeout: @long_timeout)
        case code do
            200 -> :ok
            _ ->
                Logger.error("Request failed with code " <> to_string(code))
                raise "Request failed with code " <> to_string(code)
        end
    end

    defp get_default_headers() do
        ["Authorization": "Bearer #{ @token }", "Content-Type": "application/json"]
    end

    defp decode_body(body, 200) do
        case JSON.decode body do
            {:ok, body} -> body
            _ ->
                Logger.error(body)
                raise "Could not decode the response body"
        end
    end

    defp decode_body(body, code) do
        Logger.error(body)
        raise "Request failed with code " <> to_string(code)
    end

    defp encode_message(term) when is_binary(term) do
        URI.encode(term)
    end

    # Message

    @spec message(binary) :: {atom, %{}}
    def message(term) when is_binary(term) do
        %{
            "entities" => entities,
            "intents" => intents,
            "text" => _text,
            "traits" => _traits
        } = get "#{ @base_url }/message?v=#{ @varsion }&q=#{ encode_message(term) }"
        intent = extract_intent intents
        entity_map = extract_entities entities

        {intent, entity_map}
    end

    defp extract_intent(intents) when is_list(intents) do
        intents
        |> Enum.filter(fn (%{"id" => _, "name" => _name, "confidence" => confidence})-> confidence > 0.5 end)
        |> Enum.at(0)
        |> to_atom
    end

    defp to_atom(%{"id" => _, "name" => name, "confidence" => _}) do
        String.to_existing_atom(name)
    end

    defp to_atom(nil) do
        raise "No valid intent found"
    end

    defp extract_entities(entities) when is_map(entities) do
        entities
        |> Map.values
        |> List.flatten
        |> build_entity_map
    end

    defp build_entity_map(entities) when is_list(entities) do
        build_entity_map(entities, 0, %{})
    end

    defp build_entity_map(entities, index, result) when is_list(entities) and is_integer(index) and is_map(result) do
        case Enum.at(entities, index) do
            nil -> result
            entity ->
                new_result = Map.put(result, Map.get(entity, "name"), Map.get(entity, "value"))
                build_entity_map(entities, index + 1, new_result)
        end
    end

    # Intents

    @spec create_intent(binary) :: map
    def create_intent(name) when is_binary(name) do
        url = "#{ @base_url }/intents?v=#{ @varsion }"
        {:ok, body} = JSON.encode(%{"name" => name})
        %HTTPoison.Response{body: body, status_code: code} = HTTPoison.post!(url, body, get_default_headers())
        decode_body(body, code)
    end

    @spec delete_intent(binary) :: :ok
    def delete_intent(name) when is_binary(name) do
        delete "#{ @base_url }/intents/#{ name }?v=#{ @varsion }"
    end

    @spec get_intent(binary) :: map
    def get_intent(name) when is_binary(name) do
        get "#{ @base_url }/intents/#{ name }?v=#{ @varsion }"
    end

    # Entities

    @spec get_entities :: list
    def get_entities() do
        get "#{ @base_url }/entities?v=#{ @varsion }"
    end

    @spec get_entity(binary) :: map
    def get_entity(name) when is_binary(name) do
        get "#{ @base_url }/entities/#{ name }?v=#{ @varsion }"
    end

    @spec create_entity(map) :: map
    def create_entity(req_body) when is_map(req_body) do
        post "#{ @base_url }/entities?v=#{ @varsion }", req_body
    end

    @spec delete_entity(binary) :: :ok
    def delete_entity(name) when is_binary(name) do
        delete "#{ @base_url }/entities/#{ name }?v=#{ @varsion }"
    end

    @spec update_entity(binary, map) :: :ok
    def update_entity(name, req_body) when is_binary(name) and is_map(req_body) do
        put "#{ @base_url }/entities/#{ name }?v=#{ @varsion }", req_body
    end

    # Utterances

    @spec get_utterances(integer) :: list
    def get_utterances(limit) do
        get "#{ @base_url }/utterances?v=#{ @varsion }&limit=#{ to_string(limit) }"
    end

    @spec get_utterances(integer, integer) :: list
    def get_utterances(limit, offset) do
        get "#{ @base_url }/utterances?v=#{ @varsion }&limit=#{ to_string(limit) }&offset=#{ offset }"
    end

    @spec get_utterances(integer, integer, list) :: list
    def get_utterances(limit, offset, intents) do
        intents_str = Enum.join intents, ","
        get "#{ @base_url }/utterances?v=#{ @varsion }&limit=#{ to_string(limit) }&offset=#{ offset }&intents=#{ intents_str }"
    end

    @spec create_utterances(list) :: map
    def create_utterances(list) do
        post "#{ @base_url }/utterances?v=#{ @varsion }", list
    end
end
