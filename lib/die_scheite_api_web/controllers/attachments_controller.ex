defmodule DieScheiteApiWeb.AttachmentsController do
  use DieScheiteApiWeb, :controller
  require Logger

  def get(conn, %{"id" => id}) do
    query = %{size: 1, query: %{bool: %{filter: [%{term: %{id: id}}]}}}

    with {:ok, [attachment], _, _} <- query |> post_query() |> parse_response(),
         {:ok, data} <- attachment |> Map.get("data") |> Base.decode64() do
      conn
      |> put_status(:ok)
      |> put_resp_header("Content-Type", Map.get(attachment, "contentType", ""))
      |> put_resp_header("Content-Encoding", Map.get(attachment, "contentEncoding", ""))
      |> text(data)
    else
      {:error, error} ->
        Logger.error("Error #{inspect error} Query: #{inspect query}")
        conn |> put_status(:internal_server_error) |> json(%{errors: [error]})
      err ->
        Logger.error("Unknown error #{inspect err} Query: #{inspect query}")
        conn |> put_status(:internal_server_error) |> json(%{errors: [%{message: "Unknown error", code: "ERR_UNKNOWN"}]})
    end
  end

  def post_query(query) do
    opts = Application.get_env(:die_scheite_api, :elastic)
    DieScheiteApi.ElasticClient.post_query(opts[:url], opts[:attachment_index], query)
  end

  def parse_response(response), do: DieScheiteApi.ElasticClient.parse_response(response)
end

