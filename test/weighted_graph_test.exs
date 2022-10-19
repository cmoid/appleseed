defmodule AppleseedWeightedGraphTest do
  use ExUnit.Case
  doctest Appleseed.WeightedGraph

  alias Appleseed.WeightedGraph, as: Graph
  alias Appleseed.Vertex, as: V

  test "create" do
    assert {:ok, %Graph{}} = Graph.create()
  end

  test "add vertex" do
    {:ok, d} = Graph.create()
    {:ok, v1} = V.create("v1")
    {:ok, d} = Graph.add_vertex(d, v1)
    {:ok, ^d} = Graph.add_vertex(d, v1)

    assert [v1] == Graph.vertices(d)

    {:ok, v2} = V.create("v2")

    {:ok, d} = Graph.add_vertex(d, v2)
    assert [v1, v2] == Graph.vertices(d)
  end

  test "add edge" do
    {:ok, d} = Graph.create()
    {:ok, v1} = V.create("v1")
    {:ok, v2} = V.create("v2")
    {:ok, d} = Graph.add_vertex(d, v1)
    {:ok, d} = Graph.add_vertex(d, v2)
    {:ok, d} = Graph.add_edge(d, v1, v2, 1)
    assert length(Graph.edges(d)) == 1
  end
end
