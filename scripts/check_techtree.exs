# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT
# Gate: the tracked assets/techtree.lot and .xmp equal what the generator and techtree.cff give.
#     mix run scripts/check_techtree.exs [--write | --self-test]
defmodule CheckTechtree do
  @root Path.expand("..", __DIR__)
  @files ~w(techtree.lot techtree.xmp)
  @regen "mix run scripts/check_techtree.exs --write"

  def main(["--self-test"]), do: self_test()

  def main(args) do
    built = build()
    tracked = Path.join(@root, "assets")

    if args == ["--write"] do
      for f <- @files, do: File.cp!(Path.join(built, f), Path.join(tracked, f))
      IO.puts("wrote " <> Enum.map_join(@files, ", ", &"assets/#{&1}"))
    else
      problems = drift(built, tracked) ++ sidecar(tracked)
      Enum.each(problems, &IO.puts("  FAIL #{&1}"))

      if problems == [] do
        IO.puts("ok   assets/techtree.lot and .xmp match the generator and techtree.cff")
      else
        IO.puts("regenerate with: #{@regen}")
        System.halt(1)
      end
    end
  end

  def drift(built, tracked) do
    for f <- @files,
        why = differs(Path.join(built, f), Path.join(tracked, f)),
        why != nil,
        do: "assets/#{f} #{why}"
  end

  defp differs(a, b) do
    case {File.read(a), File.read(b)} do
      {{:ok, x}, {:ok, x}} -> nil
      {{:ok, _}, {:ok, _}} -> "differs from what the generator writes"
      {_, {:error, _}} -> "is missing"
      {{:error, _}, _} -> "was not written by the generator"
    end
  end

  def sidecar(dir) do
    with {:ok, lot} <- File.read(Path.join(dir, "techtree.lot")),
         {:ok, xmp} <- File.read(Path.join(dir, "techtree.xmp")) do
      doc = JSON.decode!(lot)
      media = %{format: "video/lottie+json", frame_rate: doc["fr"], frames: doc["op"] - doc["ip"]}
      want = Path.join(dir, "techtree.cff") |> Rfd.Cff.read!() |> Rfd.CffXmp.derive(media)
      if xmp == want, do: [], else: ["assets/techtree.xmp is not what techtree.cff derives"]
    else
      _ -> ["assets/techtree.lot or .xmp is missing"]
    end
  end

  defp build do
    out = Path.join(System.tmp_dir!(), "techtree-#{System.unique_integer([:positive])}")
    env = [{"ERL_COMPILER_OPTIONS", "[nowarn_deprecated_catch]"}]
    run!(~w(rfd.render), env)
    run!(["run", "scripts/pages_site.exs", out], env)
    Path.join(out, "assets")
  end

  defp run!(args, env) do
    {text, code} = System.cmd("mix", args, cd: @root, env: env, stderr_to_stdout: true)
    if code != 0, do: raise("mix #{Enum.join(args, " ")} failed:\n#{text}")
  end

  defp self_test do
    dir = Path.join(System.tmp_dir!(), "techtree-self-#{System.unique_integer([:positive])}")
    [a, b] = for s <- ~w(built tracked), do: Path.join(dir, s)
    for d <- [a, b], do: File.mkdir_p!(d)
    lot = ~s({"fr":30,"ip":0,"op":60}\n)
    File.cp!(Path.join(@root, "assets/techtree.cff"), Path.join(b, "techtree.cff"))
    cff = Rfd.Cff.read!(Path.join(b, "techtree.cff"))
    xmp = Rfd.CffXmp.derive(cff, %{format: "video/lottie+json", frame_rate: 30, frames: 60})
    for d <- [a, b], do: File.write!(Path.join(d, "techtree.lot"), lot)
    for d <- [a, b], do: File.write!(Path.join(d, "techtree.xmp"), xmp)

    checks = [
      {"matching copies pass", drift(a, b) == [] and sidecar(b) == []},
      {"a flipped byte in the .lot is drift",
       File.write!(Path.join(b, "techtree.lot"), String.replace(lot, "60", "61")) == :ok and
         length(drift(a, b)) == 1},
      {"a sidecar whose duration disagrees with the .lot fails", sidecar(b) != []},
      {"a missing tracked file fails",
       File.rm!(Path.join(b, "techtree.xmp")) == :ok and
         Enum.any?(drift(a, b), &(&1 =~ "missing"))}
    ]

    for {name, ok} <- checks, do: IO.puts("  #{if ok, do: "ok  ", else: "FAIL"} #{name}")
    if Enum.all?(checks, &elem(&1, 1)), do: :ok, else: System.halt(1)
  end
end

CheckTechtree.main(System.argv())
