defmodule WebCrawlerEx.HTTPHandlerTest do
  use ExUnit.Case

  alias WebCrawlerEx.HTTPHandler

  @valid_url "https://example.com"
  @invalid_url "https://moc.elpmaxe"
  @binary_content_url "https://www.americanpost.news/wp-content/uploads/2022/10/The-anime-Oshi-no-Ko-announces-its-premiere-date.jpg"

  test "fetch_response/1 with valid URL" do
    {:ok, body} = HTTPHandler.fetch_response(@valid_url)

    assert String.valid?(body) == true
  end

  test "fetch_response/1 with invalid URL" do
    assert HTTPHandler.fetch_response(@invalid_url) == {:error, :nxdomain}
  end

  test "fetch_response/1 with binary content URL" do
    assert HTTPHandler.fetch_response(@binary_content_url) == {:error, :bincontent}
  end
end
