defmodule AppleseedTest do
  use ExUnit.Case
  doctest Appleseed
  alias Appleseed.WeightedDag, as: Dag
  alias Appleseed.Vertex, as: V
  import Appleseed

  test "thesis example" do
    {:ok, dag} = Dag.create()
    dag = create_vertices(["a", "b", "c", "d", "e", "f", "g"], dag)
    assert length(Dag.vertices(dag)) == 7

    dag = add_edge("a", "b", 0.7, dag)
    dag = add_edge("a", "d", 0.7, dag)
    dag = add_edge("b", "c", 0.25, dag)
    dag = add_edge("d", "e", 1.0, dag)
    dag = add_edge("d", "f", 1.0, dag)
    dag = add_edge("d", "g", 1.0, dag)
    assert length(Dag.edges(dag)) == 6

    source = find_vertex("a", Dag.vertices(dag))

    trust(source, dag)
    
  end


  defp create_vertices(vertices, dag) do
    Enum.reduce(vertices, dag, fn e, acc ->
      {:ok, v} = V.create(e)
      {:ok, acc} = Dag.add_vertex(acc, v)
      acc
    end)
  end

  defp add_edge(s, t, w, dag) do
    vertices = Dag.vertices(dag)
    s_v = find_vertex(s, vertices)
    t_v = find_vertex(t, vertices)
    {:ok, dag} = Dag.add_edge(dag, s_v, t_v, w)
    dag
  end

  defp find_vertex(name, vertices) do
    Enum.find(vertices, fn v ->
        v.name == name
    end)
  end
end
