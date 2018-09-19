defmodule DieScheiteApiWeb.EntriesController do
  use DieScheiteApiWeb, :controller
  require Logger

  @term_keys [
    "serviceId",
    "serviceInstanceId",
    "servcieVersion",
    "id",
    "parentId",
    "correlationId",
    "http.request.method",
    "http.request.uri",
    "http.request.host",
    "http.response.statusCode",
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

    HTTPoison.post(
      "#{opts[:url]}/#{opts[:index]}/_search",
      Poison.encode!(query),
      ["Content-Type": "application/json"]
    )
  end

  def parse_response({:error, %HTTPoison.Error{reason: :econnrefused}}),
    do: {:error, %{message: "Connection to elastic refused.", code: "ERR_ELASTIC_REFUSED"}}

  def parse_response({:error, %HTTPoison.Error{reason: :etimeout}}),
    do: {:error, %{message: "Connection to elastic timed out.", code: "ERR_ELASTIC_TIMEOUT"}}

  def parse_response({:error, %HTTPoison.Error{reason: reason}}),
    do: {:error, %{message: "Failed to query elastic with reason: '#{reason}'", code: "ERR_ELASTIC"}}

  def parse_response({:ok, %HTTPoison.Response{status_code: status, body: body}}) when status >= 400,
    do: {:error, %{message: "Elastic responded with #{status}", code: "ERR_ELASTIC", data: body}}

  def parse_response({:ok, %HTTPoison.Response{body: body}}) do
    case Poison.decode(body) do
      {:ok, result} ->
        entries = result
                  |> Map.get("hits")
                  |> Map.get("hits")
                  |> Enum.map(&Map.get(&1, "_source"))
        aggs = result
               |> Map.get("aggregations")
               |> Enum.map(fn {term, %{"buckets" => vals}} -> %{property: term, values: Enum.map(vals, &Map.get(&1, "key"))} end)
        total = result
                |> Map.get("hits")
                |> Map.get("total")

        {:ok, entries, aggs, total}
      {:error, _} ->
        {:error, %{message: "Failed to parse response", code: "ERR_ELASTIC_PARSE_ERROR", data: body}}
    end
  end
end
