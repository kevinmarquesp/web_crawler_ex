defmodule WebCrawlerEx do
  def main(argv) do
    url = hd(argv)

    case fetch(url) do
      {:ok, body} ->
        IO.puts(body)
      {:error, reason} ->
        IO.puts("Failed to fetch '#{url}' :: #{reason}")
    end
  end

  defp fetch(url) do
    headers = [{"User-agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"}]

    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{body: body}} ->
        {:ok, body}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:ok, reason}
    end
  end
end
