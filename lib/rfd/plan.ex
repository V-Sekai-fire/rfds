# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT

defmodule RFD.Plan do
  @moduledoc """
  An apparatus plan as Elixir data, checked for its shape while it compiles.

  Layer metadata, sublayers, `customLayerData`, nested prims, typed attributes and
  relationships. Nothing is rendered from it (operator, 2026-11-26).
  """

  @enforce_keys [:name]
  defstruct name: nil, meta: [], sublayers: [], data: [], prims: []

  @meta_keys ~w(metersPerUnit upAxis defaultPrim doc)a

  defmacro __using__(_) do
    quote do
      import RFD.Plan, only: [plan: 2]
    end
  end

  defmacro plan(name, do: block) do
    quote do
      import RFD.Plan.Fields
      @plan_doc RFD.Plan.build(unquote(name), unquote(collect(block)))
      import RFD.Plan.Fields, only: []
      def __plan__, do: @plan_doc
    end
  end

  @doc false
  def collect({:__block__, _, stmts}), do: {:__block__, [], []} |> with_list(stmts)
  def collect(nil), do: []
  def collect(stmt), do: with_list(nil, [stmt])

  defp with_list(_, stmts), do: quote(do: List.flatten([unquote_splicing(stmts)]))

  @doc false
  def build(name, entries) do
    %__MODULE__{
      name: name,
      meta: Keyword.take(flat_opts(entries, :meta), @meta_keys),
      sublayers: flat_list(entries, :sublayers),
      data: for({:data, k, t, v} <- entries, do: {k, t, v}),
      prims: for(%{__prim__: true} = p <- entries, do: p)
    }
    |> validate!()
  end

  defp flat_opts(entries, tag), do: for({^tag, kw} <- entries, kw <- kw, do: kw)
  defp flat_list(entries, tag), do: for({^tag, xs} <- entries, x <- xs, do: x)

  defmodule Fields do
    @moduledoc false
    alias RFD.Plan

    def meta(kw), do: {:meta, kw}
    def sublayers(paths), do: {:sublayers, paths}

    for t <- ~w(string token int bool float float3)a do
      def unquote(t)(key, value), do: {:data, key, unquote(to_string(t)), value}

      def unquote(:"#{t}_list")(key, values),
        do: {:data, key, unquote(to_string(t) <> "[]"), values}
    end

    def attr(key, type, value), do: {:attr, key, type, value, []}
    def attr(key, type, value, opts), do: {:attr, key, type, value, opts}
    def rel(name, target) when is_binary(target), do: {:rel, name, [target]}
    def rel(name, targets) when is_list(targets), do: {:rel, name, targets}

    def doc(text), do: {:doc, text}
    def prim(name, body), do: Plan.build_prim(:def, nil, name, body)
    def scope(name, body), do: Plan.build_prim(:def, "Scope", name, body)
    def over(name, body), do: Plan.build_prim(:over, nil, name, body)
  end

  @doc false
  def build_prim(kind, schema, name, body) do
    body = body |> unblock() |> List.wrap() |> List.flatten()

    %{
      __prim__: true,
      kind: kind,
      schema: schema,
      name: name,
      doc:
        Enum.find_value(body, fn
          {:doc, d} -> d
          _ -> nil
        end),
      attrs: for({:attr, k, t, v, o} <- body, do: {k, t, v, o}),
      rels: for({:rel, n, ts} <- body, do: {n, ts}),
      children: for(%{__prim__: true} = c <- body, do: c)
    }
  end

  defp unblock([{:do, inner}]), do: inner
  defp unblock(other), do: other

  @doc "Every rule a plan has to meet, as the list of reasons it does not."
  def problems(%__MODULE__{} = p) do
    []
    |> check(is_binary(p.name) and p.name =~ ~r/^[A-Za-z][A-Za-z0-9_]*$/, "prim-safe name")
    |> check(p.prims != [], "a plan with no prim is empty")
    |> check(
      p.meta[:defaultPrim] in [nil | Enum.map(p.prims, & &1.name)],
      "defaultPrim #{inspect(p.meta[:defaultPrim])} names no prim in this layer"
    )
    |> Kernel.++(Enum.flat_map(p.prims, &prim_problems/1))
    |> Enum.reverse()
  end

  defp prim_problems(prim) do
    here =
      []
      |> check(
        is_binary(prim.name) and prim.name =~ ~r/^[A-Za-z][A-Za-z0-9_]*$/,
        "prim #{inspect(prim.name)} is not a prim-safe name"
      )
      |> check(
        Enum.all?(prim.rels, fn {_, ts} -> Enum.all?(ts, &String.starts_with?(&1, "/")) end),
        "prim #{prim.name}: a relationship target is an absolute prim path"
      )

    here ++ Enum.flat_map(prim.children, &prim_problems/1)
  end

  defp check(acc, true, _), do: acc
  defp check(acc, false, msg), do: [msg | acc]

  def validate!(%__MODULE__{} = p) do
    case problems(p) do
      [] ->
        p

      ps ->
        raise ArgumentError, "plan #{p.name} is outside its shape:\n  " <> Enum.join(ps, "\n  ")
    end
  end
end
