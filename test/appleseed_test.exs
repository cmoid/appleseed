defmodule AppleseedTest do
  use ExUnit.Case
  doctest Appleseed
  alias Appleseed.WeightedGraph, as: Graph
  alias Appleseed.Vertex, as: V
  import Appleseed

  test "simple example" do
    {:ok, graph} = Graph.create()
    graph = create_vertices(["a", "b", "c"], graph)
    assert length(Graph.vertices(graph)) == 3

    graph = add_edge("a", "b", 0.5, graph)
    graph = add_edge("a", "c", 0.5, graph)
    assert length(Graph.edges(graph)) == 2

    source = find_vertex("a", Graph.vertices(graph))

    trust(source, graph)
  end

  test "thesis example" do
    {:ok, graph} = Graph.create()
    graph = create_vertices(["a", "b", "c", "d", "e", "f", "g"], graph)
    assert length(Graph.vertices(graph)) == 7

    graph = add_edge("a", "b", 0.7, graph)
    graph = add_edge("a", "d", 0.7, graph)
    graph = add_edge("b", "c", 0.25, graph)
    graph = add_edge("d", "e", 1.0, graph)
    graph = add_edge("d", "f", 1.0, graph)
    graph = add_edge("d", "g", 1.0, graph)
    assert length(Graph.edges(graph)) == 6

    source = find_vertex("a", Graph.vertices(graph))

    trust(source, graph)
  end

  test "thesis example2" do
    {:ok, graph} = Graph.create()
    graph = create_vertices(["a", "b", "c", "d", "x", "y"], graph)
    assert length(Graph.vertices(graph)) == 6

    graph = add_edge("a", "b", 0.8, graph)
    graph = add_edge("a", "c", 0.8, graph)
    graph = add_edge("b", "d", 0.8, graph)
    graph = add_edge("x", "y", 0.8, graph)
    assert length(Graph.edges(graph)) == 4

    source = find_vertex("a", Graph.vertices(graph))

    trust(source, graph)
  end

  defp create_vertices(vertices, graph) do
    Enum.reduce(vertices, graph, fn e, acc ->
      {:ok, v} = V.create(e)
      {:ok, acc} = Graph.add_vertex(acc, v)
      acc
    end)
  end

  defp add_edge(s, t, w, graph) do
    vertices = Graph.vertices(graph)
    s_v = find_vertex(s, vertices)
    t_v = find_vertex(t, vertices)
    {:ok, graph} = Graph.add_edge(graph, s_v, t_v, w)
    graph
  end

  defp find_vertex(name, vertices) do
    Enum.find(vertices, fn v ->
      v.name == name
    end)
  end
end
