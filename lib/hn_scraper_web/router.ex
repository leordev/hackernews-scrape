defmodule HnScraperWeb.Router do
  use HnScraperWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", HnScraperWeb do
    pipe_through :api

    get "/top", StoriesController, :top
  end
end
