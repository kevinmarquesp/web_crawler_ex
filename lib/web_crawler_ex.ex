defmodule WebCrawlerEx do
  require Logger
  alias WebCrawlerEx.HTTPHandler

  def fetch_inner_urls(url) do
    case HTTPHandler.get_domain(url) do
      {:ok, domain} ->
        case HTTPHandler.fetch_response(url) do
          {:ok, body} ->
            {:ok, Enum.map(["href", "src"], fn (attr) ->
              case HTTPHandler.extract_attribute(body, attr) do
                {:ok, urls_list} -> urls_list
                {:error, _} -> []
              end
            end)
            |> List.flatten()
            |> Enum.filter(&(not (&1 == "" or &1 == "/" or String.at(&1, 0) == "#")))
            |> Enum.map(fn (url) ->
              case url do
                "/" <> _ -> domain <> url
                _ -> url
              end
            end)
            |> Enum.concat(HTTPHandler.extract_urls(body))
            |> Enum.uniq()}

          {:error, :bincontent} ->
            {:warning, "Binnary file detected, ignoring"}
          {:error, reason} ->
            {:error, "HTTP request error: #{reason}"}
        end

      {:error, reason} ->
        {:error, "You're url is not valid, ignoring: #{reason}"}
    end
  end

  def crawn_controller(url) do
    IO.puts(url)
  end
end
