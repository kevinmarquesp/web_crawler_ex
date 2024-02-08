defmodule WebCrawlerEx.Http.ExtractInnerUrls do
  alias WebCrawlerEx.Http.FetchHelpers

  @html_url_attributes ["href", "src"]

  @doc """
  Fetches all inner URLs from a given base URL. This function first extracts the
  domain from the base URL using the `FetchHelpers.get_domain/1` function. The function
  returns a list of URLs without any fragment identifiers (no `#` in the url nor
  `/` character at the end).

  If the base URL is not valid or does not contain a domain, it returns an error
  tuple with the reason. If the body of the base URL cannot be fetched or is not
  text-based content, it also returns an error/warning tuple with the reason.
  """
  def extract_inner_urls(base_url) do
    case FetchHelpers.get_domain(base_url) do
      {:ok, domain} -> fetch_body(domain, base_url)
      {:error, reason} -> {:error, reason}
    end
  end

  defp fetch_body(domain, acc_base_url) do
    case FetchHelpers.fetch_body(acc_base_url) do
      {:ok, body} -> {:ok, extract_urls(domain, body)}
      {:error, reason} -> {:error, reason}
    end
  end

  defp extract_urls(domain, body) do
    @html_url_attributes
    |> Enum.map(&gracefully_extract_attributes(&1, body))
    |> List.flatten()
    |> Enum.filter(&valid_value?(&1))
    |> Enum.map(&format_local_urls(&1, domain))
    |> Enum.concat(FetchHelpers.extract_urls(body))
    |> Enum.map(&remove_end_slash(&1))
    |> Enum.uniq()
  end

  defp gracefully_extract_attributes(attribute, body) do
    case FetchHelpers.extract_attribute(attribute, body) do
      {:ok, values_list} -> values_list
      {:error, _} -> []
    end
  end

  defp valid_value?(""), do: false
  defp valid_value?("/"), do: false
  defp valid_value?(value), do: String.at(value, 0) !== "#"

  defp format_local_urls("/" <> url, domain), do: domain <> "/" <> url
  defp format_local_urls(url, _), do: url

  defp remove_end_slash(url) do
    if String.at(url, -1) === "/" do
      len = String.length(url)
      String.slice(url, 0, len - 1)
    else
      url
    end
  end
end