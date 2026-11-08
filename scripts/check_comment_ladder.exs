# SPDX-License-Identifier: Apache-2.0 OR MIT
# Gate: a changed source file may not climb the comment-density ladder.
# The measurement is a port of comment_density.py, scoped to this repository.
#
# Usage:
#     elixir scripts/check_comment_ladder.exs [<repo>] [--base HEAD] [--baseline] [--self-test]
#
# Exit codes: 0 every changed file within its rung, 1 one climbed, 2 bad usage.

defmodule Density do
  @source_ext [".py", ".ex", ".exs"]
  @license ["# Copyright ", "# SPDX-License-Identifier:"]
  @quote ~r/\A([rRbBuUfFtT]{0,2})('''|"""|'|")/

  def source?(path), do: Path.extname(path) in @source_ext

  def lines(text), do: String.split(text, ~r/\r\n|[\n\r\v\f\x1c\x1d\x1e\x{85}\x{2028}\x{2029}]/u)

  def density(text, ext) do
    lines = lines(text)
    marked = if ext == ".py", do: python(text), else: elixir(lines)

    {com, code} =
      lines
      |> Enum.with_index(1)
      |> Enum.reject(fn {raw, _} ->
        String.trim(raw) == "" or String.starts_with?(raw, @license)
      end)
      |> Enum.reduce({0, 0}, fn {_, n}, {c, k} ->
        if MapSet.member?(marked, n), do: {c + 1, k}, else: {c, k + 1}
      end)

    total = com + code
    {com, code, if(total > 0, do: com / total, else: 0.0)}
  end

  defp elixir(lines) do
    lines
    |> Enum.with_index(1)
    |> Enum.reduce({MapSet.new(), false}, fn {raw, n}, {set, in_doc} ->
      s = String.trim(raw)

      cond do
        in_doc ->
          {MapSet.put(set, n), not String.contains?(s, ~s("""))}

        String.starts_with?(s, "#") ->
          {MapSet.put(set, n), false}

        String.starts_with?(s, ["@moduledoc", "@doc", "@shortdoc", "@typedoc"]) ->
          {MapSet.put(set, n), length(String.split(s, ~s("""))) == 2}

        true ->
          {set, false}
      end
    end)
    |> elem(0)
  end

  # Comment tokens plus bare string statements, as tokenize and ast see them.
  defp python(text) do
    text = String.replace(text, ~r/\r\n?/, "\n")
    st = %{line: 1, col: 0, depth: 0, cur: [], stmts: [], comments: MapSet.new()}

    case lex(text, st) do
      {:ok, st} -> Enum.reduce(docstrings(Enum.reverse(st.stmts)), st.comments, &MapSet.union/2)
      {:error, st} -> st.comments
    end
  end

  defp lex("", st), do: {:ok, flush(st)}
  defp lex("\\\n" <> rest, st), do: lex(rest, %{st | line: st.line + 1, col: 0})

  defp lex("\n" <> rest, st) do
    st = if st.depth == 0, do: flush(st), else: st
    lex(rest, %{st | line: st.line + 1, col: 0})
  end

  defp lex("#" <> _ = s, st) do
    st = %{st | comments: MapSet.put(st.comments, st.line)}

    case :binary.match(s, "\n") do
      {at, _} -> lex(binary_part(s, at, byte_size(s) - at), st)
      :nomatch -> lex("", st)
    end
  end

  defp lex("\t" <> rest, st), do: lex(rest, %{st | col: st.col + 8 - rem(st.col, 8)})
  defp lex(<<c, rest::binary>>, st) when c in [?\s, ?\f], do: lex(rest, %{st | col: st.col + 1})
  defp lex(";" <> rest, st) when st.depth == 0, do: lex(rest, flush(%{st | col: st.col + 1}))

  defp lex(<<c, rest::binary>>, st) when c in ~c"([{" do
    lex(rest, push(%{st | depth: st.depth + 1, col: st.col + 1}, {:op, <<c>>, st.line}))
  end

  defp lex(<<c, rest::binary>>, st) when c in ~c")]}" do
    lex(rest, push(%{st | depth: max(st.depth - 1, 0), col: st.col + 1}, {:op, <<c>>, st.line}))
  end

  defp lex(s, st) do
    case Regex.run(@quote, s) do
      [pre, prefix, q] ->
        p = String.downcase(prefix)
        rest = binary_part(s, byte_size(pre), byte_size(s) - byte_size(pre))

        case string_body(rest, q, String.contains?(p, ["f", "t"]), 0) do
          {:ok, body, rest} ->
            nl = length(String.split(body, "\n")) - 1
            kind = if String.contains?(p, ["f", "t", "b"]), do: :other_str, else: :str
            st = push(st, {kind, st.line, st.line + nl})
            lex(rest, %{st | line: st.line + nl, col: st.col + 1})

          :error ->
            {:error, st}
        end

      nil ->
        {tok, rest} = word(s, "")
        lex(rest, push(%{st | col: st.col + 1}, {:op, tok, st.line}))
    end
  end

  defp word(<<c::utf8, rest::binary>>, acc)
       when c in ?a..?z or c in ?A..?Z or c in ?0..?9 or c in [?_, ?.] or c > 127,
       do: word(rest, acc <> <<c::utf8>>)

  defp word(<<c::utf8, rest::binary>>, ""), do: {<<c::utf8>>, rest}
  defp word(rest, acc), do: {acc, rest}

  defp string_body(s, q, fmt, braces, acc \\ "")
  defp string_body("", _q, _fmt, _b, _acc), do: :error

  defp string_body(s, q, _fmt, 0, acc) when binary_part(s, 0, byte_size(q)) == q,
    do: {:ok, acc, binary_part(s, byte_size(q), byte_size(s) - byte_size(q))}

  defp string_body("\\" <> <<c, _::binary>> = s, q, true, b, acc) when c in [?{, ?}],
    do: string_body(binary_part(s, 1, byte_size(s) - 1), q, true, b, acc <> "\\")

  defp string_body("\\" <> <<c::utf8, rest::binary>>, q, fmt, b, acc),
    do: string_body(rest, q, fmt, b, acc <> "\\" <> <<c::utf8>>)

  defp string_body("\n" <> _, q, _fmt, 0, _acc) when byte_size(q) == 1, do: :error
  defp string_body("{{" <> rest, q, true, 0, acc), do: string_body(rest, q, true, 0, acc <> "{{")

  defp string_body("{" <> rest, q, true, b, acc),
    do: string_body(rest, q, true, b + 1, acc <> "{")

  defp string_body("}" <> rest, q, true, b, acc) when b > 0,
    do: string_body(rest, q, true, b - 1, acc <> "}")

  defp string_body(<<c, _::binary>> = s, q, true, b, acc) when b > 0 and c in [?', ?"] do
    case Regex.run(@quote, s) do
      [pre, _, inner] ->
        rest = binary_part(s, byte_size(pre), byte_size(s) - byte_size(pre))

        case string_body(rest, inner, false, 0) do
          {:ok, body, rest} -> string_body(rest, q, true, b, acc <> pre <> body <> inner)
          :error -> :error
        end
    end
  end

  defp string_body(<<c::utf8, rest::binary>>, q, fmt, b, acc),
    do: string_body(rest, q, fmt, b, acc <> <<c::utf8>>)

  defp string_body(<<c, rest::binary>>, q, fmt, b, acc),
    do: string_body(rest, q, fmt, b, acc <> <<c>>)

  defp push(st, tok) do
    tok = if st.cur == [], do: {:first, st.col, tok}, else: tok
    %{st | cur: [tok | st.cur]}
  end

  defp flush(%{cur: []} = st), do: st
  defp flush(st), do: %{st | cur: [], stmts: [Enum.reverse(st.cur) | st.stmts]}

  defp docstrings(stmts) do
    stmts
    |> Enum.reduce({[], []}, fn [{:first, indent, tok} | toks], {stack, found} ->
      stack = Enum.drop_while(stack, fn {i, _} -> i >= indent end)
      skip = match?([{_, true} | _], stack)
      all = [tok | toks]
      found = if not skip and bare_string?(all), do: [span(all) | found], else: found
      body = inline_body(all)
      orelse = match?({:op, w, _} when w in ["else", "finally"], tok)
      found = if not orelse and bare_string?(body), do: [span(body) | found], else: found

      stack =
        if match?({:op, ":", _}, List.last(all)),
          do: [{indent, match?({:op, w, _} when w in ["else", "finally"], tok)} | stack],
          else: stack

      {stack, found}
    end)
    |> elem(1)
  end

  @compound ~w(def class if elif else for while with try except finally async match case)

  # `def f(): "doc"` puts the body after the header's colon on the same line.
  defp inline_body([{:op, kw, _} | _] = toks) when kw in @compound, do: after_colon(toks, 0, 0)
  defp inline_body(_), do: []

  defp after_colon([], _d, _l), do: []
  defp after_colon([{:op, ":", _} | rest], 0, 0), do: rest
  defp after_colon([{:op, ":", _} | rest], 0, l), do: after_colon(rest, 0, l - 1)
  defp after_colon([{:op, "lambda", _} | rest], 0, l), do: after_colon(rest, 0, l + 1)

  defp after_colon([{:op, b, _} | rest], d, l) when b in ["(", "[", "{"],
    do: after_colon(rest, d + 1, l)

  defp after_colon([{:op, b, _} | rest], d, l) when b in [")", "]", "}"],
    do: after_colon(rest, max(d - 1, 0), l)

  defp after_colon([_ | rest], d, l), do: after_colon(rest, d, l)

  defp bare_string?([{:op, "(", _} | rest]) do
    case List.last(rest) do
      {:op, ")", _} -> bare_string?(Enum.drop(rest, -1))
      _ -> false
    end
  end

  defp bare_string?(toks), do: toks != [] and Enum.all?(toks, &match?({:str, _, _}, &1))

  defp span(toks) do
    lines =
      Enum.flat_map(
        toks,
        &(&1 |> Tuple.to_list() |> tl() |> Enum.filter(fn x -> is_integer(x) end))
      )

    MapSet.new(Enum.min(lines)..Enum.max(lines))
  end
end

defmodule Ladder do
  @frozen ["rfd/2", "changelog/", "data/"]
  @rungs [0.03, 0.05, 0.10, 0.15, 0.20, 0.25, 0.30, 0.35, 0.40]
  @entry 0.10
  @min_lines 100
  @git_env Enum.map(
             ~w(GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY
                GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_PREFIX GIT_COMMON_DIR),
             &{&1, nil}
           )

  def rung_of(ratio), do: Enum.find(@rungs, &(ratio <= &1 + 1.0e-9))

  def git(repo, args) do
    case System.cmd("git", ["-C", repo | args], env: @git_env, stderr_to_stdout: true) do
      {out, 0} -> out
      _ -> nil
    end
  end

  # Python's %.Nf: the float's exact value, rounded half to even.
  def f(x, d) do
    <<s::1, e::11, m::52>> = <<x::float>>
    {num, exp} = if e == 0, do: {m, -1074}, else: {m + Bitwise.bsl(1, 52), e - 1075}
    {num, den} = if exp >= 0, do: {num * 2 ** exp, 1}, else: {num, 2 ** -exp}
    n = num * 10 ** d
    {q, r} = {div(n, den), rem(n, den)}
    q = if 2 * r > den or (2 * r == den and rem(q, 2) == 1), do: q + 1, else: q
    digits = q |> Integer.to_string() |> String.pad_leading(d + 1, "0")
    {int, frac} = String.split_at(digits, -d)
    sign = if s == 1, do: "-", else: ""
    if d == 0, do: sign <> digits, else: sign <> int <> "." <> frac
  end

  defp renames(repo, base) do
    (git(repo, ["diff", "--name-status", "-M", base]) || "")
    |> String.split("\n", trim: true)
    |> Enum.reduce(%{}, fn line, m ->
      case String.split(line, "\t") do
        ["R" <> _, from, to] -> Map.put(m, to, from)
        _ -> m
      end
    end)
  end

  defp at_ref(repo, ref, path, moved) do
    case git(repo, ["show", "#{ref}:#{path}"]) do
      nil -> if Map.has_key?(moved, path), do: clean(git(repo, ["show", "#{ref}:#{moved[path]}"]))
      text -> clean(text)
    end
  end

  defp keep?(f), do: Density.source?(f) and not String.starts_with?(f, @frozen)

  defp changed(repo, base) do
    [
      ["diff", "--name-only", base],
      ~w(diff --name-only --cached),
      ~w(ls-files --others --exclude-standard)
    ]
    |> Enum.flat_map(&String.split(git(repo, &1) || ""))
    |> Enum.uniq()
    |> Enum.filter(&keep?/1)
    |> Enum.sort()
  end

  defp tracked(repo), do: String.split(git(repo, ["ls-files"]) || "") |> Enum.filter(&keep?/1)

  defp clean(nil), do: nil

  defp clean(bin) do
    bin = if String.valid?(bin), do: bin, else: String.replace_invalid(bin, "")
    String.replace(bin, ~r/\r\n?/, "\n")
  end

  defp read(repo, path) do
    case File.read(Path.join(repo, path)) do
      {:ok, bin} -> clean(bin)
      _ -> nil
    end
  end

  defp measure(path, text), do: Density.density(text, Path.extname(path))

  def check(repo, base, verbose \\ true) do
    moved = renames(repo, base)

    rows =
      for path <- changed(repo, base),
          now = read(repo, path),
          now != nil,
          {n_com, n_code, n_ratio} = measure(path, now),
          n_com + n_code >= @min_lines do
        {ceiling, was} =
          case at_ref(repo, base, path, moved) do
            nil ->
              {@entry, nil}

            before ->
              {b_com, _, was} = measure(path, before)
              rung = rung_of(was) || was
              {if(n_com <= b_com, do: rung, else: min(was, rung)), was}
          end

        {n_ratio <= ceiling + 1.0e-9, path, n_ratio, was, ceiling}
      end

    if verbose do
      if rows == [], do: IO.puts("no source files changed against #{base}")

      for {ok, path, ratio, was, ceiling} <- rows do
        was_s = if was == nil, do: "new", else: f(was * 100, 1) <> "%"

        IO.puts(
          "  #{String.pad_trailing(if(ok, do: "ok", else: "FAIL"), 4)} " <>
            "#{String.pad_trailing(path, 48)} #{String.pad_leading(f(ratio * 100, 1), 5)}%  " <>
            "was #{String.pad_leading(was_s, 6)}  " <>
            "rung #{String.pad_leading(f(ceiling * 100, 0), 4)}%"
        )
      end
    end

    fails = for {false, path, ratio, was, ceiling} <- rows, do: {path, ratio, ceiling, was}
    {length(rows), fails}
  end

  def baseline(repo) do
    vals =
      for path <- tracked(repo),
          text = read(repo, path),
          text != nil,
          {com, code, ratio} = measure(path, text),
          com + code >= @min_lines,
          do: {ratio, path}

    if vals == [] do
      IO.puts("no source files of #{@min_lines}+ lines")
      1
    else
      vals = Enum.sort(vals)
      only = Enum.map(vals, &elem(&1, 0))
      n = length(only)
      mid = div(n, 2)

      median =
        if rem(n, 2) == 1,
          do: Enum.at(only, mid),
          else: (Enum.at(only, mid - 1) + Enum.at(only, mid)) / 2

      pct = &(f(&1 * 100, 1) <> "%")
      IO.puts("  #{n} files of #{@min_lines}+ non-blank lines")
      IO.puts("  floor #{pct.(hd(only))} (#{elem(hd(vals), 1)})")

      IO.puts(
        "  median #{pct.(median)}   p90 #{pct.(Enum.at(only, trunc(n * 0.9)))}   " <>
          "max #{pct.(List.last(only))} (#{elem(List.last(vals), 1)})"
      )

      for r <- @rungs do
        label = String.pad_trailing(if(r == @entry, do: "<- entry", else: ""), 9)
        count = Enum.count(only, &(rung_of(&1) == r))
        IO.puts("    rung #{String.pad_leading(f(r * 100, 0), 2)}% #{label} #{count}")
      end

      IO.puts("    off the top         #{Enum.count(only, &(rung_of(&1) == nil))}")
      0
    end
  end

  defp fixture(repo, name, comments, code_lines \\ 180) do
    body =
      Enum.map_join(0..(comments - 1)//1, &"# note #{&1}\n") <>
        Enum.map_join(0..(code_lines - 1)//1, &"x#{&1} = #{&1}\n")

    File.write!(Path.join(repo, name), body)
  end

  defp run(repo, args), do: git(repo, args)

  defp flags?(repo, name),
    do: Enum.any?(elem(check(repo, "HEAD", false), 1), &(elem(&1, 0) == name))

  defp clean?(repo), do: elem(check(repo, "HEAD", false), 1) == []

  def controls do
    repo = Path.join(System.tmp_dir!(), "ladder-#{System.unique_integer([:positive])}")
    File.mkdir_p!(repo)
    run(repo, ~w(init -q))
    run(repo, ~w(config user.email gate@example.com))
    run(repo, ~w(config user.name gate))
    fixture(repo, "a.py", 40)
    run(repo, ~w(add -A))
    run(repo, ~w(commit -qm base))

    fixture(repo, "a.py", 60)
    r1 = {"a file padded past its rung is rejected", flags?(repo, "a.py")}
    fixture(repo, "a.py", 43)
    r2 = {"a comment added inside the rung is rejected", flags?(repo, "a.py")}
    fixture(repo, "a.py", 40, 220)
    r3 = {"a file whose density falls is accepted", clean?(repo)}
    fixture(repo, "a.py", 40, 170)
    r4 = {"deleting code inside the rung is accepted, comments untouched", clean?(repo)}
    fixture(repo, "a.py", 40, 120)
    r5 = {"deleting code past the rung is rejected, comments untouched", flags?(repo, "a.py")}

    fixture(repo, "a.py", 40)
    fixture(repo, "new.py", 40)
    run(repo, ~w(add -A))
    r6 = {"a new file above the entry rung is rejected", flags?(repo, "new.py")}

    File.rm!(Path.join(repo, "new.py"))
    fixture(repo, "ok.py", 18)
    run(repo, ~w(add -A))
    r7 = {"a new file under the entry rung is accepted", clean?(repo)}

    fixture(repo, "three.py", 6, 250)
    run(repo, ~w(add -A))
    run(repo, ["commit", "-qm", "three base"])
    fixture(repo, "three.py", 6, 130)
    r8 = {"deleting code past the 3%% rung is rejected", flags?(repo, "three.py")}

    fixture(repo, "ok.py", 18)
    body = File.read!(Path.join(repo, "ok.py"))
    head = "# Copyright (c) 2026 someone\n# SPDX-License-Identifier: MIT\n"
    File.write!(Path.join(repo, "ok.py"), head <> body)
    run(repo, ~w(add -A))
    r9 = {"a licence header added to a file at its rung is accepted", not flags?(repo, "ok.py")}

    File.rm_rf!(repo)
    [r1, r2, r3, r4, r5, r6, r7, r8, r9]
  end

  def self_test do
    outer = Path.join(System.tmp_dir!(), "ladder-outer-#{System.unique_integer([:positive])}")
    File.mkdir_p!(outer)
    run(outer, ~w(init -q))
    run(outer, ~w(-c user.email=t@t -c user.name=t commit -q --allow-empty -m o))
    count = fn -> run(outer, ~w(rev-list --all --count)) end
    before = count.()
    System.put_env("GIT_DIR", Path.join(outer, ".git"))
    inner = controls()
    System.delete_env("GIT_DIR")
    kept = {"an inherited GIT_DIR gains no scratch commits", count.() == before}
    File.rm_rf!(outer)

    results = controls() ++ [kept]

    results =
      if Enum.all?(inner, &elem(&1, 1)),
        do: results,
        else: results ++ [{"controls under GIT_DIR", false}]

    bad = Enum.count(results, &(not elem(&1, 1)))

    for {name, got} <- results,
        do:
          IO.puts("  #{String.pad_trailing(if(got, do: "ok", else: "FAIL"), 4)} control: #{name}")

    IO.puts("  #{length(results) - bad} of #{length(results)} controls fired.")
    if bad == 0, do: 0, else: 1
  end

  def main(opts, repo) do
    cond do
      opts[:baseline] ->
        baseline(repo)

      opts[:self_test] ->
        self_test()

      true ->
        base = opts[:base] || "HEAD"
        {n, fails} = check(repo, base)
        IO.puts("")

        if fails != [] do
          for {path, ratio, ceiling, was} <- fails do
            verb = if was != nil, do: "sits on", else: "enters at"

            IO.puts(
              "#{path} is #{f(ratio * 100, 1)}% comments, " <>
                "above the #{f(ceiling * 100, 0)}% rung it #{verb}."
            )
          end

          IO.puts("Move the reasoning into the commit message.")
          1
        else
          IO.puts("#{n} changed source file(s) within their rung.")
          0
        end
    end
  end
end

switches = [base: :string, baseline: :boolean, self_test: :boolean]

case OptionParser.parse(System.argv(), strict: switches) do
  {opts, rest, []} when length(rest) <= 1 ->
    System.halt(Ladder.main(opts, List.first(rest) || "."))

  _ ->
    IO.puts(
      :stderr,
      "usage: check_comment_ladder.exs [repo] [--base BASE] [--baseline] [--self-test]"
    )

    System.halt(2)
end
