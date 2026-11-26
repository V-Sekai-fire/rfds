# SPDX-License-Identifier: Apache-2.0 OR MIT
# Gate: churny literals in RFD prose do not rise; write them as &{repo/file/pin/measured}.
#
#     elixir scripts/check_rfd_literals.exs --base <ref>
#     elixir scripts/check_rfd_literals.exs --self-test

defmodule RfdText do
  @moduledoc false
  # An RFD journal's text as the prose gates read it, from `mix rfd.text`.
  # The first lookup at a revision reads every RFD journal in one `mix rfd.text`.
  def get(repo, rev, path) do
    key = {__MODULE__, repo, rev}

    texts =
      Process.get(key) ||
        (fn ->
           t = fetch(repo, rev, Path.wildcard(Path.join(repo, "rfd/[0-9][0-9][0-9][0-9]-*.txn")))
           Process.put(key, t)
           t
         end).()

    Map.get(texts, path) || fetch(repo, rev, [Path.join(repo, path)]) |> Map.get(path)
  end

  defp fetch(repo, rev, fulls) do
    paths = Enum.map(fulls, &Path.relative_to(&1, repo))
    args = ["rfd.text"] ++ if(rev, do: ["--rev", rev], else: []) ++ paths

    case System.cmd("mix", args, cd: repo) do
      {out, 0} ->
        for line <- String.split(out, "\n", trim: true),
            String.starts_with?(line, "{"),
            t = JSON.decode!(line),
            into: %{},
            do: {t["path"], t}

      {out, _} ->
        raise "mix rfd.text failed: #{out}"
    end
  end

  def rfd?(path), do: path =~ ~r"^rfd/[0-9]{4}-[^/]+[.]txn$"

  def markdown(repo, rev, path) do
    case get(repo, rev, path) do
      %{"found" => true, "markdown" => md} -> md
      _ -> nil
    end
  end
end

defmodule Literals do
  @side "transport|contract|interactor|entities|repository|datasource|service"
  @kinds [
    side_path: ~r/\b[1-7]-(?:#{@side})\/[\w.-]+/,
    own_org: ~r/\b(?:V-Sekai-fire|chibifire-stages)\/[\w.-]+/i,
    project: ~r/`(?:#{@side}|manuals|frame)-[\w.-]+`/,
    sha: ~r/(?<![\w.#-])(?=[0-9a-f]*\d)(?=[0-9a-f]*[a-f])[0-9a-f]{7,40}(?![\w-])/,
    file_line: ~r/\b[\w.\/-]+\.[A-Za-z]\w{0,5}(?::\d+(?:-\d+)?|#L\d+(?:-L?\d+)?)\b/,
    branch: ~r/\b(?:feat|fix|archived)\/[\w.-]+/,
    pr: ~r/\bPR #\d+|(?<![\w&#])#\d+\b|\bpull\/\d+/
  ]
  @strict [:file_line, :branch, :pr]
  @span ~r/&\{(?:[^{}"]|"(?:\\.|[^"\\])*"|\{[^{}]*\})*\}/
  @stub ~r/^\s*abandoned_at\s+"[0-9a-f]+"\s*$/m

  def count(nil), do: {%{}, 0}

  def count(text) do
    {prose, fenced} =
      text
      |> String.replace(@span, " ")
      |> String.replace(@stub, "")
      |> String.split("\n")
      |> Enum.reduce({[], [], false}, fn line, {p, f, inside} ->
        cond do
          String.starts_with?(String.trim_leading(line), "```") -> {p, f, not inside}
          inside -> {p, [line | f], inside}
          true -> {[line | p], f, inside}
        end
      end)
      |> then(fn {p, f, _} -> {Enum.join(p, "\n"), Enum.join(f, "\n")} end)

    {tally(prose), tally(fenced) |> Map.values() |> Enum.sum()}
  end

  defp tally(text), do: Map.new(@kinds, fn {k, re} -> {k, length(Regex.scan(re, text))} end)

  @doc "{:pass | :fail, reasons, fenced} for one file, before (nil when new) and after."
  def judge(before, after_text) do
    {was, _} = count(before)
    {now, fenced} = count(after_text)
    total = fn m -> m |> Map.values() |> Enum.sum() end

    reasons =
      if(total.(now) > total.(was),
        do: ["literals #{total.(was)} -> #{total.(now)}"],
        else: []
      ) ++
        for k <- @strict, Map.get(now, k, 0) > Map.get(was, k, 0), do: "adds a #{k}"

    {if(reasons == [], do: :pass, else: :fail), reasons, fenced}
  end

  def git(repo, args) do
    case System.cmd("git", ["-C", repo | args], stderr_to_stdout: true) do
      {out, 0} -> {:ok, out}
      {out, _} -> {:error, out}
    end
  end

  def check(repo, base) do
    with {:ok, _} <- git(repo, ["rev-parse", "--verify", "--quiet", base <> "^{commit}"]),
         {:ok, mb} <- git(repo, ["merge-base", base, "HEAD"]),
         diff = ["diff", "--name-status", "-M", "--diff-filter=AMR", String.trim(mb)],
         {:ok, names} <- git(repo, diff) do
      mb = String.trim(mb)

      files =
        for line <- String.split(names, "\n", trim: true),
            [_ | paths] = String.split(line, "\t"),
            path = List.last(paths),
            path =~ ~r"^rfd/[0-9]{4}-[^/]+[.](exs|txn)$",
            do: {hd(paths), path}

      bad =
        for {old, path} <- files, reduce: 0 do
          acc ->
            {before, now} =
              if RfdText.rfd?(path) do
                prev = RfdText.get(repo, mb, old)
                {prev["found"] && prev["raw"], RfdText.get(repo, nil, path)["raw"]}
              else
                {with({:ok, t} <- git(repo, ["show", "#{mb}:#{old}"]), do: t, else: (_ -> nil)),
                 File.read!(Path.join(repo, path))}
              end

            {verdict, reasons, fenced} = judge(before, now)
            if fenced > 0, do: IO.puts("  #{path}: #{fenced} in fences, unchecked")

            if verdict == :fail do
              IO.puts("  FAIL #{path}: #{Enum.join(reasons, "; ")}")
              acc + 1
            else
              acc
            end
        end

      IO.puts("#{bad} of #{length(files)} changed RFD source(s) add churny literals")
      if bad == 0, do: 0, else: 1
    else
      {:error, out} ->
        IO.puts("FAIL: base #{inspect(base)} is unreadable: #{String.trim(out)}")
        1
    end
  end

  defp fixture(seed, edits, ref) do
    tmp = Path.join(System.tmp_dir!(), "rfd-literals-#{System.unique_integer([:positive])}")
    File.mkdir_p!(Path.join(tmp, "rfd"))
    id = ["-c", "user.email=t@t", "-c", "user.name=t"]
    git(tmp, ["init", "-q"])
    File.write!(Path.join(tmp, "rfd/2999-t.exs"), seed)
    git(tmp, ["add", "-A"])
    git(tmp, id ++ ["commit", "-q", "-m", "base"])
    git(tmp, ["branch", "base"])

    for edit <- edits do
      case edit do
        {:mv, from, to} -> git(tmp, ["mv", from, to])
        {path, text} -> File.write!(Path.join(tmp, path), text)
      end
    end

    git(tmp, ["add", "-A"])
    git(tmp, id ++ ["commit", "-q", "--allow-empty", "-m", "head"])
    out = ExUnit.CaptureIO.capture_io(fn -> send(self(), {:code, check(tmp, ref)}) end)
    File.rm_rf!(tmp)
    receive do: ({:code, c} -> {c, out})
  end

  def self_test do
    base = "rfd 2999, \"t\", :discussion do\n  prose ~S\"\"\"\n  :: decision\n  Text.\n"
    sha = "`392beb7`"

    controls = [
      {"a bare side path added", base, base <> "See 3-interactor/foo.\n", :fail},
      {"the same as &{repo(..)}", base, base <> ~S|See &{repo("3-interactor/foo")}.| <> "\n",
       :pass},
      {"a file:line added", base, base <> "In tools/build.exs:27.\n", :fail},
      {"a branch added", base, base <> "On feat/x.\n", :fail},
      {"a PR number added", base, base <> "Landed in PR #12.\n", :fail},
      {"a bare SHA added", base, base <> "At #{sha}.\n", :fail},
      {"an unquoted SHA added", base, base <> "Last at 978ea6a.\n", :fail},
      {"a line anchor added", base, base <> "See ggml.c#L27.\n", :fail},
      {"a date is not a SHA", base, base <> "On 2026-08-29.\n", :pass},
      {"the SHA under abandoned_at", base, base <> "  abandoned_at \"392beb7\"\n", :pass},
      {"a literal moved, count unchanged", base <> "A feat/x.\nB.\n", base <> "B.\nA feat/x.\n",
       :pass},
      {"a literal inside a fence", base, base <> "```\n3-interactor/foo:12\n```\n", :pass},
      {"a new file with one literal", nil, base <> "See 3-interactor/foo.\n", :fail}
    ]

    fails =
      for {label, before, after_text, want} <- controls,
          {got, _, _} = judge(before, after_text),
          got != want do
        IO.puts("  FAIL #{label}: got #{got}, expected #{want}")
      end

    {_, _, fenced} = judge(base, base <> "```\n3-interactor/foo\n```\n")
    fails = if fenced == 1, do: fails, else: ["fenced count" | fails]

    seed = base <> "In 3-interactor/a and 3-interactor/b.\n"

    repo_controls = [
      {"a bad --base", [], "no-such-ref", 1},
      {"a literal added on HEAD", [{"rfd/2999-t.exs", seed <> "See 3-interactor/c.\n"}], "base",
       1},
      {"a clean edit on HEAD", [{"rfd/2999-t.exs", seed <> "More text.\n"}], "base", 0},
      {"a rename keeps its base count", [{:mv, "rfd/2999-t.exs", "rfd/2999-u.exs"}], "base", 0}
    ]

    fails =
      Enum.reduce(repo_controls, fails, fn {label, edits, ref, want}, acc ->
        {got, out} = fixture(seed, edits, ref)
        if got == want, do: acc, else: ["#{label}: got #{got}, expected #{want}: #{out}" | acc]
      end)

    Enum.each(fails, &IO.puts("  FAIL #{&1}"))
    n = length(controls) + 1 + length(repo_controls)

    if fails == [] do
      IO.puts("ok   #{n} of #{n} controls fired in both directions")
      0
    else
      IO.puts("#{length(fails)} of #{n} controls failed")
      1
    end
  end
end

ExUnit.start(autorun: false)

code =
  case OptionParser.parse(System.argv(), strict: [base: :string, self_test: :boolean]) do
    {[self_test: true], _, _} -> Literals.self_test()
    {[base: base], [], _} -> Literals.check(File.cwd!(), base)
    {[base: base], [repo], _} -> Literals.check(repo, base)
    _ -> IO.puts("usage: check_rfd_literals.exs --base <ref> [<repo>] | --self-test") && 2
  end

System.halt(code)
