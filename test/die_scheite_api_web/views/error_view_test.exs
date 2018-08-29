defmodule DieScheiteApiWeb.ErrorViewTest do
  use DieScheiteApiWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 404.json" do
    assert render(DieScheiteApiWeb.ErrorView, "404.json", []) ==
           %{errors: [%{message: "Resource not found", code: "ERR_NOT_FOUND"}]}
  end

  test "renders 500.json" do
    assert render(DieScheiteApiWeb.ErrorView, "500.json", []) ==
           %{errors: [%{message: "Internal Server Error", code: "ERR_INTERNAL_SERVER_ERROR"}]}
  end
end
