defmodule Appleseed.WeightedGraph do
  @moduledoc """
  SPDX-License-Identifier: GPL-2.0-only
  Copyright (C) 2022 Charles Moid
  Copyright (c) 2016 Arjan Scherpenisse

  This is a very simple implementation of a Graph. The main shape
  is copied from an implementation by Arjan (https://github.com/arjan/dag),and
  modified to add weights to the edges and remove the acyclicity constraint.

  One can add vertices, add edges with associated weights, and retrieve edges
  and vertices as lists.

  """

  alias __MODULE__, as: Graph
  alias Appleseed.Edge, as: Edge
  defstruct vertices: MapSet.new(), edges: MapSet.new()

  def create() do
    {:ok, %Graph{}}
  end

  def add_vertex(%Graph{} = d, vertex) do
    {:ok, %Graph{d | vertices: MapSet.put(d.vertices, vertex)}}
  end

  def vertices(%Graph{} = d) do
    Enum.to_list(d.vertices)
  end

  def edges(%Graph{} = d) do
    Enum.to_list(d.edges)
  end

  def add_edge(%Graph{} = d, src, tar, weight) do
    {:ok, edge} = Edge.create(src, tar, weight)

    with true <- Enum.member?(d.vertices, src),
         true <- Enum.member?(d.vertices, tar),
         {:exists, false} <- {:exists, Enum.member?(d.edges, edge)} do
      {:ok, %Graph{d | edges: MapSet.put(d.edges, edge)}}
    else
      false ->
        {:error, :invalid}

      {:exists, true} ->
        {:ok, d}
    end
  end
end
