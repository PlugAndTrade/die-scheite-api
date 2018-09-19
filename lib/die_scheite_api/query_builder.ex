defmodule DieScheiteApi.QueryBuilder do
  def build_query(params, opts \\ []) do
    [
      build_size(params),
      build_sort(params),
      build_bool_query(params, Keyword.get(opts, :term_keys, []), Keyword.get(opts, :range_keys, [])),
      build_aggregations(Map.get(params, Keyword.get(opts, :aggregations_key, "aggregations"), []))
    ] |> Enum.reduce(%{}, &Map.merge/2)
  end

  def build_size(%{"size" => size}), do: %{size: size}
  def build_size(_), do: %{}

  def build_sort(%{"sort_by" => sort_by, "sort_order" => sort_order}),
    do: %{sort: [Map.new([{sort_by, %{order: sort_order}}])]}

  def build_sort(%{"sort_by" => sort_by}),
    do: %{sort: [sort_by]}

  def build_sort(_),
    do: %{}

  def build_aggregations(terms),
    do: %{aggregations: Enum.reduce(terms, %{}, &Map.put(&2, &1, %{terms: %{field: &1}}))}

  def build_bool_query(params, term_keys, range_keys),
    do: %{
      query: %{
        bool: %{
          must: build_terms(term_keys, params) ++ build_ranges(range_keys, params)
        }
      }
    }

  def build_terms(props, params), do: params
    |> Map.take(props)
    |> Enum.map(&build_term/1)

  def build_term({key, value}) when is_bitstring(value), do: %{term: Map.new([{key, value}])}

  def build_term({key, value}) when is_list(value), do: %{terms: Map.new([{key, value}])}

  def build_ranges(props, params), do: props
    |> Enum.map(&build_range(&1, Map.get(params, "#{&1}_from"), Map.get(params, "#{&1}_to")))
    |> Enum.reject(&is_nil/1)

  def build_range(_prop, nil, nil), do: nil

  def build_range(prop, nil, to), do: %{range: Map.new([{prop, %{lte: to}}])}

  def build_range(prop, from, nil), do: %{range: Map.new([{prop, %{gte: from}}])}

  def build_range(prop, from, to), do: %{range: Map.new([{prop, %{gte: from, lte: to}}])}
end
