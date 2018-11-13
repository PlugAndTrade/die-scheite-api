defmodule DieScheiteApiWeb.EntriesController do
  use DieScheiteApiWeb, :controller
  require Logger

  @term_keys [
    "id",
    "parentId",
    "correlationId",
    "serviceId",
    "serviceInstanceId",
    "servcieVersion",
    "route",
    "protocol",
    "level",
    "http.request.method",
    "http.request.uri",
    "http.request.host",
    "http.response.statusCode",
    "rabbitmq.queueName",
    "rabbitmq.acked",
    "rabbitmq.messageId"
  ]

  @range_keys [
    "timestamp",
    "level",
    "duration",
    "http.response.statusCode",
  ]

  @aggregations_key "aggs"

  @default_filter %{"sort_by" => "timestamp", "sort_order" => "desc", "size" => 10}

  def index(conn, params) do
    query = DieScheiteApi.QueryBuilder.build_query(
      Map.merge(@default_filter, params),
      term_keys: @term_keys, range_keys: @range_keys, aggregations_key: @aggregations_key
    )

    case query |> post_query() |> parse_response() do
      {:ok, entries, aggs, total} ->
        conn |> put_status(:ok) |> json(%{entries: entries, aggs: aggs, total: total})
      {:error, error} ->
        Logger.error("Error #{inspect error} Query: #{inspect query}")
        conn |> put_status(:internal_server_error) |> json(%{errors: [error]})
    end
  end

  def post_query(query) do
    opts = Application.get_env(:die_scheite_api, :elastic)
    DieScheiteApi.ElasticClient.post_query(opts[:url], opts[:index], query)
  end

  def parse_response(response), do: DieScheiteApi.ElasticClient.parse_response(response)
end
