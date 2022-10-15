defmodule AppleseedWeightedDagTest do
  use ExUnit.Case
  doctest Appleseed.WeightedDag
  
  alias Appleseed.WeightedDag, as: Dag
  alias Appleseed.Vertex, as: V

  test "create" do
    assert {:ok, %Dag{}} = Dag.create()
  end

  test "add vertex" do
    {:ok, d} = Dag.create()
    {:ok, v1} = V.create("v1")
    {:ok, d} = Dag.add_vertex(d, v1)
    {:ok, ^d} = Dag.add_vertex(d, v1)

    assert [v1] == Dag.vertices(d)

    {:ok, v2} = V.create("v2")

    {:ok, d} = Dag.add_vertex(d, v2)
    assert [v1, v2] == Dag.vertices(d)
  end

  test "add edge" do
    {:ok, d} = Dag.create()
    {:ok, v1} = V.create("v1")
    {:ok, v2} = V.create("v2")
    {:ok, d} = Dag.add_vertex(d, v1)
    {:ok, d} = Dag.add_vertex(d, v2)
    {:ok, d} = Dag.add_edge(d, v1, v2, 1)
    assert length(Dag.edges(d)) == 1
    
  end
end
