defmodule DieScheiteApiWeb.EntriesController do
  use DieScheiteApiWeb, :controller
  require Logger

  @default_options %{"_sort_by" => "timestamp", "_sort_order" => "desc", "_size" => 10}

  @es_query_options [
    "_size",
    "_sort_by",
    "_sort_order",
    "_debug",
    "_aggs"
  ]

  def index(conn, params) do
    opts = Application.get_env(:die_scheite_api, :elastic)

    with {:ok, {mappings, index}} <- get_template(),
         {:ok, filter} <- build_filters(mappings, Map.drop(params, @es_query_options)),
         {:ok, aggregations} <- build_aggregations(mappings, Map.get(params, "_aggs", [])),
         query_options <- build_options(params),
         query <- Enum.reduce([filter, aggregations, query_options], %{}, &Map.merge/2),
         {:ok, entries, aggs, total} <- post_query(query, opts[:url], index) do
      result = case params do
        %{"_debug" => "false"} -> %{resultset: entries, aggregations: aggs, total: total}
        %{"_debug" => _} -> %{resultset: entries, aggregations: aggs, total: total, query: query}
        _ -> %{resultset: entries, aggregations: aggs, total: total}
      end
      conn |> put_status(:ok) |> json(result)
    else
      {:error, errors} when is_list(errors)->
        Logger.error("Errors #{inspect errors}")
        conn |> put_status(:internal_server_error) |> json(%{errors: errors})
      {:error, error} ->
        Logger.error("Error #{inspect error}")
        conn |> put_status(:internal_server_error) |> json(%{errors: [error]})
      err ->
        Logger.error("Unexpected result #{inspect err}")
        conn |> put_status(:internal_server_error) |> json(%{errors: [%{message: "Unknown error", code: "ERR_UNKNOWN"}]})
    end
  end

  def properties(conn, _params) do
    case get_template() do
      {:ok, {mappings, _}} ->
        props = Esjql.Properties.unflatten(mappings)
        conn |> put_status(:ok) |> json(%{"properties" => props})
      {:error, errors} when is_list(errors)->
        Logger.error("Errors #{inspect errors}")
        conn |> put_status(:internal_server_error) |> json(%{errors: errors})
      {:error, error} ->
        Logger.error("Error #{inspect error}")
        conn |> put_status(:internal_server_error) |> json(%{errors: [error]})
      err ->
        Logger.error("Unexpected result #{inspect err}")
        conn |> put_status(:internal_server_error) |> json(%{errors: [%{message: "Unknown error", code: "ERR_UNKNOWN"}]})
    end
  end

  def get_template() do
    opts = Application.get_env(:die_scheite_api, :elastic)
    template = opts[:template]

    case DieScheiteApi.ElasticClient.get_template(opts[:url], template) |> DieScheiteApi.ElasticClient.parse_response() do
      {:ok, %{^template => %{
        "mappings" => mappings,
        "index_patterns" => indices
      }}} -> {:ok, {mappings |> Map.values() |> List.first(), Enum.join(indices, ",")}}
      err -> err
    end
  end

  def build_filters(mapping, params) do
    case Esjql.build_filters(mapping, params) do
      {:error, errors} -> {:error, Enum.map(errors, &Map.put(%{code: "ERR_FILTER"}, :message, &1))}
      res -> res
    end
  end

  def build_aggregations(mappings, properties) do
    case Esjql.Aggregation.build(mappings, properties, 50) do
      {:error, errors} -> {:error, Enum.map(errors, &Map.put(%{code: "ERR_AGGS"}, :message, &1))}
      res -> res
    end
  end

  def build_options(params) do
    params = Map.merge(@default_options, params)
    Map.merge(DieScheiteApi.QueryBuilder.build_sort(params), DieScheiteApi.QueryBuilder.build_size(params))
  end

  def post_query(query, url, index) do
    case DieScheiteApi.ElasticClient.post_query(url, index, query) |> DieScheiteApi.ElasticClient.parse_response() do
      {:error, err} -> {:error, Map.put(err, :query, query)}
      {:ok, response} ->
        {hits, total} = DieScheiteApi.ElasticClient.parse_resultset(response)
        aggs = Esjql.Aggregation.parse(response)
        {:ok, hits, aggs, total}
    end
  end
end
