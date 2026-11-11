# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2307, "recording the xr pilot stream to cineform", :committed do
  feature "XR Pilot keeps the runtime's PyroWave packets as they arrive and a separate
step decodes them on an idle GPU into a CineForm intermediate"
  scope "XR Pilot and its MCP server, the pyro2cfhd and frames2cfhd tools, the CineForm SDK
build, and the av1mkv delivery of a recording"

  prose ~S"""
  :: hook
  A recording keeps the runtime's own video stream and encodes it later on an idle GPU.
  :: intrigue
  Encoding live on the VR GPU would compete with the compositor, which an overload had
  already killed twice that day.
  :: exit
  Read RFD66606-2306 next, on operating the shared desk.
  :: decision
  A recording is the runtime's own video stream, not a screen capture. The
  pilot appends each PyroWave packet to a `.pwrec` file with its presentation
  and receive times and does no encoding while VR runs. A one-shot job later
  decodes the packets on the GPU that is not driving VR and encodes CineForm
  on the CPU. The CineForm file is the intermediate the delivery step wraps
  as MKV with a `.cff` (operator, 2026-10-09).
  :: related
  - RFD66606-2303, the XR requirements; RFD66606-2365, the recording rules.
  - RFD66606-2306, operating the shared desk; RFD66606-2302, the frame budget.
  """

  details_title "recording the xr pilot stream to cineform"

  prose ~S"""
  :: details The packet file
  `.pwrec` starts with the magic `PWREC`, two zero bytes and a version byte.
  Each frame is a u64 presentation time in ns, a u64 receive time in ns, a u32
  index, a u32 byte count and the payload, at most 256 MiB. A pilot that
  restarts writes the next file with `.1.pwrec`. `xr-pilot --record-stream`
  and the MCP server's `--record-stream <out>` write it.

  :: details The decode step
  `pyro2cfhd <in.pwrec> <out.cfhd>` takes `--fps`, `--size`, `--quality` and
  `--gpu` (a PCI vendor and device pair). It runs as a one-shot task on the
  GPU without VR. `frames2cfhd` does the same from PNG frames. Both share one
  fit and RIFF writer.

  - The CineForm RIFF file stops at 4 GB.
  - The MKV writer built with llvm-mingw fails past 2 GB.
  - Full-rate 4K therefore needs a container writer fix before it ships.

  :: details Building CineForm with MSVC
  Two changes let the CineForm SDK build with MSVC on the desk:
  `simd_compat.h` includes `malloc.h` for the aligned allocators, which MSVC
  has in place of `mm_malloc.h`; `lutpath.cpp` declares its registry value
  name `LPCTSTR`, so string literals assign to it under strict strings. The
  llvm-mingw build of av1mkv needs the toolchain's libc++ and libunwind DLLs
  beside it, or it exits with 0xc00004bc.

  :: details Motion that does not stutter
  Walking was integrated in the 60 Hz window loop while the tracking sender ran
  at a fixed 90 Hz, so one packet in three repeated a pose. The sender now runs
  at the runtime's announced refresh rate, clamped to 60 to 144 Hz, and moves
  held keys by real elapsed time; the window applies mouse look only. The
  wheel scales walk speed by 1.25 per notch, from 0.25 to 8 m/s; with Shift
  it moves the hand's reach. A 3D head gizmo draws yaw and pitch as arcs, so a
  trace shows when the head looks straight up or down.

  :: details Open work
  - Run the `pyro2cfhd` self-test on the desk's second GPU, then record a real
    two-minute stream and deliver it.
  - Count compositor sync timeouts in the driver and give the sparklines fault
    thresholds (RFD66606-2306).
  :: details The problem
  The first two-minute sweep was saved as left-eye PNG frames and encoded at
  10 fps, because a full-rate 4K clip passes the size limits of the CineForm
  RIFF writer and of the MKV writer built with llvm-mingw.
  """
end
