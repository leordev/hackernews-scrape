defmodule HnScraper.ScraperServer do
  use GenServer
  alias HnScraper.Scraper

  def start_link(options \\ []) do
    GenServer.start_link __MODULE__, [], options
  end

  def init(_) do
    stories = Scraper.scrap_top(30)
    {:ok, %{status: :resting, stories: stories, time: System.os_time}}
  end

  def update(pid, count \\ 100) do
    GenServer.cast(pid, {:update, count})
  end

  def get_status(pid) do
    GenServer.call(pid, :get_status)
  end

  def get_stories(pid) do
    GenServer.call(pid, :get_stories)
  end

  def handle_call(:get_status, _from, state) do
    {:reply, {:ok, state.status}, state}
  end

  def handle_call(:get_stories, _from, state) do
    {:reply, {:ok, state.stories}, state}
  end

  def handle_cast({:update, count}, _state) do
    {:noreply, %{status: :resting, stories: Scraper.scrap_top(count)}}
  end
end
