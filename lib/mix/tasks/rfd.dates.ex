# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT

defmodule Mix.Tasks.Rfd.Dates do
  @shortdoc "Write or check the journal of the day each page changed"
  @moduledoc """
      mix rfd.dates [--check]

  The site dates each page by the last day it changed. A flake build
  has no git, so the days live in `journal/pages.txn`, a tackler
  journal: one transaction per page and day, its code the page's path.

      2026-11-26 (rfd/2447-campus-beta-1-see-each-other.exs)
        Pages:RFD  1 CHANGE
        Commits

  Run it after staging pages; staged pages are dated today. `--check`
  fails when the journal does not match git and the index.
  """
  use Mix.Task

  @journal "journal/pages.txn"
  @page ~r/^(rfd|logbook)\/|^[A-Z]+\.md$/

  @impl true
  def run(args) do
    text = render(changes())

    case args do
      ["--check"] ->
        if File.read(@journal) != {:ok, text} do
          Mix.raise("#{@journal} is stale; run mix rfd.dates")
        end

        Mix.shell().info("ok   #{@journal} matches git")

      [] ->
        File.mkdir_p!(Path.dirname(@journal))
        File.write!(@journal, text)
        Mix.shell().info("#{@journal}: written")
    end
  end

  @doc "Every {path, day} a page changed on, from git and the index."
  def changes do
    {log, 0} = git(~w(log --format=%x00%as --name-only))
    {staged, 0} = git(~w(diff --cached --name-only))
    {today, 0} = System.cmd("date", ["+%F"])
    today = String.trim(today)

    logged =
      for chunk <- String.split(log, <<0>>, trim: true),
          [day | files] = String.split(chunk, "\n", trim: true),
          f <- files,
          do: {f, day}

    now =
      for f <- String.split(staged, "\n", trim: true),
          do: {f, today}

    (logged ++ now)
    |> Enum.filter(fn {f, _} -> f =~ @page end)
    |> Enum.uniq()
    |> Enum.sort()
  end

  @doc "The last day each page changed, read from the journal text."
  def last_changed(text) do
    head = ~r/^(\d{4}-\d\d-\d\d) \((.+)\)$/m

    for [_, day, path] <- Regex.scan(head, text),
        reduce: %{} do
      acc -> Map.update(acc, path, day, &max(&1, day))
    end
  end

  defp render(changes) do
    head = """
    ; The day each page of the site changed: one transaction per page
    ; and day, its code the page's path. Written by `mix rfd.dates`.

    """

    body =
      for {path, day} <- changes do
        "#{day} (#{path})\n  #{account(path)}  1 CHANGE\n  Commits\n\n"
      end

    IO.iodata_to_binary([head | body])
  end

  defp account("rfd/" <> _), do: "Pages:RFD"
  defp account("logbook/" <> _), do: "Pages:Logbook"
  defp account(_), do: "Pages:Top"

  defp git(args), do: System.cmd("git", args, stderr_to_stdout: true)
end
