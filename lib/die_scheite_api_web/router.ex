defmodule DieScheiteApiWeb.Router do
  use DieScheiteApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DieScheiteApiWeb do
    pipe_through :api

    get "/entries", EntriesController, :index
  end
end
