defmodule WebCrawlerEx.Db.Init do
  @doc """
  Migrates the database schema using SQL queries from a file.

  This function reads SQL queries from the specified file and executes them on the
  given database connection. The SQL queries are split by semicolons (`;`), with
  any leading or trailing whitespace removed. Empty queries are filtered out.
  Each query is executed individually using the provided database connection.
  """
  def migrate(conn, file) do
    case File.read(file) do
      {:ok, query} ->
        filter_query(query)
        |> Enum.each(&Exqlite.Basic.exec(conn, &1))
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp filter_query(query) do
    String.split(query, ";")
    |> Enum.map(&String.replace(&1, "\t", ""))
    |> Enum.map(&String.replace(&1, "\n", ""))
    |> Enum.filter(&(String.length(&1) > 0))
    |> Enum.map(&(&1 <> ";"))
  end
end
