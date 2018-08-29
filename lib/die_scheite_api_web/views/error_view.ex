defmodule DieScheiteApiWeb.ErrorView do
  use DieScheiteApiWeb, :view

  def render("404.json", _) do
    %{errors: [%{message: "Resource not found", code: "ERR_NOT_FOUND"}]}
  end

  def render("500.json", _) do
    %{errors: [%{message: "Internal Server Error", code: "ERR_INTERNAL_SERVER_ERROR"}]}
  end
end
