defmodule Codebot.Scraper do
    require Logger

    @moduledoc """
    1. Go to the https://hexdocs.pm/elixir/api-reference.html#content
    2. Search for the module name
    3. Navigate to the module page. eg. https://hexdocs.pm/elixir/String.html
    4. Extract the module description

    5. Look for the module function
    6. Extract the module functions and description
    7. Save all the content to a json file

    How this should look like in the end
    ```
    [
        {
            "name": "StringIO",
            "description": "<div class=\"summary-row\"><div class=\"summary-signature\"><a href=\"StringIO.html\">StringIO</a></div><div class=\"summary-synopsis\"><p>Controls an IO device process that wraps a string.</p></div></div>",
            "url": "https://hexdocs.pm/elixir/StringIO.html",
            "functions": [
                {
                    "name": "elem/1",
                    "url": "https://hexdocs.pm/elixir/StringIO.html#elem/1",
                    "signature": "elem(index)",
                    "description": "<div class=\"summary-row\"><div class=\"summary-signature\"><a href=\"StringIO.html\">StringIO</a></div><div class=\"summary-synopsis\"><p>Controls an IO device process that wraps a string.</p></div></div>"
                }
            ]
        }
    ]
    ```
    """

    @base_url "https://hexdocs.pm/elixir"

    @local_path "./store"

    def refresh_cache() do
        @base_url <> "/api-reference.html#content"
        |> get_page_content
        |> extract_modules
        |> store_to_file(@local_path <> "/modules.json")

        read_from_file(@local_path <> "/modules.json")
        |> get_page_content
        |> Enum.map(fn (content)-> extract_functions content end)
        |> store_to_file(@local_path <> "/functions.json")
    end

    defp get_page_content(url) when is_binary(url) do
        %HTTPoison.Response{body: body, status_code: code} = HTTPoison.get!(url, [], follow_redirect: true)
        handle_response(body, code)
    end

    defp get_page_content(list) when is_list(list) do
        Enum.map(list, fn (summary)-> get_page_content "#{ @base_url }/#{ Map.get(summary, "url") }" end)
    end

    defp handle_response(body, 200) do
        body
    end

    defp handle_response(body, code) do
        Logger.error(body)
        raise "Request failed with code " <> to_string(code)
    end

    defp extract_modules(content) do
        content
        |> Floki.parse_document!
        |> Floki.find("div .summary-row")
        |> Enum.map(fn (summary)->
            url =
                summary
                |> Floki.find("a")
                |> Floki.attribute("href")
                |> Enum.at(0)
            content = Floki.raw_html(summary)
            name =
                url
                |> String.split(".")
                |> Enum.at(0)

            %{"url" => url, "name" => name, "content" => content}
        end)
    end

    defp extract_functions(content) do
        content
        |> Floki.parse_document!
        |> Floki.find("div .summary-functions")
        |> Floki.find("div .summary-row")
        |> Enum.map(fn (summary)->
            anchor =
                summary
                |> Floki.find("a")
                |> Floki.attribute("href")
                |> Enum.at(0)
            name =
                summary
                |> Floki.find("a")
                |> Floki.text

            %{"a" => anchor, "name" => name}
        end)
    end

    defp store_to_file(content, file) do
        case JSON.encode content do
            {:ok, encoded} -> File.write(file, encoded)
            _ -> raise "Could not encode the content"
        end
    end

    defp read_from_file(file) do
        case File.read(file) do
            {:ok, content} -> JSON.decode!(content)
            {:error, _} -> raise "Cannot read file"
        end
    end
end
