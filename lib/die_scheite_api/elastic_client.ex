defmodule DieScheiteApi.ElasticClient do
  def post_query(url, index, query) do
    HTTPoison.post(
      "#{url}/#{index}/_search",
      Poison.encode!(query),
      ["Content-Type": "application/json"],
      [recv_timeout: 50_000]
    )
  end

  def get_template(url, name) do
    HTTPoison.get("#{url}/_template/#{name}")
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
      {:ok, data} ->
        {:ok, data}
      {:error, _} ->
        {:error, %{message: "Failed to parse response", code: "ERR_ELASTIC_PARSE_ERROR", data: body}}
    end
  end

  def parse_query_response(res) do
    case parse_response(res) do
      {:ok, result} ->
        {hits, total} = parse_resultset(result)
        {:ok, hits, total}
      err -> err
    end
  end

  def parse_resultset(result) do
      hits = result
                |> Map.get("hits")
                |> Map.get("hits")
                |> Enum.map(&Map.get(&1, "_source"))
      total = result
              |> Map.get("hits")
              |> Map.get("total")

      {hits, total}
  end
end
