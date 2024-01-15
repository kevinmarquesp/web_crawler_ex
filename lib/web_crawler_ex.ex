defmodule WebCrawlerEx do
  @db_file "results.sqlite3"
  @db_table "links_list"

  def main(argv) do
    WebCrawlerEx.HandleDatabase.get_db_connection(@db_file, @db_table)
    |> run_and_write(argv)
  end

  defp run_and_write(db_conn, user_urls_list) do
    Enum.each(user_urls_list, fn user_url ->
      valid_urls = WebCrawlerEx.HandleHttpRequests.get_inner_links(user_url)

      #note: aqui seria legal aplicar o paralelismo mágico do elixir
      valid_urls |> Enum.each(&(WebCrawlerEx.HandleDatabase.insert_link(db_conn, @db_table, &1)))
      run_and_write(db_conn, valid_urls)
    end)
  end
end

defmodule WebCrawlerEx.HandleDatabase do
  def insert_link(db_conn, db_table, link), do:
    Exqlite.Basic.exec(db_conn, "INSERT OR IGNORE INTO #{db_table} (url) VALUES ('#{link}')")

  def get_db_connection(db_file, db_table) do
    {:ok, conn} = Exqlite.Basic.open(db_file)  #todo: handle error

    Exqlite.Basic.exec(conn, "CREATE TABLE IF NOT EXISTS #{db_table} (
      id INTEGER PRIMARY KEY,
      url TEXT UNIQUE
    );")

    conn
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
