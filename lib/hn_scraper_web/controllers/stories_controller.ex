defmodule HnScraperWeb.StoriesController do
  use HnScraperWeb, :controller
  alias HnScraper.ScraperServer

  def top(conn, _params) do
    {:ok, res} = ScraperServer.get_stories(Stories) 
    json conn, res
  end
end
