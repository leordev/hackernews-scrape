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
    %{body: story} = HTTPotion.get url, [timeout: 30_000]
    Poison.decode!(story)
  end

  def get_page_details(url) do
    IO.puts(">>>> scraping url " <> url)
    try do
      Scrape.article(url)
    rescue
      CaseClauseError -> %{image: nil, description: nil, tags: nil}
    end
  end

  def scrap_top(count) do
    get_stories()
    |> Enum.take(count)
    |> pmap(fn(i) -> map_story(i) end)
  end

  defp map_story(story_id) do
    raw_story = get_story(story_id)
    page_details = get_page_details(raw_story["url"])
    %{
      :id => raw_story["id"],
      :url => raw_story["url"],
      :title => raw_story["title"],
      :score => raw_story["score"],
      :type => raw_story["type"],
      :time => raw_story["time"],
      :author => raw_story["by"],
      :page => %{
        :image => page_details.image,
        :description => page_details.description,
        :tags => page_details.tags
      }
    }
  end

  def pmap(collection, func) do
    collection
    |> Enum.map(&(Task.async(fn -> func.(&1) end)))
    |> Enum.map(&Task.await(&1, 30000))
  end
end
