defmodule Week5.Minimal do
  def visit_link do
    link = "https://quotes.toscrape.com/"

    response = HTTPoison.get!(link)

    IO.puts("#{IO.ANSI.yellow()}STATUS CODE:#{IO.ANSI.reset()}")
    IO.puts(Map.get(response, :status_code))

    IO.puts("#{IO.ANSI.yellow()}HEADERS:#{IO.ANSI.reset()}")
    IO.inspect(Map.get(response, :headers))

    IO.puts("#{IO.ANSI.yellow()}BODY:#{IO.ANSI.reset()}")
    IO.puts(Map.get(response, :body))
  end

  defmodule QuotesToScrape do
    use Crawly.Spider

    @impl Crawly.Spider
    def base_url(), do: "https://quotes.toscrape.com/"

    @impl Crawly.Spider
    def init() do
      [start_urls: ["https://quotes.toscrape.com/"]]
    end

    @impl Crawly.Spider
    def parse_item(response) do
      # Parse response body to document
      {:ok, document} = Floki.parse_document(response.body)

      # Create item (for pages where items exists)
      items =
        document
        |> Floki.find(".quote")
        |> Enum.map(fn q ->
          %{
            author: Floki.find(q, "span small") |> Floki.text(),
            quote: Floki.find(q, "span.text") |> Floki.text() |> String.replace("\\\"", "'"),
            tags:
              Floki.find(q, "meta.keywords")
              |> Floki.attribute("content")
              |> Enum.map(fn x -> String.split(x, ",") end)
              |> Enum.at(0)
          }
        end)

      {_status, result} = JSON.encode(items)
      File.write("./tmp/quotes.json", result)

      %{items: items}
    end
  end
end
