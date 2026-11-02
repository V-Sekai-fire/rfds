# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2421, "the headset is the Steam Frame on a PC VR stream", :discussion do
  flight_level :l1
  scope "the Steam Frame headset, its panels and compute, and the stream budget."

  prose ~S"""
  :: hook
  The headset is the Steam Frame, with measured panels, compute and stream rates.
  :: intrigue
  PyroWave encodes both eyes at 200 Mbit/s against 317 Mbit/s of measured Wi-Fi. Does it fit?
  :: exit
  Before you size work for the headset, open `logbook/logbook-steam-frame-sizing.md` for the
  apparatus and the numbers.
  :: decision
  - The headset is aarch64 SteamOS with SteamVR's OpenXR runtime, two 2160 by 2160 panels at 108,
    120 or 144 Hz, a recommended render target of 1728 by 1728 per eye, and 16 GB of memory shared
    with an Adreno 750.
  - One Slang kernel measures 1.28 FP32 and 2.57 FP16 TFLOPS on that GPU and 107 GFLOPS across its
    8 CPU cores, about 0.39 to 0.48 of the desk's M2 Pro on each.
  :: related
  - RFD66606-2287, where this rule lived before the split.
  """

  details_title "the headset is the Steam Frame on a PC VR stream"

  prose ~S"""
  :: details The stream
  PyroWave encodes both eyes at 200 Mbit/s and 72 Hz in 12.4 ms through the CPU-buffer path,
  against 317 Mbit/s of measured Wi-Fi. `logbook/logbook-steam-frame-sizing.md` carries the
  apparatus and the numbers.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2421", :provides, "steam-frame-headset-sizing"
  end
end
