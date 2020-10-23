defmodule CodeBot.Scraper do

    @base_url "https://hexdocs.pm/elixir/Kernel.html"

    @spec scrape(binary) :: :ok | {:error, atom}
    def scrape() do
        scrape(@base_url)
    end

    def scrape(url) when is_binary(url) do
        url
        |> fetch_content
        |> parse_menu
        |> Enum.filter(fn (url)-> String.contains?(url, "https://hexdocs.pm/elixir/") end)
        |> filter_links
        |> Enum.uniq
        |> IO.inspect
        |> json_encode
        |> write_to_file
    end

    defp fetch_content(url) when is_binary(url) do
        %HTTPoison.Response{body: body, status_code: code} = HTTPoison.get!(url, [], follow_redirect: true)
        handle_response(code, body)
    end

    defp handle_response(200, body) do
        {:ok, content} = Floki.parse_document body
        content
    end

    defp handle_response(code, _) do
        raise "Could not fetch data from url. Response code " <> to_string(code)
    end

    defp parse_menu(content) do
        content
        |> Floki.find("a")
        |> Floki.attribute("href")
        |> Enum.uniq
    end

    defp filter_links(links, index \\ 0, result \\ []) do
        case Enum.at links, index do
            nil -> result
            link ->
                new_results =
                    link
                    |> String.split("#")
                    |> Enum.at(0)
                    |> add_element_to_list(result)

                filter_links(links, index + 1, new_results)
        end
    end

    defp add_element_to_list(element, list) do
        list ++ [element]
    end

    defp write_to_file(content) when is_binary(content) do
        File.write("./test.json", content)
    end

    defp json_encode(content) do
        case JSON.encode content do
            {:ok, encoded} -> encoded
            _ -> raise "Could not encode the content"
        end
    end
end
