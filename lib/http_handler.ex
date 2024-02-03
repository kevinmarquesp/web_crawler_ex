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

  def extract_attribute(body, attribute) do
    {status, result} = Floki.parse_document(body)

    if status !== :ok do
      {:error, result}
    else
      {
        :ok,
        Floki.find(result, "*[#{attribute}}]")
        |> Floki.attribute(attribute)
      }
    end
  end

  def extract_urls(body) do
    Regex.scan(~r/http(s)?:\/\/[\w\.\/\-=?#]+/, body)
    |> Enum.map(&Enum.at(&1, 0))
    |> Enum.map(&Enum.at(String.split(&1, "#"), 0))
  end
end
