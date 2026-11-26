# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT

defmodule Mix.Tasks.Rfd.Text do
  @shortdoc "Print RFDs as the text the prose gates read, at a revision or on disk"
  @moduledoc """
      mix rfd.text [--rev REV] PATH...

  For each `rfd/NNNN-slug.txn` (or `.exs`, a revision from before the
  journals), prints one JSON object per line:

      {"path": ..., "found": true, "markdown": ..., "hook": ..., "raw": ...}

  `markdown` is the rendered README and DETAILS, which the prose gates
  check. `raw` is every text of the RFD with `&{...}` references as
  written, which the literals gate checks. With `--rev` the source is
  read from that revision; a `.txn` path missing there is read as the
  `.exs` it was before. A path with no source is `"found": false`.
  """
  use Mix.Task

  @impl true
  def run(args) do
    {opts, paths} = OptionParser.parse!(args, strict: [rev: :string])
    Mix.Task.run("compile")

    for path <- paths do
      IO.puts(JSON.encode!(text(path, opts[:rev])))
    end
  end

  defp text(path, rev) do
    case source(path, rev) do
      nil ->
        %{path: path, found: false}

      {name, body} ->
        doc = RFD.Source.load_string(body, name)
        raw = RFD.DSL.unexpanded(fn -> RFD.Source.load_string(body, name) end)
        markdown = RFD.Doc.readme(doc) <> "\n" <> (RFD.Doc.details(doc) || "")
        %{path: path, found: true, markdown: markdown, hook: doc.hook, raw: RFD.Txn.prose(raw)}
    end
  end

  defp source(path, nil) do
    if File.exists?(path), do: {path, File.read!(path)}
  end

  defp source(path, rev) do
    exs = String.replace_suffix(path, ".txn", ".exs")

    Enum.find_value(Enum.uniq([path, exs]), fn p ->
      case System.cmd("git", ["show", "#{rev}:#{p}"], stderr_to_stdout: true) do
        {body, 0} -> {p, body}
        _ -> nil
      end
    end)
  end
end
