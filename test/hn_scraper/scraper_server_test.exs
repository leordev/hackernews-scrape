defmodule HnScraper.ScraperServerTest do
  use ExUnit.Case, async: true
  alias HnScraper.ScraperServer

  test "initializing the server" do
    {:ok, scraper} = ScraperServer.start_link
    assert {:ok, :resting} == ScraperServer.get_status(scraper)
  end

end
