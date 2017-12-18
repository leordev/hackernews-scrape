defmodule HnScraper.Scraper do
  def get_stories do
    url = "https://hacker-news.firebaseio.com/v0/topstories.json"
    %{body: stories} = HTTPotion.get url
    Poison.decode!(stories)
  end

  def get_story(id) do
    story_id = Integer.to_string(id)
    IO.puts(">>>> getting story " <> story_id)
    url = "https://hacker-news.firebaseio.com/v0/item/"
      <> story_id <> ".json"
    %{body: story} = HTTPotion.get url
    Poison.decode!(story)
  end

  def get_page_details(url) do
    IO.puts(">>>> scraping url " <> url)
    try do
      Scrape.website(url)
    rescue
      CaseClauseError -> nil
    end
  end

  def scrap_top(count) do
    get_stories()
    |> Enum.take(count)
    |> pmap(fn(i) -> map_story(i) end)
  end

  defp map_story(story_id) do
    raw_story = get_story(story_id)
    Map.put_new(raw_story, "details", get_page_details(raw_story["url"]))
  end

  def pmap(collection, func) do
    collection
    |> Enum.map(&(Task.async(fn -> func.(&1) end)))
    |> Enum.map(&Task.await(&1, 30000))
  end
end
