# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2321, "the autobattler fields Frames that wear", :committed do
  feature "each fighter in the SolidCraft autobattler is a Frame put together from guest
solids, rolled on survey tables, and it carries wear from round to round"
  scope "the SolidCraft autobattler: its game script, its page and its zone version"

  prose ~S"""
  :: hook
  Autobattler fighters are Frames that carry wear from round to round.
  :: intrigue
  Each unit was one bare solid with no identity, and every round started from zero.
  Nothing on screen said which unit was hurt or why a round ended.
  :: exit
  Run the game script with `--selftest` and `--rounds=N` to read a sim of the rounds.
  :: decision
  Each squad in the SolidCraft autobattler fields five Frames. A Frame's body is
  put together from solids the guest kernel builds, and its species, presentation
  and age come from three d100 rolls on the population survey tables of our
  appendix-E dataset. A Frame that survives a round stays with wear and leaves
  after five rounds, and each side earns scrip per round, as in the Gyre setting.
  The operator asked for more Frames, game feel, the Gyre flavour and readability
  on 2026-10-17.
  :: related
  - RFD66606-2379, where the desktop builds ship: the release that carries this game.
  - RFD66606-2085, RFD66606-2091 and RFD66606-2120, the Gyre setting (abandoned): the source of
    Frames, wear and scrip.
  """

  details_title "the autobattler fields Frames that wear"

  prose ~S"""
  :: details Roles, props and the zone as requested
  Each Frame also has one of three roles, melee, range or cyber, that beat each
  other as in rock, paper, scissors. The operator requested the roles on
  2026-10-18. Each role and the plant also need a prop in a mirrored arena:
  cover, a relay per side or soil. The operator requested them the same day.
  On 2026-10-19 the operator requested that the game also run as a fabric zone
  that headsets join, with the store kept off every frame and every tick.

  :: details Sources
  Drafted on 2026-10-17 from the game script as shipped, its self-test logs on
  each system and the operator's requests of the same day.

  :: details What a Frame is
  The guest builds 18 solids while the game loads: 12 whole solids and six parts
  (a head, a limb, a torso, a ring, a cube and a base). A Frame places parts by
  species and merges them into one mesh, so a Frame is one draw call; the parts
  become separate pieces only when it breaks. The bounds of the parts set health,
  damage, speed and reach, as the single solid did before.

  - Species: humanoid 1-50, semi-humanoid 51-88, synthetic 89-94, uplifted
    animal 95-96, plant 97-98, exotic 99-100.
  - Presentation: feminine 1-71, masculine 72-89, other 90-100.
  - Age: youth 1-58, juvenile 59-75, adult 76-87, no age 88-99, infant 100.

  The bands are the raw survey distribution, tables E.8 to E.10. Age scales the
  body and the head. Each species but humanoid adds one trait: semi-humanoid is
  fast, uplifted animal is very fast with less health, synthetic is plated and
  slower, plant regrows and is slow, and exotic is one bare whole solid that hits
  hard.

  :: details Wear and scrip
  A Frame that survives a round gains one point of wear, and its maximum health
  drops by a tenth of its base for each point. At five points it leaves. New
  drafts fill the empty places. Each side earns two scrip per round plus one per
  Frame left, and the winner three more.

  :: details Feel and readability
  A hit flashes the Frame and plays a short generated sound. A Frame that breaks
  throws its parts and shakes the camera. Each Frame has a health bar and a name
  tag, a little of its side's colour shows even in shade, and the end of a round
  shows the Frames left and the scrip earned.

  :: details Roles
  Melee beats range, range beats cyber and cyber beats melee. A hit on the role
  the attacker beats does 1.6 times its damage, a hit on the role that beats it
  does 0.6 times, and a hit on the same role does its normal damage. Reach puts
  the roles in order: melee hits at the reach of its body, cyber at 3.8 m and
  range at 7 m, so a range Frame shoots a cyber Frame before the cyber Frame can
  answer, and a melee Frame has to close the gap to a range Frame.

  - Melee: 1.25 times the health, 1.15 times the speed, an attack every 0.8 s,
    and a shield in front. Its hits push the target back.
  - Range: 0.75 times the health, 0.8 times the damage, 0.9 times the speed, an
    attack every 1.1 s, and a barrel at the shoulder. Each shot is a small
    sphere that flies to the target.
  - Cyber: 0.95 times the health, 0.7 times the damage, an attack every 1.0 s,
    and a dish on top. Each hit adds 0.7 s to the target's next attack and shows
    a ring that spreads over the target.

  The role's parts come from the same catalog of guest solids and merge into the
  Frame's one mesh, but they do not count toward its health, damage or reach.
  Each squad's draft holds every role at least once, so every round shows the
  triangle; the other two places draw a role at random from the round's seed.
  The name tag shows the role before the species.

  :: details What the world gives each role
  Each role and the plant now need something in the arena, so a sim shows
  what the world adds and what it takes away. The operator requested these
  props on 2026-10-18, for every role at once so that no role is the only one
  that depends on the world.

  - Range needs a clear line. Five cover blocks stand in the middle. A range
    Frame does not shoot through cover; it walks around the block until the
    line is clear. Every Frame walks around cover, not through it.
  - Cyber needs its relay. Each side has a relay mast, with its reach drawn as
    a faint disc on the floor. A cyber Frame jams only within 6.5 m of its own
    standing relay; away from it, the hit does half damage and no jam. A cyber
    Frame waits at the edge of the disc while friends who are not cyber still
    fight. Any Frame can attack the enemy relay (160 health). A relay that goes
    down stays down until the next round.
  - Melee needs open ground. Within 0.9 m of cover a melee Frame moves at 0.6
    times its speed and its hits do not push the target back.
  - A plant needs soil. It regrows (4 health per second) only on one of four
    soil patches. Below half health it walks to the nearest patch and stays
    until it is nearly whole.

  Equity is a property of the layout: each prop has a twin of the same shape at
  the mirror place across the middle line, side 0's relay is on side 0's half,
  and a tie in which way to walk round cover goes the same way for both
  sides. The self-test checks the mirror and fails when one block is moved
  0.5 m (the control). It also checks that a line through the middle block is
  blocked and a line past the blocks is clear. Each round prints a `WORLD`
  line: seconds range Frames spent with no clear line, cyber hits with and
  without the relay, seconds melee Frames spent beside cover, seconds plants
  spent on soil, and each relay's health. `--rounds=N` with `--selftest` runs
  N rounds for a longer sim.

  :: details Zone server and VR mode
  The round is deterministic: one seed gives the same `ROUND`, `DAMAGE` and
  `WORLD` lines on the web and on the three desktop systems. That makes the game
  a fit for an authoritative zone. The zone server runs the round headless, and
  every client shows the same round.

  Three loops run at three rates, and only the last touches the store.

  - The headset renders at 144 Hz, a frame every 6.9 ms. It predicts poses
    locally and never waits on the network or on a commit.
  - The zone runs the round at a fixed tick. At the start of a round it sends
    the seed and both drafts on a reliable stream. Each tick it sends every
    Frame's place and health as datagrams, where the next tick replaces a lost
    one, and hits, breaks and the round's end on the reliable stream. The zone
    and transport are those of &{repo("interactor-fabric-zone")}.
  - After a tick, the zone hands its SQLite journal image to a save thread if
    it changed. The save thread writes the image to SQLite on FoundationDB
    (&{repo("datasource-store")}) and keeps only the newest one: a save that is
    still in flight when the next is ready is replaced, not queued. A slow
    commit makes the stored image older; it never holds a tick or a frame.

  The store's place in the third loop comes from a measurement. On 2026-10-19,
  sixteen players committing one row 20 times a second waited 5.5 to 6.0 ms
  for the median commit on the Windows desk's FoundationDB under WSL, and over
  one player-day the worst waits reached 3.3 to 4.7 s. A typical commit is
  already a whole frame at 144 Hz, and the worst is hundreds of frames.

  The zone version lives in a new interactor repository, named
  interactor-solidcraft-zone and placed in the goal manifest when it is made. The
  game's Godot project moves there as the one source, with a zone-server mode
  and a headset mode. The Space keeps the web build and the downloads, built
  from that repository. The guest kernel and the zone repository stay as they
  are and are used as dependencies.

  Each step has a check, and each check has a control.

  - The Space's web build prints the same lines after the move as before it.
  - Two headless clients beside a zone server print the server's `ROUND`,
    `DAMAGE` and `WORLD` lines. A client given another seed must differ.
  - The headset mode runs under the XR Pilot desktop runtime, which an agent
    drives with no person in a headset.
  - The save thread reports the age of the newest stored image over a
    player-day: its worst and how often it passes 1, 2 and 5 s. The planted
    slow commit must raise it.

  The zone simulates at 60 Hz and sends rows under RFD66606-2326's byte budget.
  Two choices are open: whether the headset client is the V-Sekai client or a
  scene in the game's own project, and which host runs FoundationDB in
  production. A run on a plain Linux runner, pending on 2026-10-19, says
  whether the multi-second waits come from the WSL host.

  :: details The autobattler is the network test bench
  RFD66606-2326's numbers so far come from walkers generated for the test, whose
  rows never repeat. The autobattler gives real traffic with an answer key.
  One seed fixes every round, so the server's replay of a seed is the truth
  for every row a client receives, at every tick.

  - Scale. One zone runs many arenas side by side, from one to a few hundred,
    each a round of ten Frames on its own seed, with headless players placed
    so their view holds from tens to thousands of Frames. Arenas start a few
    ticks apart, so hits, breaks and round ends spread over time.
  - Classes. The zone carries what the game carries, not one kind of mover:
    Frames on scripted moves, players' tracked heads and hands, props at
    rest that change only when touched, and crowds of pedestrians who stop,
    start and walk in pairs. Headless
    players replay recorded head and hand tracks, since tracked motion has
    sensor jitter a script lacks. Every report is split by class.
  - Scenes. Crowds come as the scenes people make: a shopping street, a
    standing concert, a seated stadium with a wave, a queue, a scramble
    crossing, a dance floor, a parade, a festival plaza, a theatre, a picnic
    lawn, an exit through one door, and a ring of players talking. Each
    scene's density and pace come from footage counted the way the
    blue-hour street walk was, and in social scenes most of the crowd is
    tracked players.
  - Oracle. Each headless client decodes its rows, moves Frames along their
    sent velocity between rows, and compares what it holds with the server's
    replay of the same seeds. It reports the worst position error and how
    long a Frame stayed wrong. A client must never hold a Frame the replay
    says has left, or a value that was never sent.
  - Link. Between server and clients sits a relay that drops and delays
    datagrams: no loss, 1% and 5%, at 50, 100 and 200 ms of round trip.
  - Record. The relay writes every message it passes. The recordings are
    the corpus for the static zstd dictionary: dictionaries built from them
    at 1, 8, 64, 256 and 1024 MB are measured on held-out recordings in
    bytes per row, and the size stops growing where the gain flattens.
  - Report. Bytes per player per second against the budget, bytes per row
    for plain zstd, for patch-from against the last row the client
    acknowledged, and for each dictionary size, and the oracle's errors.
    Saves go through the store's latest-wins thread and report save age.

  On rows generated for the test, sent as the gap from the client's own
  prediction, props at rest cost 0.31 bytes a row, pedestrians 2.16 and
  tracked points 3.96. Walkers that never stop cost 0.47, which flatters
  prediction, so the bench uses pedestrians and never zombies. Scripted
  scenes flatter it the same way: a scripted queue, wave or crossing cost
  0.31 to 0.34, the price of a prop at rest, and a scripted concert 2.04.
  Scenes are replayed from recorded motion where a licence allows, and a
  scene full of players costs what their tracked heads and hands cost. The budget
  gives players near each other the first share, and the bench sets the split
  from recorded traffic.

  Each measurement has a planted defect that must show in the report:

  - the budget ignored, which must push bytes per second over it;
  - a client holding another dictionary version, which must fail to
    decode and never decode wrong values;
  - the clock counter per row, which must make a client order rows wrong
    past 256 rows in a tick;
  - the velocity scale read per tick, which must raise position error;
  - a dropped leave message, which must leave a Frame the replay has
    removed;
  - the store's slow commit, which must raise save age and nothing else.

  :: details What was measured
  The change is in the game script only, so the guest and every translation hash
  stayed valid. On 2026-10-17 the web build and the macOS, Windows and Linux zips
  each started translated, built 18 solids and printed `RESULT PASS`. The script
  cost per physics frame rose from about 0.23 ms to about 0.3 ms on the Mac. The
  web game's slowest frame in the first round read 139 to 145 ms before and
  after. Native frame times on the Mac were not compared: other jobs on the same
  machine made them vary more than the change.

  On 2026-10-18 the roles changed the game script only, again. The self-test
  first checks the triangle: every role beats exactly one other and loses to
  exactly one. A control table in which melee loses to both others must fail
  the same check, and it does. The macOS, Windows and Linux zips and the web
  build in a desktop browser then printed the same two rounds, with the same
  winners and the same damage per pair of roles, and `RESULT PASS`. In round 1,
  range did 303 damage to cyber and cyber did 57 to range. The web game's
  slowest frame in round 1 read 150 ms with the roles and 134 ms without them,
  one run each in the same browser, so the difference is not measured past
  noise. The release kept its tag, because the guest did not change; its zips
  and SHA256SUMS were replaced.

  On 2026-10-18 the world props changed the game script only, a third time.
  The self-test printed `WORLD mirror=true control=false line_through=false
  line_beside=true` on each system. The macOS, Windows and Linux zips and the
  web build in a desktop browser printed the same `ROUND`, `DAMAGE` and
  `WORLD` lines for the four rounds they share; the web run went on to nine
  rounds and the macOS run to twelve. Over the twelve rounds each side won
  six. Per round, range Frames spent 0.3 to 3.0 s with no clear line, melee
  Frames spent 1.2 to 9.0 s beside cover, and cyber Frames landed 1 to 17 hits
  with the relay and 0 to 13 without it. Plants stood on soil in four of the
  twelve rounds, for up to 8.0 s; plants are 2 in 100 of the species rolls, so
  a sim that wants to read the soil rule needs many rounds. No relay went down
  in the twelve rounds (the lowest read 103 of 160). The first version moved a blocked range
  Frame sideways only, and in one round two range Frames stayed blocked for
  34 s until the 45 s limit ended it. A blocked range Frame now walks around
  the block, and no round of the twelve reached the limit.
  :: details The problem
  Each unit was one solid: a box, a cylinder, a sphere or a torus.
  """
end
