defmodule Appleseed do
  @moduledoc """
  SPDX-License-Identifier: GPL-2.0-only
  Copyright (C) 2022 Charles Moid

  """

  alias Appleseed.WeightedGraph, as: Graph
  alias Appleseed.Vertex, as: V

  @d 0.85

  @t_c 0.01

  @in_0 200

  def trust(source, dag) do
    new_s = %V{source | energy: @in_0, trust: 0}
    v_0 = MapSet.put(MapSet.new(), new_s)
    trust_loop(source, v_0, dag)
  end

  defp trust_loop(source, vs, dag) do
    new_vs =
      Enum.reduce(vs, MapSet.new(), fn v, acc ->
        MapSet.put(acc, %V{v | energy: 0})
      end)

    {new_vs, dag} =
      Enum.reduce(vs, {new_vs, dag}, fn v, acc ->
        n_vs = update_trust(elem(acc, 0), v)
        edges = Graph.edges(elem(acc, 1))

        Enum.reduce(edges, {n_vs, elem(acc, 1)}, fn e, acc2 ->
          if e.src.name == v.name do
            tar = e.tar

            new_tar =
              Enum.find(elem(acc2, 0), false, fn nv ->
                nv.name == tar.name
              end)

            new_d = elem(acc2, 1)
            new_vs = elem(acc2, 0)

            {new_tar, new_vs, new_d} =
              case new_tar do
                false ->
                  new_tar = %V{tar | energy: 0, trust: 0}
                  {:ok, new_d} = Graph.add_edge(new_d, tar, source, 1)
                  new_vs = MapSet.put(new_vs, new_tar)
                  {new_tar, new_vs, new_d}

                _all_val ->
                  {new_tar, new_vs, new_d}
              end

            w = comp_weight(e, new_d)

            new_nv = %V{
              new_tar
              | energy:
                  new_tar.energy +
                    @d * v.energy * w
            }

            new_vs = MapSet.delete(new_vs, new_tar)
            {MapSet.put(new_vs, new_nv), new_d}
          else
            acc2
          end
        end)
      end)

    m = compute_max(new_vs, vs)

    if m <= @t_c do
      res = collect_trusts(new_vs)

      Enum.map(res, fn t ->
        IO.puts("v: #{hd(t)} t: #{hd(tl(t))}")
      end)
    else
      trust_loop(source, new_vs, dag)
    end
  end

  defp compute_max(new_vs, old_vs) do
    Enum.reduce(new_vs, 0, fn nv, acc ->
      ov =
        Enum.find(old_vs, false, fn v ->
          nv.name == v.name
        end)

      case ov do
        false ->
          acc

        old_v ->
          diff = abs(nv.trust - old_v.trust)
          max(diff, acc)
      end
    end)
  end

  defp collect_trusts(new_vs) do
    Enum.map(new_vs, fn v ->
      [v.name, v.trust]
    end)
  end

  defp comp_weight(e, dag) do
    e.weight /
      List.foldl(Graph.edges(dag), 0, fn edg, acc ->
        if edg.src.name == e.src.name do
          acc + edg.weight
        else
          acc
        end
      end)
  end

  defp update_trust(new_vs, v) do
    new_trust = v.trust + (1 - @d) * v.energy

    new_v =
      Enum.find(new_vs, fn ov ->
        ov.name == v.name
      end)

    upd_new_v = %V{new_v | trust: new_trust}
    new_vs = MapSet.delete(new_vs, new_v)
    MapSet.put(new_vs, upd_new_v)
  end

  defp print(v) do
    IO.puts("")
    IO.puts("name: #{v.name}")
    IO.puts("  energy: #{v.energy}")
    IO.puts("  trust: #{v.trust}")
  end

  defp print_set(set) do
    Enum.map(set, fn s ->
      print(s)
      IO.puts("")
    end)
  end
end
