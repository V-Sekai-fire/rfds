# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2390, "every ELF guest ships with its native translation", :discussion do
  flight_level :l1
  scope "native binary translation of every ELF guest on every platform."

  prose ~S"""
  :: hook
  Every ELF guest runs translated, never interpreted, on every platform it ships to.
  :: intrigue
  What happens when the setting is on and no library is present? On Windows it segfaulted on
  2026-09-23.
  :: exit
  Run `probe_load.gd` and check that `Sandbox.is_binary_translated()` holds for every ELF on the
  Frame, the desktop and the Fly image.
  :: decision
  - Native binary translation, required, interpretation never: every ELF guest we author ships
    with its translation on every platform it ships to, Windows, Linux and macOS alike.
  - `stages/sandbox_util.gd`'s `enable_native_translation` drops its Linux-only guard and turns
    the setting on wherever a library for the platform is shipped.
  :: related
  - RFD66606-2293, where this rule lived before the split.
  """

  details_title "every ELF guest ships with its native translation"

  prose ~S"""
  :: details Build
  The addon is built with the emitter (`GODOT_SANDBOX_BINTR_EMIT=<dir>` writes each program's
  translation as C99, `RISCV_ASMJIT=OFF`, no JIT), and the pen's `guests.yml` emits each
  program's C99 on the linux runner and compiles one library per program hash,
  `res://bintr/bintr-<HASH>.so` for linux x86_64, `.dll` for windows x86_64 through LLVM's clang
  (`clang-cl` on a desk, the llvm-mingw clang on the runner), and `.dylib` for macos arm64, at
  double. Xtools/build.exs` does the same on a desk. The Windows leg is in progress. Until its
  `.dll` loads, a Windows guest is untranslated and the gate below names it.

  The Windows segfault of 2026-09-23 (the setting on with no library present) is reproduced on
  the double build, its backtrace logged, and fixed in the placed addon source, not avoided.
  `guests.yml` and the release carry the libraries beside the ELFs with their sha256s.

  :: details Check and control
  Check: `probe_load.gd` asserts `Sandbox.is_binary_translated()` for every ELF on the Frame, the
  desktop and the Fly image, and the logbook records each ELF's instructions per second
  translated against interpreted.

  Control: an ELF whose hash has no library reports untranslated and the gate fails by name.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2390", :provides, "elf-guest-native-translation"
  end
end
