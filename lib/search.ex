defmodule Codebot.Search do

    def find(mod, func) do
        result = find(mod)

        %{
            base_link: result.link, list: Enum.filter(
                result.list, fn (link)-> String.contains?(link, func)
            end)
        }
    end

    def find(mod) do
        case File.read("./test.json") do
            {:ok, file} ->
                case JSON.decode(file) do
                    {:ok, content} ->
                        [link | _ ] = Enum.filter(content, fn (link)->
                            link
                            |> String.downcase
                            |> String.contains?(mod)
                        end)
                        %HTTPoison.Response{body: body, status_code: code} = HTTPoison.get!(link, [], follow_redirect: true)

                        list =
                            handle_response(code, body)
                            |> Floki.find("div .summary-row")
                            |> Enum.map(fn (doc)->
                                %{
                                    signature: extract_signature(doc),
                                    description: extract_description(doc),
                                    link: extract_link(doc)
                                }
                            end)

                        %{ base_link: link, list: list }

                    _ -> raise "Could not decode file contents"
                end
            _ -> raise "Could not find path"
        end
    end

    defp handle_response(200, body) do
        case Floki.parse_document body do
            {:ok, content} -> content
            {:error, _error} -> raise "Could not parse document"
        end
    end

    defp handle_response(code, _) do
        raise "Could not fetch data from url. Response code " <> to_string(code)
    end

    defp extract_link(doc) do
        doc
        |> Floki.find("div .summary-signature")
        |> Floki.find("a")
        |> Floki.attribute("href")
        |> Enum.at(0)
    end

    defp extract_signature(doc) do
        doc
        |> Floki.find("div .summary-signature")
        |> Floki.find("a")
        |> Floki.text
    end

    defp extract_description(doc) do
        doc
        |> Floki.find("div .summary-synopsis")
        |> Floki.find("p")
        |> Floki.text
    end
end
