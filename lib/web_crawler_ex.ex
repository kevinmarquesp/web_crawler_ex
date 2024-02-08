defmodule WebCrawlerEx do
  alias WebCrawlerEx.Http.ExtractInnerUrls
  alias WebCrawlerEx.Db.Init
  require Logger

  @db "./.db.sqlite3"
  @migration_file "./migrate.sql"

  @url_buffer_table :url_buffer
  @valid_result_table :valid_result
  @binnary_result_table :binnary_result
  @timeout_error_table :timeout_error

  @timeout_span 10_000

  @doc """
  """
  def init_crawnler(init) do
    case Exqlite.Basic.open(@db) do
      {:ok, conn} ->
        execute_migration(conn, init)
      {:error, reason} ->
        Logger.error("#{inspect(self())} Couldn't open the #{@db} file: #{reason}")
    end
  end

  defp execute_migration(conn, init) do
    case Init.migrate(conn, @migration_file) do
      :ok ->
        recursive_crawnler(conn, init)
      {:error, reason} ->
        Logger.error("#{inspect(self())} Error reading file #{@migration_file}: #{reason}")
    end
  end

  @doc """
  """
  def recursive_crawnler(conn, init) do
    crawnler(conn, init)

    case Init.select(conn, @url_buffer_table) do
      {:ok, urls} ->
        recursive_crawnler(conn, urls)
      {:error, reason} ->
        Logger.error("#{inspect(self())} #{reason}")
    end
  end

  @doc """
  """
  def crawnler(_, []), do: Logger.error("#{inspect(self())} Cannot handle an empty list!")

  def crawnler(conn, base_urls) when is_list(base_urls) do
    base_urls
    |> Enum.map(&Task.async(fn -> crawnler(conn, &1) end))
    |> Enum.map(fn task ->
      try do
        Task.await(task, @timeout_span)
      catch
        :exit, _ ->
          Logger.error("#{inspect(self())} Error during processing task")
      end
    end)
  end
  
  def crawnler(conn, base_url) do
    case ExtractInnerUrls.extract_inner_urls(base_url) do
      {:ok, url_results} ->
        Logger.info("#{inspect(self())} Inserting #{base_url} to #{@db}:#{@valid_result_table}")
        insert_results(conn, base_url, url_results)

      {:error, :bincontent} ->
        Logger.warning("#{inspect(self())} Binnary content detected (in #{base_url})")
        Logger.warning("#{inspect(self())} Inserting #{base_url} to #{@db}:#{@binnary_result_table}")
        Init.insert(conn, @binnary_result_table, base_url)

      {:error, :timeout} ->
        Logger.error("#{inspect(self())} Timeout error (in #{base_url})")
        Init.insert(conn, @timeout_error_table, base_url)

      {:error, reason} ->
        Logger.error("#{inspect(self())} #{reason} (in #{base_url})")
    end
  end

  defp insert_results(conn, base_url, url_results) when is_list(url_results) do
    Logger.info("#{inspect(self())} Found #{length(url_results)} results in #{base_url}")

    Enum.each(url_results, fn (url) ->
      case Init.insert(conn, @url_buffer_table, url) do
        {:ok, _, _, _} ->
          Logger.info("#{inspect(self())} #{url} inserted on #{@db}:#{@url_buffer_table}")
        {:error, %Exqlite.Error{message: reason}, _} ->
          Logger.error("#{inspect(self())} #{reason}")
      end
    end)
  end
end
