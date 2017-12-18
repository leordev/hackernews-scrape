defmodule HnScraperWeb.StoriesController do
  use HnScraperWeb, :controller

  def top(conn, %{"count" => count}) do
    res = HnScraper.Scraper.scrap_top(String.to_integer(count))
    json conn, res
  end
end
