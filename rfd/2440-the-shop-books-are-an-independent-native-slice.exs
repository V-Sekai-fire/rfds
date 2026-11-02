# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2440, "the shop books are an independent native slice", :discussion do
  flight_level :l1
  feature "the shopkeeper keeps a saved world for each conversation, from one program."

  scope "the shop half of the adventure party and shop feature, as its own program."

  prose ~S"""
  :: hook
  Does a shopkeeper that has met a request answer the second one with nothing left to do?
  :: intrigue
  The loop the campus replaces named a store this workspace has retired. A store that forgets
  every write answers the second request as if it were the first.
  :: exit
  Run the memory gate: the second request for a goal in one conversation returns an empty plan. A
  store that forgets every write must fail it.
  :: decision
  - The shop ships as one native program: the shopkeeper persona with its saved world for each
    conversation, kept in SQLite on FoundationDB through a secrets engine that runs named
    statements (operator, 2026-11-01).
  - The slice runs with no sight, voice, pen or seats present. Its inputs are scripted requests
    (operator, 2026-11-01).
  - Native means a riscv64 guest ELF for the sandbox, run binary-translated (operator,
    2026-11-01). Its gates run on the CPU guest as the parity oracle (RFD66606-2374,
    RFD66606-2390).
  - The host is the win64 build of RFD66606-2360. It runs on the Steam Frame and the Steam Deck
    through FEX, and the slice's gates run there too (operator, 2026-11-01).
  :: related
  - RFD66606-2339, the persona; RFD66606-2360, the one beta.
  - The sibling slices are RFD66606-2436 to RFD66606-2439.
  """

  details_title "the shop books are an independent native slice"

  prose ~S"""
  :: details What the beta asks
  The shopkeeper persona and its saved world, so a request it has met is answered with nothing
  left to do. The books are decided in this RFD, carried from the abandoned RFD66606-2359.

  :: details What exists
  Read from the repository descriptions in our organization, not from the code: a planning-domain
  persona, and a secrets engine that runs precanned SQL against SQLite on the fabric's store, live
  in repositories of their own. The shop's wiring of the two is new.

  :: details Gates and controls
  Each gate has a control that plants the defect and must fail.

  - Memory: the second request for a goal in one conversation returns an empty plan that has
    reached it. Control: a store that forgets every write.
  - Alone: the program passes its gate with every sibling slice absent. Control: a sibling's
    message planted in the input.

  :: details Frontier learning picks the runs
  The slice's gates run as levels in RFD66606-2309's sense, scheduled the way RFD66606-2323
  schedules the store's attacks.
  A level is an input family with fixed attributes: the number of conversations, the number of
  repeated goals, the goal kind, and the write pattern of the store. A problem is one scripted
  conversation with a drawn seed and a drawn order of requests.

  | Level | Planted defect | Found when |
  | --- | --- | --- |
  | forgetful store | a store that forgets every write | the second plan is not empty |
  | crossed books | two conversations share books | a goal met in one is met in both |
  | late write | the write acknowledged before it lands | a second request that sees no write |
  | wrong goal | an empty plan for an unmet goal | a goal reported reached that was not |
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
  - Whether many instances of one campus each keep a separate books database. One database for
    each instance is possible, and no run has opened more than one.
  :: details The problem
  RFD66606-2360 lists four features and names no way to build one without the others.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2440", :provides, "shop-books-native-slice"
    relate "rfd-2440", :spends, "party-seats-native-slice"
    relate "rfd-2440", :spends, "binary-translated-only-timings"
    relate "rfd-2440", :spends, "elf-guest-native-translation"
    relate "rfd-2440", :spends, "fex"
    relate "rfd-2440", :spends, "persona-goal-task-planner"
    relate "rfd-2440", :spends, "bao"
    relate "rfd-2440", :spends, "fdb-sqlite"
    relate "rfd-2440", :is_a, "native-slice"
  end
end
