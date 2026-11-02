# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2374, "everything in a godot-sandbox runs binary-translated", :discussion do
  flight_level :l2
  scope "binary translation in godot-sandbox and the timings that justify it."

  prose ~S"""
  :: hook
  Everything in a godot-sandbox runs binary-translated, and only translated timings are reported.
  :: intrigue
  An interpreted timing reported as the result would hide the translated speed. A script that
  does not compile has no fallback to hide behind.
  :: exit
  Check a new script against the rule: ship it compiled as `.sgd` with its translation, and
  count a script that does not compile as a FAIL.
  :: decision
  - Everything that runs in godot-sandbox is binary-translated, guest ELFs and SafeGDScript
    alike, and an interpreted timing is never the one reported.
  - No `.gd` ships: every script, third-party ones included, ships compiled as `.sgd` with its
    translation, and a script that does not compile is a counted FAIL, not a fallback.
  :: related
  - RFD66606-2294, where this rule lived before the split.
  - RFD66606-2390, which builds the translated libraries.
  """

  details_title "everything in a godot-sandbox runs binary-translated"

  prose ~S"""
  :: details What was measured
  Each target built one sphere of 672 triangles in the guest's self-test, with the
  translated and the interpreted build started one after the other, twice, on a
  machine with no other load (2026-10-17). Times are in milliseconds.

  | target | translated | interpreted |
  |---|---|---|
  | macOS arm64, Mac mini, osxcross build | 40.3 to 42.0 | 214.7 to 293.5 |
  | Windows x86_64, the desk | 61.2 to 62.0 | 454.2 to 491.7 |
  | Linux x86_64, WSL on the same desk | 114.4 to 131.9 | 583.8 to 595.3 |
  | web, Chrome on the Mac, tab in front | 79 to 110 | 442 to 472 |

  The same macOS translation built with Apple clang took 69.5 to 72.4 ms against
  37.7 to 38.4 ms from osxcross with clang 18, so the osxcross build is the one that
  ships. The cause of that difference is not measured. Readings taken while another
  build ran on the same machine overstated the gap: Windows interpreted read 848 to
  907 ms then.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2374", :provides, "binary-translated-only-timings"
    relate "rfd-2374", :provides, "sgd-compiled-scripts-only"
    relate "rfd-2374", :is_a, "guest-runtime"
  end
end
