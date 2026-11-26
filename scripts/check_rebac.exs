# SPDX-License-Identifier: Apache-2.0 OR MIT
# Gate: every CLAUDE.md rebac block is RFD66606-2200 tuples over the verbs that RFD declares.
#
# The verbs come from RFD66606-2200's `rebac` block as data (RFD66606-2291), not from a table
# scraped out of its rendered Markdown, and every rule lives in `RFD.ReBAC`, which the
# DSL applies when a source compiles. `mix rfd.rebac` runs this over the whole corpus;
# this script is the CLAUDE.md half, which a prek hook runs on its own.
#
# Usage:
#     mix run scripts/check_rebac.exs [--doc CLAUDE.md] [--rfd rfd/2200-rebac-agent-roles.txn]
#     mix run scripts/check_rebac.exs --self-test
#
# Exit codes: 0 every row is well formed, 1 a row is not or a precondition is unmet, 2 bad usage.

unless Code.ensure_loaded?(RFD.Txn) do
  for f <- ~w(lib/rfd/rebac.ex lib/rfd/ref.ex lib/rfd/rectgtn.ex lib/rfd/hide.ex lib/rfd/doc.ex
           lib/rfd/dsl.ex),
      do: Code.require_file(f)
end

defmodule ReBACGate do
  @rfd "rfd/2200-rebac-agent-roles.txn"

  @doc "The verbs an RFD source declares, as a set of atoms."
  def verbs(path) do
    if String.ends_with?(path, ".txn"),
      do: doc_verbs(RFD.Source.load(path)),
      else: compiled_verbs(path)
  end

  defp doc_verbs(%{rebac: nil}), do: MapSet.new()
  defp doc_verbs(%{rebac: rebac}), do: MapSet.new(RFD.ReBAC.verb_names(rebac))

  defp compiled_verbs(path) do
    Code.compiler_options(ignore_module_conflict: true)

    case Code.compile_file(path) do
      [{module, _} | _] ->
        case module.__rfd__().rebac do
          nil -> MapSet.new()
          rebac -> MapSet.new(RFD.ReBAC.verb_names(rebac))
        end

      [] ->
        MapSet.new()
    end
  end

  def check(doc_text, verbs) do
    if MapSet.size(verbs) == 0,
      do: ["the RFD declares no verbs"],
      else: RFD.ReBAC.document_problems(doc_text, verbs)
  end

  def run(argv) do
    case OptionParser.parse(argv, strict: [doc: :string, rfd: :string, self_test: :boolean]) do
      {[self_test: true], [], []} -> self_test()
      {opts, [], []} -> gate(opts[:doc] || "AGENTS.md", opts[:rfd] || @rfd)
      _ -> usage()
    end
  end

  defp usage do
    IO.puts(:stderr, "usage: elixir scripts/check_rebac.exs [--doc F] [--rfd F] | --self-test")
    System.halt(2)
  end

  defp gate(doc, rfd) do
    with {:ok, d} <- File.read(doc), true <- File.exists?(rfd) do
      vs = verbs(rfd)

      case check(d, vs) do
        [] ->
          rows = RFD.ReBAC.block_rows(d)
          denials = Enum.count(rows, fn {_, t} -> String.contains?(t, "--!") end)

          IO.puts(
            "check_rebac: #{length(rows)} rows in #{doc} (#{length(rows) - denials} grants, " <>
              "#{denials} denials) over #{MapSet.size(vs)} verbs from #{rfd}: PASS"
          )

        errors ->
          Enum.each(errors, &IO.puts("check_rebac: #{doc}: #{&1}"))
          System.halt(1)
      end
    else
      _ ->
        IO.puts("check_rebac: cannot read #{doc} or #{rfd}")
        System.halt(1)
    end
  end

  defp doc(rows), do: "Intro.\n\n```rebac\n" <> Enum.join(rows, "\n") <> "\n```\n"

  defp self_test do
    v = MapSet.new([:owns, :reaches, :may_use])

    controls = [
      {"a well-formed block passes",
       doc(["# grants", "", "a--owns--card", "a--!reaches--box  # no key"]), v, true},
      {"a kebab verb reads as its atom", doc(["a--may-use--card"]), v, true},
      {"an unknown verb fails", doc(["a--drives--card"]), v, false},
      {"a denial without its reason fails", doc(["a--!owns--card"]), v, false},
      {"an uppercase segment fails", doc(["A--owns--card"]), v, false},
      {"a repeated row fails", doc(["a--owns--card", "a--owns--card"]), v, false},
      {"a relation granted and denied fails", doc(["a--owns--card", "a--!owns--card # no"]), v,
       false},
      {"a document with no rebac block fails", "Nothing here.\n", v, false},
      {"an unclosed rebac block fails", "```rebac\na--owns--card\n", v, false},
      {"a row that is not a tuple fails", doc(["owns a card"]), v, false},
      {"an RFD that declares no verbs fails", doc(["a--owns--card"]), MapSet.new(), false}
    ]

    results =
      for {name, text, vs, want} <- controls do
        got = check(text, vs) == []
        IO.puts("  #{if got == want, do: "ok  ", else: "FAIL"} #{name}")
        got == want
      end

    passed = Enum.count(results, & &1)
    IO.puts("check_rebac self-test: #{passed}/#{length(results)} controls behave")
    if passed != length(results), do: System.halt(1)
  end
end

ReBACGate.run(System.argv())
