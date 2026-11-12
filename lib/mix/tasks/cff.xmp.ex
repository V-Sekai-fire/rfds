# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT
defmodule Mix.Tasks.Cff.Xmp do
  @shortdoc "Derive an XMP sidecar from a .cff; --check refuses a stale one (RFD66606-2240)"
  @moduledoc "mix cff.xmp [--check] [--format T --frame-rate N --frames N] <in.cff> <out.xmp>"
  use Mix.Task

  @switches [check: :boolean, format: :string, frame_rate: :integer, frames: :integer]

  @impl true
  def run(args) do
    {opts, files} = OptionParser.parse!(args, strict: @switches)

    [cff, out] =
      case files do
        [_, _] -> files
        _ -> Mix.raise("usage: " <> @moduledoc)
      end

    media = Map.new(Keyword.take(opts, [:format, :frame_rate, :frames]))
    xmp = cff |> Rfd.Cff.read!() |> Rfd.CffXmp.derive(media)

    cond do
      !opts[:check] -> File.write!(out, xmp)
      File.read(out) == {:ok, xmp} -> Mix.shell().info("ok   #{out} matches #{cff}")
      true -> Mix.raise("#{out} is stale: it differs from what #{cff} derives")
    end
  end
end
