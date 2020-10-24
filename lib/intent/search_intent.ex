defmodule Codebot.Intent.SearchIntent do
    @spec get_response(map) :: any
    def get_response(entities) do
        params =
            entities
            |> Map.values
            |> List.flatten
            |> build_entities_map

        cond do
            Map.get(params, "module") == nil -> raise "module not found"
            Map.get(params, "module") !== nil and Map.get(params, "function") !== nil ->
                Codebot.Search.find(Map.get(params, "module"), Map.get(params, "function"))
            Map.get(params, "module") !== nil -> Codebot.Search.find(Map.get(params, "module"))
        end
    end

    @spec build_entities_map(any, any, any) :: any
    def build_entities_map(entities, index \\ 0, result \\ %{}) do
        case Enum.at(entities, index) do
            nil -> result
            entity ->
                new_result = Map.put(result, Map.get(entity, "name"), Map.get(entity, "value"))
                build_entities_map(entities, index + 1, new_result)
        end
    end
end
