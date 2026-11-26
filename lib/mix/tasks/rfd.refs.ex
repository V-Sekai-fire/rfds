# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT

defmodule Mix.Tasks.Rfd.Refs.Update do
  @shortdoc "Resolve every &{...} in rfd/*.exs, write RFD.lock.exs, render"
  @moduledoc """
      mix rfd.refs.update [--manifest URL]

  The manifest is read at its published tip, the source `mix rfd.refs.check`
  reads, so the pair cannot disagree. `RFD_MANIFEST` overrides the URL.
  """
  use Mix.Task

  @manifest "https://github.com/chibifire-smoke-water/contract-manifest-smoke-water"

  def manifest_url, do: System.get_env("RFD_MANIFEST") || @manifest

  @impl true
  def run(args) do
    {opts, _, _} = OptionParser.parse(args, strict: [manifest: :string])
    url = opts[:manifest] || manifest_url()
    {_, commit} = tip!(url)

    xml =
      case blob(url, commit, "default.xml") do
        {:ok, text} -> text
        :error -> Mix.raise("default.xml is unreadable at #{commit} in #{url}")
      end

    calls = calls()
    lock = RFD.Ref.Snapshot.lock(calls, world(xml, commit, calls, url))

    File.write!(
      RFD.Ref.lock_path(),
      "# Written by `mix rfd.refs.update`; RFD prose resolves &{...} against it.\n" <>
        inspect(lock, pretty: true, limit: :infinity, printable_limit: :infinity) <> "\n"
    )

    Mix.shell().info("#{length(calls)} reference(s), #{map_size(lock.repos)} repo(s) locked")
    Mix.Task.run("rfd.render", [])
  end

  def calls do
    RFD.Source.all()
    |> Enum.flat_map(&RFD.Ref.calls(RFD.Txn.prose(RFD.Txn.parse_raw!(File.read!(&1)))))
    |> Enum.uniq()
  end

  def world(xml, commit, calls, url) do
    %{
      manifest: xml,
      manifest_url: url,
      legacy: legacy_projects(),
      commit: commit,
      archived: if(calls == [], do: %{}, else: archived!()),
      tip: &tip!/1,
      blob: &blob/3
    }
  end

  @legacy "https://github.com/V-Sekai-fire/contract-manifest-taskweft"

  defp legacy_projects do
    {_, commit} = tip!(@legacy)

    case blob(@legacy, commit, "default.xml") do
      {:ok, text} -> RFD.Ref.Snapshot.projects(text, @legacy)
      :error -> %{}
    end
  end

  defp repo_of(url), do: url |> URI.parse() |> Map.fetch!(:path) |> String.trim("/")

  defp archived! do
    fire = gh_list(~w(repo list V-Sekai-fire --archived --limit 2000 --json name --jq .[].name))
    archive = gh_list(~w(repo list V-Sekai-archive --limit 2000 --json name --jq .[].name))

    Map.new(fire, &{&1, "https://github.com/V-Sekai-fire/#{&1}"})
    |> Map.merge(Map.new(archive, &{&1, "https://github.com/V-Sekai-archive/#{&1}"}))
  end

  defp gh_list(args) do
    case System.cmd("gh", args, env: gh_env(), stderr_to_stdout: true) do
      {out, 0} -> String.split(out)
      {out, _} -> Mix.raise("gh #{Enum.join(args, " ")} failed: #{out}")
    end
  end

  defp gh_env do
    token =
      Enum.find([System.get_env("RFD_TOKEN"), System.get_env("GH_TOKEN")], &(&1 not in [nil, ""]))

    [{"GH_TOKEN", token || ""}]
  end

  def tip!(url) do
    case System.cmd("git", ["ls-remote", "--symref", url, "HEAD"], stderr_to_stdout: true) do
      {out, 0} ->
        [_, branch] = Regex.run(~r{ref: refs/heads/(\S+)\s+HEAD}, out)
        [_, sha] = Regex.run(~r/^([0-9a-f]{40})\s+HEAD$/m, out)
        {branch, sha}

      {_out, _} ->
        tip_via_api!(url)
    end
  end

  defp tip_via_api!(url) do
    repo = repo_of(url)
    branch = gh_out(["api", "repos/#{repo}", "--jq", ".default_branch"])
    sha = gh_out(["api", "repos/#{repo}/commits/#{branch}", "--jq", ".sha"])
    {branch, sha}
  end

  defp gh_out(args) do
    case System.cmd("gh", args, env: gh_env(), stderr_to_stdout: true) do
      {out, 0} -> String.trim(out)
      {out, _} -> Mix.raise("gh #{Enum.join(args, " ")} failed: #{out}")
    end
  end

  def blob(url, sha, path) do
    repo = url |> URI.parse() |> Map.fetch!(:path) |> String.trim("/")

    case System.cmd(
           "gh",
           ["api", "repos/#{repo}/contents/#{path}?ref=#{sha}"] ++
             ~w(-H Accept:application/vnd.github.raw),
           env: gh_env(),
           stderr_to_stdout: true
         ) do
      {out, 0} -> {:ok, out}
      _ -> :error
    end
  end
end

defmodule Mix.Tasks.Rfd.Restore do
  @shortdoc "Bring an abandoned RFD's last full source back from its abandoned_at commit"
  @moduledoc "    mix rfd.restore NNNN"
  use Mix.Task

  @impl true
  def run([serial]) do
    path =
      Path.wildcard(Path.join(RFD.Source.rfd_root(), "#{serial}-*.txn")) |> List.first() ||
        Mix.raise("no rfd/#{serial}-*.txn")

    sha = RFD.Source.load(path).abandoned_at || Mix.raise("RFD #{serial} has no abandoned_at")
    root = RFD.Source.repo_root()

    case Enum.filter(RFD.Ref.sources_at(root, serial, sha), &String.ends_with?(&1, ".exs")) do
      [old | _] ->
        text = RFD.Ref.git(root, ["show", "#{sha}:#{old}"])
        {text, note} = reopen(text)
        File.write!(path, journal(text, path))
        Mix.shell().info("#{path} restored from #{sha}:#{old}#{note}")

      [] ->
        Mix.raise(
          "#{sha} predates the .exs sources; its Markdown is " <>
            Enum.join(RFD.Ref.sources_at(root, serial, sha), ", ")
        )
    end
  end

  def run(_), do: Mix.raise("usage: mix rfd.restore NNNN")

  # The restored source is an old `.exs`; it comes back as a journal dated
  # by the day its serial was registered.
  defp journal(source, path) do
    tmp = Path.join(System.tmp_dir!(), "restore-#{System.unique_integer([:positive])}.exs")
    File.write!(tmp, source)

    try do
      doc = RFD.DSL.unexpanded(fn -> RFD.Source.load(tmp) end)
      site = if div(doc.serial, 1000) == 1, do: "Weftspun", else: "VSekaiFabric"
      day = RFD.Txn.registered_on(File.read!(path))
      RFD.Txn.write(doc, day: day, site: site, madr: source =~ ~r/^\s*madr do/m)
    after
      File.rm(tmp)
    end
  end

  def reopen(text) do
    re = ~r/^(rfd\s+\d+,[^\n]*?(?:\n[^\n]*?)??,\s*):abandoned(\s+do\b)/m

    if text =~ re and not (text =~ ~r/^\s*abandoned_at\s/m),
      do:
        {Regex.replace(re, text, "\\1:discussion\\2", global: false),
         "; state set to :discussion"},
      else: {text, ""}
  end
end

defmodule Mix.Tasks.Rfd.Refs.Check do
  @shortdoc "Fail when RFD.lock.exs no longer matches the live manifest and repositories"
  @moduledoc "    mix rfd.refs.check"
  use Mix.Task
  alias Mix.Tasks.Rfd.Refs.Update

  @smoke_water "https://github.com/chibifire-smoke-water/"

  @impl true
  def run(_) do
    url = Update.manifest_url()

    if skip?(url, System.get_env("GITHUB_ACTIONS"), System.get_env("RFD_TOKEN")) do
      Mix.shell().info(
        "skip #{url}: a CI run without RFD_TOKEN cannot read the smoke-water manifest"
      )
    else
      check(url)
    end
  end

  def skip?(url, github_actions, token),
    do: String.starts_with?(url, @smoke_water) and github_actions == "true" and token in [nil, ""]

  defp check(url) do
    calls = Update.calls()
    {_, commit} = Update.tip!(url)

    xml =
      case Update.blob(url, commit, "default.xml") do
        {:ok, text} -> text
        :error -> Mix.raise("default.xml is unreadable at #{commit} in #{url}")
      end

    live = RFD.Ref.Snapshot.lock(calls, Update.world(xml, commit, calls, url)) |> stable()
    held = RFD.Ref.read_lock!(File.cwd!()) |> stable()

    case drift(held, live) do
      [] ->
        Mix.shell().info("ok   #{map_size(held.repos)} locked repo(s) match #{commit}")

      rows ->
        Enum.each(rows, &Mix.shell().error("  FAIL #{&1}"))
        Mix.raise("RFD.lock.exs is stale against #{commit}; run `mix rfd.refs.update`")
    end
  end

  def stable(lock) do
    %{
      repos: Map.new(lock.repos, fn {k, e} -> {k, Map.drop(e, [:tip])} end),
      files: lock.files
    }
  end

  def drift(held, live) do
    for part <- [:repos, :files],
        k <- Enum.uniq(Map.keys(held[part]) ++ Map.keys(live[part])),
        held[part][k] != live[part][k],
        do: "#{part} #{inspect(k)}: #{inspect(held[part][k])} -> #{inspect(live[part][k])}"
  end
end

defmodule Mix.Tasks.Rfd.Abandoned.Check do
  @shortdoc "Fail unless every abandoned_at SHA holds a source with a Decision"
  @moduledoc "    mix rfd.abandoned.check"
  use Mix.Task

  @impl true
  def run(_) do
    root = RFD.Source.repo_root()

    unless RFD.Ref.history?(root),
      do: Mix.raise("#{root} is shallow or not a git checkout; `git fetch --unshallow` first")

    stubs =
      for path <- RFD.Source.all(),
          doc = RFD.DSL.unexpanded(fn -> RFD.Source.load(path) end),
          sha = doc.abandoned_at,
          is_binary(sha) do
        RFD.Ref.abandoned!(doc.serial, sha, root, verify: true)
      end

    Mix.shell().info("ok   #{length(stubs)} abandoned_at SHA(s) hold a source with a Decision")
  end
end
