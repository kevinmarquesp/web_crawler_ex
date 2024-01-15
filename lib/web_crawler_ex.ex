defmodule WebCrawlerEx do
  @db_file "results.sqlite3"

  def main(argv) do
    Enum.each(argv, fn user_url ->
      valid_urls = WebCrawlerEx.HandleHttpRequests.get_inner_links(user_url)
      Enum.each(valid_urls, &(IO.puts(&1)))
      Enum.each(valid_urls, &(IO.puts(is_list &1)))
    end)
  end
end

defmodule WebCrawlerEx.HandleDatabase do
  def touch_db_file(db_file) do
    case File.exists?(db_file) do
      true ->
        IO.puts("Warning: #{db_file} already exists!")
      false -> 
        {:ok, _} = Exqlite.Basic.open(db_file)  #todo: handle error
        IO.puts("#{db_file} created with success!")
    end
  end
end

defmodule WebCrawlerEx.HandleHttpRequests do
  def get_inner_links(base_url) do
    {:ok, page_html} = fetch(base_url)  #todo: handle error
    href_values = get_href_values(page_html)  #todo: handle error

    filter_valid_links(href_values)
  end

  defp filter_valid_links(href_values), do:
    Enum.filter(href_values, &valid_http_url?/1)

  defp valid_http_url?(url_str), do:
    ~r/^http(s)?:\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/
    |> Regex.match?(url_str)

  defp get_href_values(page_html) do
    {:ok, parsed_html} = Floki.parse_document(page_html)  #todo: handle error
    a_tags = Floki.find(parsed_html, "body a")

    Enum.map(a_tags, &(Floki.attribute(&1, "href")))
    |> Enum.map(&hd/1)
    |> Enum.uniq()
  end

  defp fetch(url) do
    headers = [{"User-agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"}]

    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{body: page_html}} ->
        {:ok, page_html}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end
