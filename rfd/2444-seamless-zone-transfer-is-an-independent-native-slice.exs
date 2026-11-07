# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2444, "seamless zone transfer is an independent native slice", :discussion do
  flight_level :l1
  feature "a person walks from one campus zone into another with no cut, from one program."
  scope "the seamless-zone-transfer beta feature as its own native program, its gate and its control."

  prose ~S"""
  :: hook
  Can a person cross from one campus zone into another while the other person sees no cut?
  :: intrigue
  One zone server is the authority for one instance, so a crossing hands an avatar from one
  authority to another. A handoff that loses the avatar, shows it twice or drops its poses is a
  cut, and nothing built yet carries it alone.
  :: exit
  Run the crossing gate against a recorded pose stream that crosses a zone boundary. A handoff
  that never completes must fail it.
  :: decision
  - Seamless zone transfer ships as one native program with no editor or browser. It owns the
    handoff of one avatar from the zone that holds it to the zone that receives it (operator,
    2026-11-07).
  - The slice runs with no voice, pen, adventure party or shop present. Its inputs are recorded
    pose streams that cross a boundary in place of those parts (operator, 2026-11-07).
  - The handoff spends the transfer verb and its macaroon from RFD66606-2288. The slice does not
    invent a second way to move a guest's VM.
  - Native means a riscv64 guest ELF for the sandbox, run binary-translated (operator,
    2026-11-07). Its gates run on the CPU guest as the parity oracle (RFD66606-2374,
    RFD66606-2390).
  - The host is the win64 build of RFD66606-2360. It runs on the Steam Frame and the Steam Deck
    through FEX, and the slice's gates run there too (operator, 2026-11-07).
  :: related
  - RFD66606-2360, the one beta.
  - RFD66606-2436, the zone's list of people and their poses.
  - RFD66606-2288, the transfer capability.
  """

  details_title "seamless zone transfer is an independent native slice"

  prose ~S"""
  :: details What the beta asks
  The beta's fifth feature is a person crossing from one campus zone into another. The person who
  stays sees the avatar leave the first zone and arrive in the second, with no gap in its poses
  and no second copy. The slice holds that and nothing more: the handoff of one avatar between two
  zone servers.

  :: details Seamless
  Seamless means three things a gate can check. No gap: the viewer's view holds the avatar at a
  pose in every step of the crossing. No copy: at no step does a view list the avatar twice. No
  loss: the pose the avatar has when it arrives is the pose it had when it left, at the replayed
  rate.

  :: details The slice's edge
  In: two zones, an avatar in the first, and a recorded pose stream that crosses the boundary.
  Out: the poses and the views of presence, voice, outfits, seats and books, which are the sibling
  slices. The edge is a message shape between the two zones and a client. Its first step writes it
  down.

  :: details Gates and controls
  Each gate has a control that plants the defect and must fail.

  - Crossing: a viewer replays a pose stream that crosses the boundary, and its view lists the
    avatar once at the replayed pose in every step. Control: a handoff that never completes.
  - Capability: a handoff with a valid transfer macaroon goes ahead. Control: the same handoff
    with no macaroon, which must be refused.
  - Alone: the program starts and passes its crossing gate with every sibling slice absent.
    Control: a sibling's message planted in the input, which the program must refuse by name.

  :: details Frontier learning picks the runs
  The slice's gates run as levels in RFD66606-2309's sense, scheduled the way RFD66606-2323
  schedules the store's attacks.
  A level is an input family with fixed attributes: the pose rate, the side of the boundary the
  viewer stands on, the crossing speed, and the loss pattern in the recorded pose stream. A
  problem is one 5 minute replay of a pose stream with a drawn seed and offset.

  | Level | Planted defect | Found when |
  | --- | --- | --- |
  | never completes | the handoff never completes | the avatar vanishes from the first zone and never appears in the second |
  | double | both zones list the avatar | a view lists the avatar twice |
  | pose drop | the zone drops poses during the switch | a gap in the viewer's poses |
  | pose jump | the arrival pose differs from the departure pose | the avatar jumps at the boundary |
  | no macaroon | the handoff skips the capability | the transfer goes ahead unrefused |
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
  - Whether the walk from the shop to a room and back in RFD66606-2439 already crosses a zone
    boundary. Each is read from its source before this slice is cut from it.
  - Whether the transfer verb of RFD66606-2288, which moves a guest's VM, is what a crossing
    spends, or whether an avatar crosses as a smaller message. The first step reads it.
  - Whether the zones are two servers of one instance or two instances. RFD66606-2436 says one
    zone server is the authority for one instance.
  - How long a crossing may take before a viewer sees a cut. Nothing has run, and no number is
    claimed.
  :: details The problem
  RFD66606-2360 listed four features, and none of them carries a person from one zone to another.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2444", :provides, "seamless-zone-transfer"
    relate "rfd-2444", :spends, "binary-translated-only-timings"
    relate "rfd-2444", :spends, "elf-guest-native-translation"
    relate "rfd-2444", :spends, "fex"
    relate "rfd-2444", :is_a, "native-slice"
  end
end
