defmodule DieScheiteApi.QueryBuilderTest do
  use ExUnit.Case, async: true

  @term_keys [ "ta", "tb", "tc" ]
  @range_keys [ "ra", "rb", "rc" ]

  test "single term filter" do
    params = %{"ta" => "A"}
    assert query_from_must([%{term: %{"ta" => "A"}}]) == build_query(params)
  end

  test "single terms filter" do
    params = %{"ta" => ["A", "B"]}
    assert query_from_must([%{terms: %{"ta" => ["A","B"]}}]) == build_query(params)
  end

  test "term and terms filter" do
    params = %{"ta" => ["A", "B"], "tb" => "C"}
    assert query_from_must([%{terms: %{"ta" => ["A","B"]}}, %{term: %{"tb" => "C"}}]) == build_query(params)
  end

  test "from range filter" do
    params = %{"ra_from" => "A"}
    assert query_from_must([%{range: %{"ra" => %{gte: "A"}}}]) == build_query(params)
  end

  test "to range filter" do
    params = %{"ra_to" => "A"}
    assert query_from_must([%{range: %{"ra" => %{lte: "A"}}}]) == build_query(params)
  end

  test "in range filter" do
    params = %{"ra_from" => "A", "ra_to" => "B"}
    assert query_from_must([%{range: %{"ra" => %{gte: "A", lte: "B"}}}]) == build_query(params)
  end

  test "sort by" do
    params = %{"sort_by" => "ta"}
    assert empty_query(%{sort: ["ta"]}) == build_query(params)
  end

  test "sort by order" do
    params = %{"sort_by" => "ta", "sort_order" => "asc"}
    assert empty_query(%{sort: [%{"ta" => %{order: "asc"}}]}) == build_query(params)
  end

  test "size" do
    params = %{"size" => 11}
    assert empty_query(%{size: 11}) == build_query(params)
  end

  test "ignore unknown keys" do
    params = %{"ua" => "A", "ub" => ["B", "C"]}
    assert empty_query(%{}) == build_query(params)
  end

  test "everything" do
    params = %{
      "ta" => "A",
      "tb" => ["B", "C"],
      "ra_from" => "A",
      "rb_to" => "B",
      "rc_from" => "C",
      "rc_to" => "D",
      "sort_by" => "ta",
      "sort_order" => "desc",
      "size" => 12
    }

    assert Map.merge(
      empty_query(%{size: 12, sort: [%{"ta" => %{order: "desc"}}]}),
      query_from_must([
        %{term: %{"ta" => "A"}},
        %{terms: %{"tb" => ["B", "C"]}},
        %{range: %{"ra" => %{gte: "A"}}},
        %{range: %{"rb" => %{lte: "B"}}},
        %{range: %{"rc" => %{gte: "C", lte: "D"}}},
      ])
    ) == build_query(params)
  end

  defp build_query(params),
    do: DieScheiteApi.QueryBuilder.build_query(params, term_keys: @term_keys, range_keys: @range_keys)


  def empty_query(other), do: Map.merge(%{query: %{bool: %{must: []}}}, other)
  def query_from_must(must), do: %{query: %{bool: %{must: must}}} #, size: 10, sort: [%{"timestamp" => %{order: "desc"}}]}
end
