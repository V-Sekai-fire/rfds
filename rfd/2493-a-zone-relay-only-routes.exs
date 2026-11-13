# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2493, "a zone relay only routes", :discussion do
  flight_level :l1

  feature "a zone hands each member the others' frames and reads none of them."

  scope "the presence slice's zone relay: its rule for taking a frame, its sockets, its gates."

  prose ~S"""
  :: hook
  Can a zone carry four people's bodies to each other without simulating, decoding or judging
  anything, and without trusting the clock of anyone who sends to it?
  :: intrigue
  A zone that simulates is one more party to trust. The first relay built here avoided that and
  still trusted something it should not have: it opened each sender's turn on a tick of its own
  clock. Run on real sockets for the first time, it refused 7 honest frames of 320. A client's
  clock is not the relay's, and a send that drifts across the relay's tick lands twice in one
  turn and not at all in the next. The model's gate had passed, because its clients and its
  router shared one clock.
  :: exit
  Drive the relay's state machine with four clients whose clocks are offset, skewed and
  jittered, for 19,200 ticks. It passes when no honest frame is refused and every flood frame is.
  :: decision
  - A zone relay hands each member's two frames to the other members as they came. It does not
    simulate, decode, compress or judge, and it holds no key (operator, 2026-11-13).
  - A half of a slot is open again 5 ticks after the frame it last took, counted on the relay's
    own clock from that frame and from nothing else. A frame that comes sooner is counted and
    not stored, so a flood makes the relay do less.
  - The half of a datagram is the socket it arrived on: first frames go to one port and second
    frames to the next. Nothing is added to a frame and nothing travels beside it.
  - The relay is plain C with no heap and no engine, held to a model in SafeGDScript by
    replaying a recorded trace of every call and every answer.
  - Liveness is the relay's and safety is not: it can drop or delay, and it cannot forge.
  :: related
  - RFD66606-2436, presence, the slice this relay serves.
  - RFD66606-2443, the entity server it was first built beside, which this narrows.
  - RFD66606-2442, the latency budget that is where its tick is going.
  - RFD66606-2492, the predictor that makes what it carries smaller.
  """

  details_title "a zone relay only routes"

  prose ~S"""
  :: details Where it lives
  The parts are repositories of their own in our organisation, each started anew on 2026-11-13.

  - The model is the zone router guest, interactor-zone-router-guest: `router.sgd` and the
    script that writes its trace.
  - The relay is transport-zone-relay: `src/zone_relay.c` is the state machine, `src/zone_net.c`
    puts it on two sockets and a 64 Hz tick, and `src/zone_load.c` is the load generator.
  - The gates that run four clients through the model, with a planted zone, sender and viewer,
    are in interactor-presence-gates, beside the ledger of what each rung moved.

  :: details The rule and what it replaced
  The rule before opened slot `s` where the relay's `now % 6` was 0, 1, 3 or 4. That put the
  senders on different ticks, which is good, and tied a sender's turn to the relay's clock,
  which is not. The rule now needs no shared clock. Five ticks and not six, so that a frame one
  tick early is still taken. A flood gets at most six frames through in five intervals.

  Clients still send on different ticks of the six. That is a courtesy that spreads arrivals,
  kept by the clients. The relay enforces no slot.

  :: details What was measured
  The same fixed sequence was given to the rule in use and to the old rule, kept as a planted
  build. Four clients start at different moments, run 1,000 and 100 parts in a million fast and
  slow, and arrive up to 0.4 of a tick early or late.

  | Rule | Honest frames sent | Honest frames refused | Flood frames refused |
  | --- | --- | --- | --- |
  | open 5 ticks after the last frame | 25,602 | 0 | 128 of 128 |
  | open on a fixed tick of the relay's clock | 25,602 | 1,894 | 128 of 128 |

  On sockets, four client threads on one machine: 0 honest frames refused of 960 over three
  runs, where the first run under the old rule refused 7 of 320. A Linux runner printed the same
  figures as the development machine.

  :: details Gates and controls
  Each gate prints a result line, and each control plants a defect that must be caught.

  - Trace: the C relay answers every one of 1,469 recorded calls as the model did. Controls:
    five planted models, each of which must fail at the record where it first differs.
  - Opaque: the relay's source touches a frame only to store it and to send it. Control: one
    planted read of a frame byte.
  - Clocks: the table above. Controls: the old rule, and a flood.
  - Sockets: no viewer gets a frame that differs from what was sent, or its own, or one from
    the socket of the other half. Controls: a relay that sends from the wrong socket, and 6 ms
    of planted work in every tick, which must move the median tick by at least 5 ms.

  :: details What it does not guarantee
  - It can drop or delay, and honest clients cannot route around it.
  - A relay that is handed one pair key can alter a frame for that one viewer under a valid
    tag. The honest majority then names that viewer and not the relay.
  - A person here is an address. The home server's member table, and a datagram refused
    because its address was never named, arrive with the transport step.

  :: details What is not known
  - The cost of one datagram. The development machine charges about 0.4 ms for a loopback
    datagram, so its times compare one run with the next and nothing else. No number of people
    is claimed.
  - Whether a ring of submissions on Linux beats one send a datagram. That is a later rung, on
    a Linux machine of ours.
  - How the relay shares a viewer's frames among more than four people. The frame budget and
    its levels of detail by Morton prefix depth are a later rung.

  :: details The problem
  The relay had been made blind to frames and was still not blind to time.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2493", :provides, "router-only-zone"
    relate "rfd-2493", :spends, "elf-guest-native-translation"
    relate "rfd-2493", :is_a, "zone-relay"
  end
end
