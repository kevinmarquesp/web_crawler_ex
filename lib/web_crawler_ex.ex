defmodule WebCrawlerEx do
  def main(argv) do
    url = hd(argv)

    {:ok, page_html} = fetch(url)
    href_values = get_href_values(page_html)
    valid_urls = filter_valid_links(href_values)

    Enum.each(valid_urls, &(IO.puts(&1)))
  end

  defp filter_valid_links(href_values) do
    Enum.filter(href_values, fn
      [href_value] -> valid_http_url?(href_value)
      _ -> false
    end)
  end

  defp valid_http_url?(url_str) do
    valid_url_exp = ~r/^http(s)?:\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/
    Regex.match?(valid_url_exp, url_str)
  end

  defp get_href_values(page_html) do
    {:ok, parsed_html} = Floki.parse_document(page_html)
    a_tags = Floki.find(parsed_html, "body a")
    Enum.map(a_tags, &(Floki.attribute(&1, "href")))
  end

  defp fetch(url) do
    headers = [{"User-agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"}]

    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{body: page_html}} ->
        {:ok, page_html}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:ok, reason}
    end
  end
end
