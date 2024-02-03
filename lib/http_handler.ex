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

  @doc """
  Extracts the value of a given attribute from the HTML body. This function uses
  the Floki library to parse the HTML and find the attribute. If the parsing is
  successful, it returns a tuple {:ok, attribute_value}. If the parsing fails,
  it returns a tuple {:error, reason}.
  """
  def extract_attribute(body, attribute) do
    {status, result} = Floki.parse_document(body)

    if status !== :ok do
      {:error, result}
    else
      {
        :ok,
        Floki.find(result, "*[#{attribute}]")
        |> Floki.attribute(attribute)
      }
    end
  end
  
  @doc """
  Extracts all URLs from a given text body. This function uses a regular expression
  to find all strings that match the pattern of a URL. It returns a list of URLs
  without any fragment identifiers (the part of the URL after the '#').
  """
  def extract_urls(body) do
    Regex.scan(~r/http(s)?:\/\/[\w\.\/\-=?#]+/, body)
    |> Enum.map(&Enum.at(&1, 0))
    |> Enum.map(&Enum.at(String.split(&1, "#"), 0))
  end

  
  @doc """
  Extracts the domain from a given URL. This function uses the URI.parse function
  to parse the URL and extract the scheme (like 'http' or 'https') and the host
  (the domain name). If the URL is valid and contains a scheme and a host, it returns
  a tuple {:ok, domain_name}. If the URL is not valid or does not contain a scheme
  and a host, it returns {:error, :noturl}.
  """
  def get_domain(url) do
    case URI.parse(url) do
      %URI{scheme: scheme, host: host} when is_binary(scheme) and is_binary(host) ->
        {:ok, "#{scheme}://#{host}"}
      _ ->
        {:error, :noturl}
    end
  end
end
