defmodule WebCrawlerEx.HTTPHandler do
  @doc """
  Fetches the body response only for URLs that returns a text based content. Other
  kinds of URLs will return an error tuple, this error could be the HTTPoioson ones
  or a :bincontent error.
  """
  def fetch_response(url) do
    default_headers = [{"User-agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"}]

    case HTTPoison.get(url, default_headers) do
      {:error, %HTTPoison.Error{reason: reason}} -> {:error, reason}
      {:ok, %HTTPoison.Response{body: body}} -> if String.valid?(body) do
          {:ok, body}
        else
          {:error, :bincontent}
        end
    end
  end
end
