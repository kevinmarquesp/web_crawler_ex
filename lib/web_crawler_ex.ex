defmodule WebCrawlerEx do
  alias WebCrawlerEx.Http.ExtractInnerUrls
  require Logger

  @timeout_span 10_000
  
  @doc """
  """
  def init(_url) do
  end

  @doc """
  """
  def crawn([]), do:
    Logger.warning("#{inspect(self())} Cannot handle an empty list")

  def crawn(base_url) when is_list(base_url) do
    pid = inspect(self())

    urls = base_url
    |> Enum.map(&Task.async(fn -> crawn(&1) end))
    |> Enum.flat_map(fn task ->
      try do
        Task.await(task, @timeout_span)
      catch
        :exit, _ ->
          Logger.error("#{pid} Task timeout: #{inspect(task)}")
          []
      end
    end)

    # do something
    crawn(urls)
  end

  def crawn(base_url) do
    pid = inspect(self())

    if String.valid?(base_url) do
      Logger.info("#{pid} Working with #{base_url}")

      case ExtractInnerUrls.extract_inner_urls(base_url) do
        {:ok, urls} ->  #this urls variable IS A LIST of strings
          Logger.info("#{pid} Found #{length(urls)} results")
          Logger.info("#{pid} Writting each result to the database")
          urls

        {:error, reason} ->
          Logger.error("#{pid} #{base_url} #{reason}")
          []

        {:warning, reason} ->
          Logger.warning("#{pid} #{base_url} #{reason}")
          []
        end

    else
      Logger.error("#{pid} Could not handle #{inspect(base_url)} URL string")
      []
    end
  end
end
