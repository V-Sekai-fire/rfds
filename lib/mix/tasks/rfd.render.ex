# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT

defmodule Mix.Tasks.Rfd.Render do
  @shortdoc "Render rfd/NNNN-slug.txn into rfd/NNNN-slug/ and the registers into SERIALS*.usda"
  @moduledoc """
      mix rfd.render [--check] [NAME ...]

  NAME is `NNNN-slug`, `rfd/NNNN-slug.txn`, a directory or `journal/serials.txn`; with
  none, every source is rendered. The registers are built from the journals, so
  `journal/serials.txn` renders every `SERIALS*.usda`. `--check` writes nothing and
  fails on drift.
  """
  use Mix.Task

  @impl true
  def run(args) do
    {opts, names, _} = OptionParser.parse(args, strict: [check: :boolean])

    sources =
      if names == [],
        do: RFD.Source.all() ++ RFD.Source.registers(),
        else: Enum.map(names, &RFD.Source.at/1)

    if sources == [], do: Mix.raise("no rfd/*.txn found")

    results = Enum.map(sources, &RFD.Source.render(&1, opts))
    bad = Enum.filter(results, &match?({:drift, _, _}, &1))

    for r <- results do
      case r do
        {:ok, name, files} -> Mix.shell().info("ok    #{name}: #{Enum.join(files, ", ")}")
        {:same, name} -> Mix.shell().info("same  #{name}")
        {:drift, name, files} -> Mix.shell().error("DRIFT #{name}: #{Enum.join(files, ", ")}")
      end
    end

    Mix.shell().info("rendered #{length(results)} source(s)")
    if bad != [], do: Mix.raise("#{length(bad)} rendered file(s) differ from their source")
  end
end

defmodule Mix.Tasks.Rfd.Check do
  @shortdoc "Compile every RFD and register source; one outside RFD66606-1000's shape fails here"
  @moduledoc false
  use Mix.Task

  @impl true
  def run(args) do
    {_, names, _} = OptionParser.parse(args, strict: [])

    sources =
      if names == [],
        do: RFD.Source.all() ++ RFD.Source.registers(),
        else: Enum.map(names, &RFD.Source.at/1)

    Code.compiler_options(ignore_module_conflict: true)

    bad =
      for path <- sources, reduce: [] do
        acc ->
          try do
            RFD.Source.load(path)
            acc
          rescue
            e ->
              Mix.shell().error("FAIL #{Path.basename(path)}: #{Exception.message(e)}")
              [path | acc]
          end
      end

    Mix.shell().info("#{length(sources) - length(bad)} of #{length(sources)} source(s) compile")
    if bad != [], do: Mix.raise("#{length(bad)} source(s) are outside RFD 1000's shape")
  end
end

defmodule Mix.Tasks.Rfd.Rebac do
  @shortdoc "Hold every rebac block against the verb vocabulary the corpus declares"
  @moduledoc false
  use Mix.Task

  @impl true
  def run(args) do
    {_, docs, _} = OptionParser.parse(args, strict: [])
    Code.compiler_options(ignore_module_conflict: true)

    blocks =
      for path <- RFD.Source.all(),
          doc = RFD.Source.load(path),
          doc.rebac != nil,
          do: {doc.serial, doc.rebac}

    vocabulary = Map.new(blocks, fn {serial, r} -> {serial, RFD.ReBAC.verb_names(r)} end)
    all_verbs = vocabulary |> Map.values() |> List.flatten() |> MapSet.new()

    problems =
      Enum.flat_map(blocks, fn {serial, r} ->
        missing = for s <- r.verbs_from, not Map.has_key?(vocabulary, s), do: s

        known =
          MapSet.new(
            RFD.ReBAC.verb_names(r) ++ Enum.flat_map(r.verbs_from, &Map.get(vocabulary, &1, []))
          )

        for reason <-
              for(s <- missing, do: "verbs_from #{s} names no RFD that declares verbs") ++
                RFD.ReBAC.problems(r, known),
            do: "RFD #{serial}: #{reason}"
      end) ++
        Enum.flat_map(if(docs == [], do: ["AGENTS.md"], else: docs), fn path ->
          for reason <- RFD.ReBAC.document_problems(File.read!(path), all_verbs),
              do: "#{path}: #{reason}"
        end)

    Enum.each(problems, &Mix.shell().error("FAIL #{&1}"))

    Mix.shell().info(
      "#{length(blocks)} rebac block(s) over #{MapSet.size(all_verbs)} verb(s), " <>
        "#{Enum.sum(for {_, r} <- blocks, do: length(r.tuples))} tuple(s), " <>
        "#{Enum.sum(for {_, r} <- blocks, do: length(r.capabilities))} capability(ies)"
    )

    if problems != [], do: Mix.raise("#{length(problems)} rebac problem(s)")
  end
end

defmodule Mix.Tasks.Rfd.Rectgtn do
  @shortdoc "Render the organization domain and one Taskweft problem per RFD"
  @moduledoc false
  use Mix.Task

  @impl true
  def run(args) do
    {opts, _, _} = OptionParser.parse(args, strict: [check: :boolean])
    Code.compiler_options(ignore_module_conflict: true)

    root = Path.join(RFD.Source.repo_root(), "rectgtn")
    problems = Path.join(root, "problems")
    unless opts[:check], do: File.mkdir_p!(problems)

    docs = for path <- RFD.Source.all(), do: RFD.Source.load(path)

    sources =
      [{Path.join(root, "organization.ex"), RFD.RECTGTN.domain_source()}] ++
        for doc <- docs do
          {Path.join(problems, "rfd_#{doc.serial}.ex"), RFD.RECTGTN.problem_source(doc)}
        end

    wanted =
      for {path, body} <- sources do
        {path, IO.iodata_to_binary(Code.format_string!(body, line_length: 98)) <> "\n"}
      end

    drift = for {path, body} <- wanted, File.read(path) != {:ok, body}, do: path

    cond do
      drift == [] ->
        Mix.shell().info("same  #{length(wanted)} rectgtn document(s)")

      opts[:check] ->
        for p <- drift, do: Mix.shell().error("DRIFT #{Path.relative_to_cwd(p)}")
        Mix.raise("#{length(drift)} rectgtn document(s) differ from their source")

      true ->
        for {path, body} <- wanted, path in drift, do: File.write!(path, body)

        Mix.shell().info(
          "ok    #{length(drift)} of #{length(wanted)} rectgtn document(s) written " <>
            "(#{Enum.count(docs, &(&1.steps != []))} with a declared critical path)"
        )
    end
  end
end

defmodule Mix.Tasks.Rfd.Usda do
  @shortdoc "Print the .usda rendering of one register to stdout"
  @moduledoc """
      mix rfd.usda NAME

  NAME is a register's name (`Weftspun`), its layer (`SERIALS.usda`), or a legacy
  `SERIALS*.exs` file, which is compiled as it was before the journals.
  """
  use Mix.Task

  @impl true
  def run([name]) do
    registers =
      if String.ends_with?(name, ".exs"),
        do: [RFD.Source.load(name)],
        else:
          Enum.filter(
            RFD.Register.from_journals(),
            &(name in [&1.name, RFD.Register.usda_name(&1)])
          )

    case registers do
      [r] -> Mix.shell().info(RFD.Register.usda(r))
      _ -> Mix.raise("no register #{name}")
    end
  end

  def run(_), do: Mix.raise("usage: mix rfd.usda NAME")
end

defmodule Mix.Tasks.Rfd.Serials do
  @shortdoc "Hold every register against the tree, and against a base revision"
  @moduledoc """
      mix rfd.serials [--base REF]

  The registers, built from the journals, against the sources on disk and, with
  `--base`, against a revision: no serial gone, none revived. A base revision may
  hold its registers as journals or as the `SERIALS*.exs` that came before them. A
  base with no register fails unless this change adds `journal/serials.txn`.
  `journal/serials.txn` must also be in its written form.
  """
  use Mix.Task

  @impl true
  def run(args) do
    {opts, _, _} = OptionParser.parse(args, strict: [base: :string])
    root = RFD.Source.repo_root()
    journal = Path.join(root, RFD.Register.Journal.path())
    unless File.exists?(journal), do: Mix.raise("no #{RFD.Register.Journal.path()}")

    text = File.read!(journal)
    registers = RFD.Register.from_journals(root)

    form =
      if RFD.Register.Journal.canonical(text) == text,
        do: [],
        else: ["#{RFD.Register.Journal.path()} is not in the form RFD.Register.Journal writes"]

    tree =
      for r <- registers,
          p <- RFD.Serials.tree_problems(r, RFD.Source.all()),
          do: "#{r.name}: #{p}"

    base =
      case opts[:base] do
        nil -> []
        ref -> RFD.Serials.against_base(registers, ref, root)
      end

    for r <- registers do
      {a, d} = RFD.Register.tables(r)
      Mix.shell().info("#{r.name}: #{map_size(a)} allocated, #{map_size(d)} deleted")
    end

    problems = form ++ tree ++ base
    for p <- problems, do: Mix.shell().error(p)
    Mix.shell().info("#{length(problems)} problem(s)")
    if problems != [], do: Mix.raise("the register and the tree disagree")
  end
end

defmodule RFD.Serials do
  @moduledoc "The register held against the tree and against its own previous revision."

  @doc "Reasons the register and the `rfd/*.txn` sources disagree."
  def tree_problems(%RFD.Register{} = r, sources) do
    {allocated, deleted} = RFD.Register.tables(r)
    site = r.layer[:site]

    on_disk =
      for path <- sources,
          name = path |> Path.basename() |> String.replace_suffix(".txn", ""),
          serial = String.to_integer(String.slice(name, 0, 4)),
          div(serial, 1000) == site,
          into: %{},
          do: {serial, String.slice(name, 5..-1//1)}

    dirs =
      for {serial, slug} <- Enum.sort(on_disk) do
        cond do
          not Map.has_key?(allocated, serial) ->
            "#{serial}-#{slug}: the source has no allocated row"

          allocated[serial] != slug ->
            "#{serial}: the register says #{allocated[serial]}, the source says #{slug}"

          true ->
            nil
        end
      end

    rows =
      for {serial, _} <- Enum.sort(allocated), not Map.has_key?(on_disk, serial) do
        "serial #{serial} is allocated and has no source"
      end

    gone =
      for {serial, _} <- Enum.sort(deleted), Map.has_key?(on_disk, serial) do
        "serial #{serial} is listed as deleted and has a source"
      end

    Enum.reject(dirs, &is_nil/1) ++ rows ++ gone
  end

  @doc "A serial the previous revision recorded is still recorded, and never revived."
  def base_problems(%RFD.Register{} = was, %RFD.Register{} = now) do
    {was_a, was_d} = RFD.Register.tables(was)
    {now_a, now_d} = RFD.Register.tables(now)
    present = Map.keys(now_a) ++ Map.keys(now_d)

    gone =
      for s <- Enum.sort(Map.keys(was_a) ++ Map.keys(was_d)), s not in present do
        "serial #{s} was in the register and is gone from it"
      end

    revived =
      for s <- Enum.sort(Map.keys(was_d)), Map.has_key?(now_a, s) do
        "serial #{s} was deleted and is allocated again"
      end

    gone ++ revived
  end

  @doc "Every register held against the registers at `ref`, matched by name."
  def against_base(registers, ref, root) do
    case base_registers(ref, root) do
      {:ok, was} ->
        now = Map.new(registers, &{&1.name, &1})
        sites = MapSet.new(was, & &1.layer[:site])

        gone =
          Enum.flat_map(was, fn w ->
            case now[w.name] do
              nil -> ["#{w.name}: the register was at #{ref} and is gone"]
              r -> for p <- base_problems(w, r), do: "#{w.name}: #{p}"
            end
          end)

        unheld =
          for r <- registers,
              not Enum.any?(was, &(&1.name == r.name)),
              MapSet.member?(sites, r.layer[:site]),
              do: "#{r.name}: no register #{r.name} at #{ref}, so nothing held it in place"

        gone ++ unheld

      :none ->
        if added?(ref, root),
          do: [],
          else: ["no register at #{ref}, so nothing held the registers in place"]
    end
  end

  @doc "The registers at `ref`: from its journals, or from the `SERIALS*.exs` before them."
  def base_registers(ref, root) do
    journal = RFD.Register.Journal.path()

    case System.cmd("git", ["cat-file", "-e", "#{ref}:#{journal}"],
           cd: root,
           stderr_to_stdout: true
         ) do
      {_, 0} -> {:ok, journal_registers(ref, root)}
      _ -> legacy_registers(ref, root)
    end
  end

  defp journal_registers(ref, root) do
    tmp = Path.join(System.tmp_dir!(), "rfd-serials-#{System.unique_integer([:positive])}")
    File.mkdir_p!(tmp)

    try do
      script = ~s(git archive "$1" journal rfd | tar -x -C "$2")

      case System.cmd("sh", ["-c", script, "sh", ref, tmp], cd: root, stderr_to_stdout: true) do
        {_, 0} -> RFD.Register.from_journals(tmp)
        {out, _} -> raise ArgumentError, "cannot read the journals at #{ref}: #{out}"
      end
    after
      File.rm_rf!(tmp)
    end
  end

  defp legacy_registers(ref, root) do
    case System.cmd("git", ["ls-tree", "--name-only", ref], cd: root, stderr_to_stdout: true) do
      {out, 0} ->
        files = for f <- String.split(out, "\n", trim: true), f =~ ~r/^SERIALS[^\/]*\.exs$/, do: f

        if files == [] do
          :none
        else
          {:ok,
           for f <- files do
             {text, 0} = System.cmd("git", ["show", "#{ref}:#{f}"], cd: root)
             RFD.Source.load_string(text, f)
           end}
        end

      {out, _} ->
        raise ArgumentError, "cannot read #{ref}: #{String.trim(out)}"
    end
  end

  defp added?(ref, root) do
    journal = RFD.Register.Journal.path()

    match?(
      {"A" <> _, 0},
      System.cmd("git", ["diff", "--name-status", "#{ref}...HEAD", "--", journal], cd: root)
    )
  end
end

defmodule RFD.Source do
  @moduledoc "Locate, compile and render the RFD and register sources."

  def repo_root, do: File.cwd!()
  def rfd_root, do: Path.join(repo_root(), "rfd")

  def all do
    rfd_root() |> Path.join("[0-9][0-9][0-9][0-9]-*.txn") |> Path.wildcard() |> Enum.sort()
  end

  @doc "The registers' source: `journal/serials.txn`, read with the RFD journals."
  def registers do
    path = Path.join(repo_root(), RFD.Register.Journal.path())
    if File.exists?(path), do: [path], else: []
  end

  @doc "Resolve `NNNN-slug`, `rfd/NNNN-slug.txn`, a directory, or `journal/serials.txn` to a source path."
  def at(name) do
    base =
      name
      |> Path.basename()
      |> String.replace_suffix(".exs", "")
      |> String.replace_suffix(".txn", "")

    if base == "serials" or String.starts_with?(base, "SERIALS"),
      do: Path.join(repo_root(), RFD.Register.Journal.path()),
      else: Path.join(rfd_root(), base <> ".txn")
  end

  def register?(path), do: Path.basename(path) == "serials.txn"

  @doc "The directory an RFD rendering goes to."
  def dir_of(path),
    do: path |> String.replace_suffix(".txn", "") |> String.replace_suffix(".exs", "")

  @doc """
  Compile one source and return its document; the compile itself validates it.
  `journal/serials.txn` gives every register, built and validated with the RFD journals.
  """
  def load(path) do
    cond do
      register?(path) -> RFD.Register.from_journals(Path.dirname(Path.dirname(path)))
      String.ends_with?(path, ".txn") -> load_txn(File.read!(path), path)
      true -> compile(path)
    end
  end

  defp load_txn(text, path) do
    RFD.Txn.parse!(text)
  rescue
    e in ArgumentError ->
      reraise ArgumentError, "#{path}: #{Exception.message(e)}", __STACKTRACE__
  end

  defp compile(path) do
    Code.compiler_options(ignore_module_conflict: true)
    path |> Code.compile_file() |> Enum.map(&elem(&1, 0)) |> pick(path)
  end

  @doc "Compile source text (a base revision read from git) the same way."
  def load_string(text, name) do
    if String.ends_with?(name, ".txn"), do: load_txn(text, name), else: compile_string(text, name)
  end

  defp compile_string(text, name) do
    Code.compiler_options(ignore_module_conflict: true)
    text |> Code.compile_string(name) |> Enum.map(&elem(&1, 0)) |> pick(name)
  end

  defp pick(mods, path) do
    docs =
      Enum.flat_map(mods, fn m ->
        cond do
          function_exported?(m, :__rfd__, 0) -> [m.__rfd__()]
          function_exported?(m, :__register__, 0) -> [m.__register__()]
          true -> []
        end
      end)

    case docs do
      [doc] -> doc
      [] -> raise ArgumentError, "#{path} defines no module that uses RFD.DSL or RFD.Register"
      many -> raise ArgumentError, "#{path} defines #{length(many)} documents; one per file"
    end
  end

  def render(path, opts) do
    if register?(path), do: render_register(path, opts), else: render_rfd(path, opts)
  end

  defp render_register(path, opts) do
    wanted = for r <- load(path), do: {RFD.Register.usda_name(r), RFD.Register.usda(r)}
    write("serials", repo_root(), wanted, opts)
  end

  defp render_rfd(path, opts) do
    dir = dir_of(path)
    name = Path.basename(dir)
    doc = load(path)

    if Integer.to_string(doc.serial) != String.slice(name, 0, 4) do
      raise ArgumentError, "#{path}: serial #{doc.serial} does not match the file name #{name}"
    end

    wanted =
      [{"README.md", RFD.Doc.readme(doc)}, {"DETAILS.md", RFD.Doc.details(doc)}]
      |> Enum.reject(fn {_, body} -> is_nil(body) end)

    case write(name, dir, wanted, opts) do
      {:drift, _, _} = drift -> drift
      rendered -> merge(rendered, write(name, repo_root(), regions!(path, doc), opts))
    end
  end

  # A `renders_into` in the RFD's rebac block owns the fenced `rebac` region of that document.
  defp regions!(path, %{rebac: %RFD.ReBAC{}} = doc) do
    for {doc_path, subject} <- doc.rebac.renders_into do
      full = Path.join(repo_root(), doc_path)
      text = File.read!(full)

      case RFD.ReBAC.put_block(text, RFD.ReBAC.rows_for(doc.rebac, subject)) do
        :no_block ->
          raise ArgumentError, "#{path}: #{doc_path} carries no rebac block to render into"

        body ->
          {doc_path, body}
      end
    end
  end

  defp regions!(_path, _doc), do: []

  defp merge({:same, name}, {:same, _}), do: {:same, name}
  defp merge({:same, _}, other), do: other
  defp merge(one, {:same, _}), do: one
  defp merge({tag, name, a}, {_, _, b}), do: {tag, name, a ++ b}

  defp write(name, dir, wanted, opts) do
    differing = for {n, body} <- wanted, File.read(Path.join(dir, n)) != {:ok, body}, do: n

    cond do
      differing == [] ->
        {:same, name}

      opts[:check] ->
        {:drift, name, differing}

      true ->
        File.mkdir_p!(dir)
        for {n, body} <- wanted, n in differing, do: File.write!(Path.join(dir, n), body)
        {:ok, name, differing}
    end
  end
end
