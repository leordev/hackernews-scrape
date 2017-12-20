defmodule HnScraper.Scraper do
  def get_stories do
    url = "https://hacker-news.firebaseio.com/v0/topstories.json"
    %{body: stories} = HTTPotion.get url
    Poison.decode!(stories)
  end

  def get_story(id) do
    IO.puts(">>>> getting story #{id}")
    url = "https://hacker-news.firebaseio.com/v0/item/#{id}.json"
    %{body: story} = HTTPotion.get url, [timeout: 30_000]
    Poison.decode!(story)
  end

  def get_page_details(url) do
    if url == nil do
      %{image: nil, description: nil, tags: nil}
    else
      IO.puts(">>>> scraping url " <> url)
      try do
        Scrape.article(url)
      rescue
        CaseClauseError -> %{image: nil, description: nil, tags: nil}
      end
    end
  end

  def scrap_top(stories, count) do
    IO.puts(">>>>> preparing for scraping")

    IO.puts("we have currently #{Enum.count(stories)} scraped stories")

    old_stories = stories
      |> Enum.map(fn(s) -> s.id end)

    new_stories = get_stories()

    stories_to_scrape =
      new_stories
      |> Enum.take(count)
      |> Enum.filter(fn(i) ->
        not Enum.member?(old_stories, i)
      end)

    IO.puts("found #{Enum.count(stories_to_scrape)} stories to scrape")

    IO.puts(">>>> starting scrape")

    new_scrapes =
      stories_to_scrape
      |> pmap(fn(i) -> map_story(i) end)

    IO.puts(">>>> scraping finished")

    result =
      new_stories
      |> Enum.take(count)
      |> Enum.map(fn(s) ->
        new_story = Enum.find(new_scrapes, nil, fn(x) -> x.id == s end)
        if new_story == nil do
          Enum.find(stories, nil, fn(x) -> x.id == s end)
        else
          new_story
        end
      end)

    IO.puts(">>>> current stories in state: #{Enum.count(result)}")

    result
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
