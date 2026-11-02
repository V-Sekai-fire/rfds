# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2438, "draw and wear is an independent native slice", :discussion do
  flight_level :l1
  feature "a drawn outfit becomes a garment and is worn in the campus zone by one program."
  scope "the draw-and-wear beta feature as its own native program, its gate and its control."

  prose ~S"""
  :: hook
  Can the pen's first rung run in the campus zone without a person in a headset?
  :: intrigue
  The pen's first rung proves two people see a drawn outfit, and it has no campus to wear it in.
  Its gates need a headset, which the beta's other slices cannot assume.
  :: exit
  Run the wear gate on a recorded stroke file. A garment that never reaches the zone's ghost must
  fail it.
  :: decision
  - Draw and wear ships as one native program that takes a recorded stroke file, makes the
    garment, and hands ownership of it to the zone. It keeps the pen's gates unchanged (operator,
    2026-11-01).
  - A recorded stroke file stands in for the person in the headset in every gate that is not the
    pen's own (operator, 2026-11-01).
  - Native means a riscv64 guest ELF for the sandbox, run binary-translated (operator,
    2026-11-01). Its gates run on the CPU guest as the parity oracle (RFD66606-2374,
    RFD66606-2390).
  - The host is the win64 build of RFD66606-2360. It runs on the Steam Frame and the Steam Deck
    through FEX, and the slice's gates run there too (operator, 2026-11-01).
  :: related
  - RFD66606-2287, the pen's first rung; RFD66606-2360, the one beta.
  - The sibling slices are RFD66606-2436, RFD66606-2437, RFD66606-2439 and RFD66606-2440.
  """

  details_title "draw and wear is an independent native slice"

  prose ~S"""
  :: details What the beta asks
  The pen's first rung, in the campus zone: the drawn outfit is worn, and the other person sees
  it. RFD66606-2287 decides how a person draws and wears an outfit, and this slice keeps that
  decision as written.

  :: details What exists
  Read from the repository descriptions in our organization, not from the code: the pen's guest
  programs for fitting, curve drawing, dress-on and the worker live in repositories of their own.
  The campus zone with the ghost handoff is new. Each part is read for its code before the slice's
  first step.

  :: details Gates and controls
  Each gate has a control that plants the defect and must fail.

  - Pen: the gates of RFD66606-2287, unchanged.
  - Wear: from a recorded stroke file, the zone holds a ghost of the garment and ownership passes
    to the zone. Control: a handoff that never completes.
  - Alone: the program passes its gates with every sibling slice absent. Control: a sibling's
    message planted in the input.

  :: details Where the pen's gates run
  The pen's gates fit a body and make a garment on a GPU. They run on a GPU desk. On a CPU only
  unit gates and their controls run, and the end-to-end run waits for a GPU desk.

  :: details Frontier learning picks the runs
  The slice's gates run as levels in RFD66606-2309's sense, scheduled the way RFD66606-2323
  schedules the store's attacks.
  A level is an input family with fixed attributes: the stroke file's length, the body shape, the
  garment kind, and the handover delay. A problem is one recorded stroke file worn once, with a
  drawn seed and body.

  | Level | Planted defect | Found when |
  | --- | --- | --- |
  | handover | a handover that never completes | no ghost in the zone |
  | ghost shape | the ghost built from another stroke file | the ghost differs from the garment |
  | second viewer | the zone sends the garment to one viewer | the other person sees no outfit |
  | stroke order | two strokes swapped | a garment that differs from the recorded one |
  | sibling input | a sibling's message planted | the program accepts it |

  Each level runs on the slice as it is and on the slice with that level's defect planted. On the
  planted target, success is the defect found. Regret `1[s ≥ 1] − s/n` over the last eight runs is
  high when a level finds its defect only some of the time. Mutation moves one attribute and is
  kept only when the planted find rate rises.
  A clean run counts only after its level found the planted defect in each of its last eight runs.
  A finding on the real slice is never averaged into a rate: it stops the lane and becomes a level
  that runs every time.
  The runs are guest ELF runs on the CPU guest, which is the parity oracle, so no gate here needs
  a GPU.

  :: details Where the code lands
  Each slice is a repository of its own in our organization, named for what it does with no game
  name, and pinned through the repo manifest. It arrives as an ordinary pull request. V-Sekai
  repositories stay read-only.

  :: details What is not known
  - Whether the pen's outfits and the rigged models reach the campus zone unchanged. Each part is
    read for its precision and format first.
  - Whether an agent in a seat can wear a drawn outfit. No ruling covers it.
  :: details The problem
  RFD66606-2360 lists four features and names no way to build one without the others.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2438", :provides, "draw-wear-native-slice"
    relate "rfd-2438", :spends, "binary-translated-only-timings"
    relate "rfd-2438", :spends, "elf-guest-native-translation"
    relate "rfd-2438", :spends, "fex"
    relate "rfd-2438", :spends, "headset-draw-wear-rung"
    relate "rfd-2438", :is_a, "native-slice"
  end
end
