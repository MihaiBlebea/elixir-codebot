defmodule Codebot.Scraper do
    require Logger

    @moduledoc """
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

    def scrape() do
        @base_url <> "/api-reference.html#content"
        |> get_page_content
        |> extract_modules
        |> Enum.map(&add_functions_to_module/1)
        # |> store_to_file(@local_path <> "/functions.json")
    end

    defp get_page_content(url) when is_binary(url) do
        %HTTPoison.Response{body: body, status_code: code} = HTTPoison.get!(url, [], follow_redirect: true)
        handle_response(body, code)
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

            %{"url" => "#{ @base_url }/#{ url }", "name" => name, "content" => content}
        end)
    end

    defp extract_functions(content) do
        Floki.parse_document!(content)
        |> Floki.find("div .functions-list")
        |> Floki.find("section")
        |> Enum.map(fn (detail)->
            id =
                detail
                |> Floki.attribute("id")
                |> Enum.at(0)
            html = Floki.raw_html(detail)
            %{"anchor" => id, "description" => html}
        end)
    end

    defp add_functions_to_module(%{"url" => url, "name" => _, "content" => _} = module) do
        funcs =
            get_page_content(url)
            |> extract_functions
            |> Enum.map(fn (func)->
                %{"anchor" => anchor, "description" => _} = func
                Map.put(func, "url", "#{ url }#{ anchor }")
            end)

        Map.put(module, "functions", funcs)
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
