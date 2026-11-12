# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2436, "presence is an independent native slice", :discussion do
  flight_level :l1
  feature "two people in one campus zone see each other's avatars from a program that runs alone."
  scope "the see-each-other beta feature as its own native program, its gate and its control."

  prose ~S"""
  :: hook
  Can two people see each other from a program that needs nothing else in the beta?
  :: intrigue
  The beta lists seeing each other first, and nothing built yet carries it alone. A slice that
  needs voice, the pen and the adventure party to run depends on all three.
  :: exit
  Run the sight gate against a recorded pose stream. A zone that drops one side's poses must fail
  it.
  :: decision
  - Presence ships as one native program with no editor or browser. It owns the
    zone's list of people and their avatar poses (operator, 2026-11-01).
  - The slice runs with no voice, pen, adventure party or shop present. Its inputs are recorded
    pose streams in place of those parts (operator, 2026-11-01).
  - Native means a riscv64 guest ELF for the sandbox, run binary-translated (operator,
    2026-11-01). Its gates run on the CPU guest as the parity oracle (RFD66606-2374,
    RFD66606-2390).
  - The host is the win64 build of RFD66606-2360. It runs on the Steam Frame and the Steam Deck
    through FEX, and the slice's gates run there too (operator, 2026-11-01).
  :: related
  - RFD66606-2360, the one beta.
  - The sibling slices, RFD66606-2437 to RFD66606-2440, are abandoned (operator, 2026-11-11).
  """

  details_title "presence is an independent native slice"

  prose ~S"""
  :: details What the beta asks
  The beta's first feature is two people in the campus zone, one in the standalone Steam Frame
  and one on the desktop. Each sees the other's avatar. The slice holds that and nothing
  more: who is in the zone, where each avatar stands, and the pose each person sends.

  :: details The campus
  A campus is a world, and a world runs as instances. Any player starts an instance for friends,
  public or invite-only. One zone server is the authority for one instance. Each instance keeps
  its own shop books. One campus ships first, and building a campus stays with the V-Sekai
  content tools (operator, 2026-10-30).

  :: details The slice's edge
  In: the zone's list of people, a pose from each, and a view of the others for each person. Out:
  voice, outfits, seats and books, which are the sibling slices. The edge is a message shape
  between the zone and a client. It is the only contract the slice shares, and its first step
  writes it down.

  :: details Gates and controls
  Each gate has a control that plants the defect and must fail.

  - Sight: two clients replay a pose stream, and each client's view lists the other's avatar at
    the replayed pose. Control: a zone that drops one client's poses.
  - Alone: the program starts and passes its sight gate with every sibling slice absent. Control:
    a sibling's message planted in the input, which the program must refuse by name.

  :: details Frontier learning picks the runs
  The slice's gates run as levels in RFD66606-2309's sense, scheduled the way RFD66606-2323
  schedules the store's attacks.
  A level is an input family with fixed attributes: the number of people in the zone, the pose
  rate, the client side (stream or desktop), and the loss pattern in the recorded pose stream. A
  problem is one 5 minute replay of a pose stream with a drawn seed and offset.

  | Level | Planted defect | Found when |
  | --- | --- | --- |
  | pose drop | the zone drops one client's poses | a client's view misses the other avatar |
  | pose order | the zone swaps two poses | an avatar seen at an older pose than the replay |
  | self echo | the zone lists a person to themselves | a view that lists its own avatar |
  | late join | the zone skips the list for a late client | a late client sees nobody |
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
  - Which pose message shape the standalone Frame client and the desktop client both send.
    The first step reads it from the clients and writes it down.
  - Whether a zone holds the pose rate for two people. Nothing has run, and no number is claimed.
  :: details The problem
  RFD66606-2360 lists four features and names no way to build one without the others.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2436", :provides, "see-each-other"
    relate "rfd-2436", :spends, "binary-translated-only-timings"
    relate "rfd-2436", :spends, "elf-guest-native-translation"
    relate "rfd-2436", :spends, "fex"
    relate "rfd-2436", :is_a, "native-slice"
  end
end
