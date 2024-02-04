defmodule WebCrawlerEx.HTTPHandlerTest do
  use ExUnit.Case

  alias WebCrawlerEx.HTTPHandler

  @valid_url "https://example.com"
  @invalid_url "https://moc.elpmaxe"
  @binary_content_url "https://www.americanpost.news/wp-content/uploads/2022/10/The-anime-Oshi-no-Ko-announces-its-premiere-date.jpg"

  test "fetch_body/1 with valid URL" do
    {:ok, body} = HTTPHandler.fetch_body(@valid_url)

    assert String.valid?(body) == true
  end

  test "fetch_body/1 with invalid URL" do
    assert HTTPHandler.fetch_body(@invalid_url) == {:error, :nxdomain}
  end

  test "fetch_body/1 with binary content URL" do
    assert HTTPHandler.fetch_body(@binary_content_url) == {:error, :bincontent}
  end

  test "extract_attribute/2 should select existing and non-existing attribute values" do
    body = "<div class='test'>Hello, World!</div>"
    assert HTTPHandler.extract_attribute("class", body) == {:ok, ["test"]}
    assert HTTPHandler.extract_attribute("id", body) == {:ok, []}
  end

  test "extract_urls/1 should retrun a list with the urls found" do
    body_with_urls = "Check out https://elixir-lang.org and http://example.com"
    assert HTTPHandler.extract_urls(body_with_urls) == ["https://elixir-lang.org", "http://example.com"]

    body_without_urls = "This is a text without any URLs."
    assert HTTPHandler.extract_urls(body_without_urls) == []
  end

  test "get_domain/1 should return the correct domain" do
    assert HTTPHandler.get_domain("https://elixir-lang.org/docs.html") == {:ok, "https://elixir-lang.org"}
    assert HTTPHandler.get_domain("invalid_url") == {:error, :noturl}
  end
end
