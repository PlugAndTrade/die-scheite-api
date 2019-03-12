defmodule DieScheiteApiWeb.Router do
  use DieScheiteApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DieScheiteApiWeb do
    pipe_through :api

    get "/entries", EntriesController, :index
    get "/logentries", EntriesController, :index
    get "/logentries/properties", EntriesController, :properties
    get "/attachments/:id", AttachmentsController, :get
  end
end
