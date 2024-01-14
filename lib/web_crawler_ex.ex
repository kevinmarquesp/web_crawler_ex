defmodule WebCrawlerEx do
  use Ecto.Migration

  def main(argv) do
    hd(argv)
    |> IO.puts()
  end
end
