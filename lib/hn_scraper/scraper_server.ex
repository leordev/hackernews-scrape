defmodule HnScraper.ScraperServer do
  use GenServer
  alias HnScraper.Scraper

  def start_link(options \\ []) do
    GenServer.start_link __MODULE__, [], options
  end

  def init(_) do
    #stories = Scraper.scrap_top(30)
    schedule_work()
    {:ok, %{status: :resting, stories: [], time: nil}}
  end

  def update(pid, count \\ 30) do
    GenServer.cast(pid, {:update, count})
  end

  def get_status(pid) do
    GenServer.call(pid, :get_status)
  end

  def get_stories(pid) do
    GenServer.call(pid, :get_stories)
  end

  def handle_info(:perform_scrape, state) do
    update(self())
    schedule_work()
    {:noreply, %{status: :scraping, stories: state.stories, time: state.time}}
  end

  def handle_call(:get_status, _from, state) do
    {:reply, {:ok, state.status}, state}
  end

  def handle_call(:get_stories, _from, state) do
    {:reply, {:ok, state.stories}, state}
  end

  def handle_cast({:update, count}, state) do
    {:noreply, %{status: :resting, stories: Scraper.scrap_top(state.stories, count), time: System.os_time}}
  end

  def schedule_work() do
    Process.send_after(self(), :perform_scrape, 60_000)
  end
end
