# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2375, "the game ships to the headset as a Windows build", :discussion do
  flight_level :l2
  scope "the Windows build that ships to the headset, and how it is exported and pulled."

  prose ~S"""
  :: hook
  The game reaches the headset as a Windows build, exported on the desk and pulled as a casync
  repository.
  :: intrigue
  A translation generated at run time into writable executable memory does not load under the
  headset's compatibility layer. A service-mode CI runner runs in session 0, which has no
  desktop, so it cannot export.
  :: exit
  Check a new translation against the rule: it is a precompiled Windows library linked against
  the universal C runtime, tested on the Windows desk.
  :: decision
  - The game ships as a Windows build, run natively and through the headset's compatibility
    layer, so a translation is a precompiled Windows library linked against the universal C
    runtime that loads under that layer, never code generated at run time into writable
    executable memory.
  - A Linux `.so` serves the Linux zone servers and never reaches the headset. The compatibility
    layer runs that same Windows build, so the Windows desk is where it is tested. RFD66606-2390
    builds the libraries.
  :: related
  - RFD66606-2294, where this rule lived before the split.
  - RFD66606-2390, which builds the translated libraries.
  """

  details_title "the game ships to the headset as a Windows build"

  prose ~S"""
  :: details How the station ships to the headset
  The station ships to the headset as the Windows x86_64 build, run through the
  headset's compatibility layer, on single-precision Godot 4.7.2 until the
  station's double-precision guests are verified (operator, 2026-10-01). The
  export uses an export template and a real rendering device, so it runs in the
  Windows desk's interactive session: Windows OpenSSH and a service-mode CI runner
  both run in session 0, which has no desktop. A session drives the Godot editor
  there through the computer-use driver, or starts the export from SSH as a
  scheduled task with `/it`. No GitHub Actions runner does it.

  :: details The casync repository
  The build ships as a casync repository: desync, the Go implementation of
  casync, makes the index and chunk store, and they go into a V-Sekai-fire
  repository of their own. The headset pulls the title with desync's arm64 build,
  or takes it over SSH as user `deck` with the desk's key, as a dev title.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2375", :provides, "windows-headset-game-build"
  end
end
