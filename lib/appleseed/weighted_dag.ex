defmodule Appleseed.WeightedDag do
  @moduledoc """
  SPDX-License-Identifier: GPL-2.0-only
  Copyright (C) 2022 Charles Moid
  Copyright (c) 2016 Arjan Scherpenisse

  This is a very simple implementation of a Dag. The main shape
  is copied from an implementation by Arjan (https://github.com/arjan/dag),and
  modified to add weights to the edges. All the other
  functions were removed so that only what is needed for Appleseed
  is here.

  One can add vertices, add edges with associated weights, and retrieve edges
  and vertices as lists. When adding edges it will enforce the acyclic property

  """

  alias __MODULE__, as: Dag
  alias Appleseed.Edge, as: Edge
  defstruct vertices: MapSet.new(), edges: MapSet.new()

  def create() do
    {:ok, %Dag{}}
  end

  def add_vertex(%Dag{} = d, vertex) do
    {:ok, %Dag{d | vertices: MapSet.put(d.vertices, vertex)}}
  end

  def vertices(%Dag{} = d) do
    Enum.to_list(d.vertices)
  end

  def edges(%Dag{} = d) do
    Enum.to_list(d.edges)
  end

  def add_edge(%Dag{} = d, src, tar, weight) do
    {:ok, edge} = Edge.create(src, tar, weight)

    with true <- Enum.member?(d.vertices, src),
         true <- Enum.member?(d.vertices, tar),
         {:exists, false} <- {:exists, Enum.member?(d.edges, edge)} do
         ##{:path, false} <- {:path, path?(d, tar, src)} do
      {:ok, %Dag{d | edges: MapSet.put(d.edges, edge)}}
    else
      false ->
        {:error, :invalid}

      {:exists, true} ->
        {:ok, d}

      {:path, true} ->
        {:error, :cycle}
    end
  end

  def path?(%Dag{} = d, src, tar) do
    case Enum.any?(d.edges, fn e -> e.src == src and e.tar == tar end) do
      true ->
        true

      false ->
        outgoing(d, src)
        |> Enum.reduce_while(
          false,
          fn v, _ ->
            case path?(d, v, tar) do
              true -> {:halt, true}
              false -> {:cont, false}
            end
          end
        )
    end
  end

  def outgoing(%Dag{} = d, v) do
    d.edges
    |> Enum.filter(fn e -> e.src == v end)
    |> Enum.map(fn e -> e.tar end)
  end
end
