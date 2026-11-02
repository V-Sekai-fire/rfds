# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2377, "a translation links into the addon, one bake per platform", :discussion do
  flight_level :l2
  scope "linking a translation into the addon, and baking its C once per platform."

  prose ~S"""
  :: hook
  Each platform links its own baked translation into the addon, so the web game loads.
  :: intrigue
  Chrome refuses to compile a WebAssembly module larger than 8 MB on the main thread, and a
  game's translation is larger. C baked on one platform does not match on another.
  :: exit
  Bake the C of a platform by running the game once on that platform with the emitter on,
  then compile the emitted C for that platform.
  :: decision
  - A translation can be compiled into the addon library of its platform instead of being
    loaded as a library at run time. On the web this is the only route that works. The
    desktop builds of the same game use the same route.
  - Each platform bakes its own C. The game runs once on that platform with the emitter on,
    and the emitted C is compiled for that platform.
  :: related
  - RFD66606-2294, where this rule lived before the split.
  """

  details_title "a translation links into the addon, one bake per platform"

  prose ~S"""
  :: details Where the objects live
  The addon keeps each platform's translation objects in a folder of their own,
  `src/bintr/<platform>.<arch>/`.

  :: details Why each platform bakes
  The program hash covers the machine layout as well as the program, so C baked on one
  platform does not match on another. Windows and Linux on x86_64 share a layout and a hash,
  and each still compiles its own copy. One bake of the SolidCraft guest is 32 C files, 336
  MB of C for 16.2 MB of RISC-V code.

  :: details A change to the host's system calls
  A change to the host's system calls leaves the guest's translation as it was, so the
  compiled objects and the hash stay valid and only a relink is needed.
  :: details The problem
  Chrome refuses to compile a WebAssembly module larger than 8 MB on the main thread, and a
  game's translation is larger.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2377", :provides, "per-platform-baked-translation"
  end
end
