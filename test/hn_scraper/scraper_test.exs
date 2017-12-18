defmodule HnScraper.ScraperTest do
  use ExUnit.Case, async: false
  alias HnScraper.Scraper

  test "get hn top stories list" do
    assert Enum.count(Scraper.get_stories) > 30
  end

  test "get story" do
    [ id | _stories ] = Scraper.get_stories
    story = Scraper.get_story(id)
    assert story["id"] > 0
    assert story["score"] > 0
    assert String.length(story["title"]) > 0
  end

  test "scrape story origin website" do
    [ id | _stories ] = Scraper.get_stories
    story = Scraper.get_story(id)
    page_details = Scraper.get_page_details(story["url"])
    assert String.contains?(story["url"], page_details.url)
  end

  test "scrap 3 stories" do
    stories = Scraper.scrap_top(3)
    IO.inspect(stories)
    assert Enum.count(stories) == 3
  end
end
