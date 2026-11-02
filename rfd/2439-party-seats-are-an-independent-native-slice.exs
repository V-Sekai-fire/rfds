# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2439, "adventure party seats are an independent native slice", :discussion do
  flight_level :l1

  feature "an adventure party of one player and three seats runs from a program with no campus."

  scope "the seats half of the adventure party and shop feature, as its own program."

  prose ~S"""
  :: hook
  Can a seat's takeover be proven with no campus, no shop and no headset?
  :: intrigue
  The abandoned loop proved only bot players. A player may want to play the part an agent plays,
  and the takeover has never run.
  :: exit
  Run the takeover gate: after a player takes a seat, its actions come only from the player. An
  agent that keeps acting must fail it.
  :: decision
  - Seats ship as one native program: one player and three seats named Aria, Ember and Quill. A
    friend or an agent on the Agent2Agent protocol fills each seat (operator, 2026-11-01).
  - The program asks a seat for its action and takes the answer. A player takes a seat from its
    agent at any time, and the agent's later actions are ignored (operator, 2026-11-01).
  - The slice runs with no sight, voice, pen or shop present. Its inputs are scripted seat answers
    (operator, 2026-11-01).
  - Native means a riscv64 guest ELF for the sandbox, run binary-translated (operator,
    2026-11-01). Its gates run on the CPU guest as the parity oracle (RFD66606-2374,
    RFD66606-2390).
  - The host is the win64 build of RFD66606-2360. It runs on the Steam Frame and the Steam Deck
    through FEX, and the slice's gates run there too (operator, 2026-11-01).
  :: related
  - RFD66606-2360, the one beta.
  - The sibling slices are RFD66606-2436 to RFD66606-2438 and RFD66606-2440.
  """

  details_title "adventure party seats are an independent native slice"

  prose ~S"""
  :: details What the beta asks
  One player and three seats, each filled by a friend or a persona, with the takeover.
  The seats and the takeover are decided in this RFD, carried from the abandoned RFD66606-2358.

  :: details What exists
  Read from the repository descriptions in our organization, not from the code: an Agent2Agent
  v1.0 server in Lean 4 and a planning-domain persona live in repositories of their own. The seat
  slot, the takeover and the agent that fills a seat are new.

  :: details Gates and controls
  Each gate has a control that plants the defect and must fail.

  - Loot contention: one grant and one committed row for four bot players. Control: a second grant
    planted.
  - Takeover: after a player takes a seat, the seat's actions come only from the player. Control:
    the agent still acting.
  - Alone: the program passes both gates with every sibling slice absent. Control: a sibling's
    message planted in the input.

  :: details Frontier learning picks the runs
  The slice's gates run as levels in RFD66606-2309's sense, scheduled the way RFD66606-2323
  schedules the store's attacks.
  A level is an input family with fixed attributes: the number of seats filled by agents, the
  answer delay, the moment of the takeover, and the contention among four bot players. A problem
  is one scripted adventure party of four with a drawn seed and a drawn takeover tick.

  | Level | Planted defect | Found when |
  | --- | --- | --- |
  | second grant | a second loot grant | two grants or two committed rows |
  | agent after takeover | the agent still acting | an action that comes from the agent |
  | late answer | a seat that answers after the tick | a missed action taken as an answer |
  | three open seats | all three seats asked at once | a seat's action missing |
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
  - What happens to a fight in progress when a player takes a seat. The first step decides it.
  - Whether an agent answers the server's call for a seat fast enough, and how it behaves with
    three seats open at once. Nothing has run.
  :: details The problem
  RFD66606-2360 lists four features and names no way to build one without the others.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2439", :provides, "party-seats-native-slice"
    relate "rfd-2439", :spends, "draw-wear-native-slice"
    relate "rfd-2439", :spends, "binary-translated-only-timings"
    relate "rfd-2439", :spends, "elf-guest-native-translation"
    relate "rfd-2439", :spends, "fex"
    relate "rfd-2439", :is_a, "native-slice"
  end
end
