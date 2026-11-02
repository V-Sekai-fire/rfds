# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2378, "desktop libraries build in WSL and cross-build from the Mac", :discussion do
  flight_level :l2
  scope "where each desktop library is built, and how the WSL steps run."

  prose ~S"""
  :: hook
  Build each desktop library on its named machine, and run WSL steps from a script file.
  :: intrigue
  Ubuntu's clang 14 cannot parse the macOS SDK's libc++ headers. Nested quoting from `cmd`
  into WSL returns empty output.
  :: exit
  Put the next step that runs in WSL in a script file on the Windows side, and run it with
  `wsl.exe` as root with `sh` from `/mnt/c/`.
  :: decision
  - Linux x86_64 is built and tested in WSL Ubuntu 22.04 on the Windows desk, not in a
    container on the Mac (operator, 2026-10-16). The library needs glibc 2.35, the floor the
    Godot template already sets.
  - macOS arm64 is cross-built in the same WSL with osxcross and the macOS 15.4 SDK packed
    from the Mac (operator, 2026-10-16). Windows x86_64 is cross-built with MinGW on the
    Mac.
  - Steps that run in WSL go in a script file on the Windows side, which `wsl.exe` runs as
    root with `sh` from `/mnt/c/`.
  :: related
  - RFD66606-2294, where this rule lived before the split.
  - RFD66606-2374, which holds the rest of the paragraph on the Apple clang measurement.
  """

  details_title "desktop libraries build in WSL and cross-build from the Mac"

  prose ~S"""
  :: details The osxcross compiler
  Ubuntu's clang 14 cannot parse that SDK's libc++ headers, so osxcross is built with clang
  18, and clang 18 is the `clang` on the PATH, because the osxcross wrapper calls plain
  `clang`.

  :: details Build times
  Compiling the 32 translation units took 158 s for macOS on the Mac, 348 s for Windows on
  the Mac and 590 s for Linux in WSL on the desk.

  :: details What was measured
  The same macOS translation built with Apple clang took 69.5 to 72.4 ms against 37.7 to
  38.4 ms from osxcross with clang 18, so the osxcross build is the one that ships. The
  cause of that difference is not measured. Readings taken while another build ran on the
  same machine overstated the gap: Windows interpreted read 848 to 907 ms then.
  :: details The problem
  Nested quoting from `cmd` into WSL returns empty output.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2378", :provides, "wsl-desktop-library-builds"
    relate "rfd-2378", :spends, "cross-build-image"
    relate "rfd-2378", :is_a, "workspace-policy"
  end
end
