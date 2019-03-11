defmodule DieScheiteApi.QueryBuilder do
  def build_size(%{"_size" => size}), do: %{size: size}
  def build_size(_), do: %{}

  def build_sort(%{"_sort_by" => sort_by, "_sort_order" => sort_order}),
    do: %{sort: [Map.new([{sort_by, %{order: sort_order}}])]}
  def build_sort(%{"_sort_by" => sort_by}),
    do: %{sort: [sort_by]}
  def build_sort(_),
    do: %{}

  def build_aggregations(terms),
    do: %{aggregations: Enum.reduce(terms, %{}, &Map.put(&2, &1, %{terms: %{field: &1, size: 100}}))}
end
