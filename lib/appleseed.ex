defmodule Appleseed do
  @moduledoc """
  SPDX-License-Identifier: GPL-2.0-only
  Copyright (C) 2022 Charles Moid

  """

  alias Appleseed.WeightedDag, as: Dag
  alias Appleseed.Vertex, as: V

  defp d() do
    0.85
  end

  defp t_c() do
    0.01
  end

  defp in_0() do
    200
  end

  def trust(source, dag) do
    new_s = %V{source | energy: in_0(), trust: 0}
    v_0 = MapSet.put(MapSet.new(), new_s)
    trust_loop(source, v_0, dag)
  end

  defp trust_loop(source, vs, dag) do
    IO.puts("The size of incoming vertices: #{MapSet.size(vs)}")

    new_vs =
      Enum.reduce(vs, MapSet.new(), fn v, acc ->
        new_v = %V{v | energy: 0}
        MapSet.put(acc, new_v)
      end)

    {new_vs, dag} =
      Enum.reduce(vs, {new_vs, dag}, fn v, acc ->
        new_vs = update_trust(elem(acc, 0), v)
        edges = Dag.edges(elem(acc, 1))

        Enum.reduce(edges, {new_vs, dag}, fn e, acc ->
          if e.src.name == v.name do
            tar = e.tar
            IO.puts("Found new vertex: #{tar.name}")

            new_tar =
              Enum.find(new_vs, false, fn nv ->
                nv.name == tar.name
              end)

            case new_tar do
              false ->
                IO.puts("New vertex not in new set: #{tar.name}")
                new_v = %V{tar | energy: 0, trust: 0}
                {:ok, new_d} = Dag.add_edge(elem(acc, 1), tar, source, 1)
                {MapSet.put(elem(acc, 0), new_v), new_d}

              nv ->
                w = comp_weight(e, dag)
                new_nv = %V{nv | energy: nv.energy + d() * old_energy(nv, vs) * w}
                new_vs = MapSet.delete(elem(acc, 0), nv)
                {MapSet.put(new_vs, new_nv), elem(acc, 1)}
            end
          else
            acc
          end
        end)
      end)

    IO.puts("new set: #{MapSet.size(new_vs)} and old set: #{MapSet.size(vs)}")
    m = compute_max(new_vs, vs)

    if m <= t_c() do
      IO.puts("Max is: #{m}")
      collect_trusts(new_vs)
    else
      trust_loop(source, new_vs, dag)
    end
  end

  defp compute_max(new_vs, old_vs) do
    IO.puts("new size: #{MapSet.size(new_vs)} and old size: #{MapSet.size(old_vs)}")

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

  defp old_energy(v, vs) do
    old_v =
      Enum.find(vs, false, fn ov ->
        ov.name == v.name
      end)

    case old_v do
      false ->
        0

      _ ->
        old_v.energy
    end
  end

  defp comp_weight(e, dag) do
    e.weight /
      List.foldl(Dag.edges(dag), 0, fn edg, acc ->
        if edg.src.name == e.src.name do
          acc + edg.weight
        else
          acc
        end
      end)
  end

  defp update_trust(new_vs, v) do
    new_trust = v.trust + (1 - d()) * v.energy

    new_v =
      Enum.find(new_vs, fn ov ->
        ov.name == v.name
      end)

    upd_new_v = %V{new_v | trust: new_trust}
    new_vs = MapSet.delete(new_vs, new_v)
    MapSet.put(new_vs, upd_new_v)
  end
end
