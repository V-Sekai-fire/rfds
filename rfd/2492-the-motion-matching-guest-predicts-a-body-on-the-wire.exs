# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2492, "the motion matching guest predicts a body on the wire", :discussion do
  flight_level :l1

  feature "a sender states a clip and a time and sends only what the guest cannot predict."

  scope "the presence slice's frame codec: a predictor under Zstandard, its gates and controls."

  prose ~S"""
  :: hook
  Both ends of a presence stream hold the same clips and the same motion matching guest. How many
  bytes of a body does a sender still have to send?
  :: intrigue
  A person's body goes on the wire as 21 entity Packets of 100 bytes, in two frames of 12, once
  every 6 ticks of a 64 Hz clock. Each frame is coded alone against one fixed dictionary.
  Measured on 62 clips, that stream is 8,693 bytes a second at level 19, which is 6% over the
  sustained budget of 8,192. A dictionary cannot close the gap: coding a frame against the send
  before it saves 3%. But the body is not free motion. The stick feeds `mm_step`, which answers a
  clip and a time, and the body is that clip's pose placed in the world. A viewer that runs the
  same guest on the same clips can make most of that pose itself.
  :: exit
  Run the frame size tool on the 62 clips with the predictor in the codec and without it. The
  rung passes when the bytes a second with the predictor are below the 8,693 of the fixed
  dictionary on the same sends, the decoded frames equal the frames that were sent, bit for bit,
  and each of the four controls below is caught.
  :: decision
  - The predictor is the motion matching guest, `mm.elf` (operator, 2026-11-13: "he motion
    matching guest yes."). No learned model is brought in before this has been tried.
  - The predictor sits in the frame codec, under Zstandard. A decoded frame is still 12 whole
    Packets of 100 bytes, so the Packet layout does not change and the observers hash the same
    frames as today.
  - The clip and the time travel in the payload of a Packet that is already sent. Nothing travels
    beside the Packets.
  - Every send states its own clip and time. A frame stands alone, and a lost send does not make
    the next one unreadable.
  - The hash of the clip set and of the guest joins the hashes of the dictionary and of the part
    table as one protocol version. A viewer with another version is refused.
  :: related
  - RFD66606-2436, presence, the slice this codec serves.
  - RFD66606-2442 and RFD66606-2443, the latency metric and the server that carries the frames.
  """

  details_title "the motion matching guest predicts a body on the wire"

  prose ~S"""
  :: details Start here
  This RFD is written so that a session with no memory of the work can begin from it. Read these
  in order before writing anything.

  - The gates repository, interactor-presence-gates in our organisation. Read `docs/wire.md`
    for frames and Packets, `docs/frame-sizes.md` for the measurement this RFD must beat,
    `docs/ledger.md` with `ledger.tsv` for how a rung is recorded, and `tools/frame_sizes.exs`,
    the tool that measures any recorded stream. The parts it joins are repositories of their
    own beside it; the Packet codec is interactor-packets-guest and RFD66606-2493 names the
    rest.
  - The motion matching guest's repository, interactor-motion-matching-guest, which the
    workspace checks out on its interactor side. Its README has `mm_add_clip`, `mm_bake` and
    `mm_step(dt, vx, vz, facing, mode, jump)`, which answers a clip, a time, the character and
    the clip root for each frame.
  - The packet contract, contract-entity-packet. A Packet is 100 bytes: `gid` at 0, position in
    micrometres at 4, velocity at 28, acceleration at 34, the tick at 40, rotation at 52 and 40
    bytes of payload at 58.
  - The avatar follower, interactor-anny-follow-guest. `follow.sgd` and `data/drive.tsv` hold
    the 21 bodies of the muscle skeleton that drive ANNY. Their order on the wire is
    `data/parts.tsv` of the codec's repository, a whole coarse body in the first frame.

  :: details What was measured
  The 62 clips that pass the retarget gates, 29 minutes of motion, were played at the tick and
  written as the frames one person would send. Half the clips built the dictionary and sends of
  the other half were measured.

  | Cadence | Dictionary | Level | Bytes a send | Bytes a second |
  | --- | --- | --- | --- | --- |
  | 6 ticks | none | 3 | 982 | 10,476 |
  | 6 ticks | fixed, 64 KiB | 3 | 947 | 10,100 |
  | 6 ticks | fixed, 64 KiB | 19 | 815 | 8,693 |
  | 6 ticks | the send before | 19 | 791 | 8,436 |
  | 8 ticks | fixed, 64 KiB | 19 | 814 | 6,510 |

  The row to beat is the third. The fourth shows why a better dictionary is not the way: the
  best possible one, the send before, gains 3%.

  :: details Why a predictor should work here
  A body in this slice is made in a chain. The left stick sets a wanted ground velocity. The
  motion matching guest picks a clip and a time. The clip's pose at that time is placed in the
  world, and the muscle skeleton takes it. So for a sender whose body follows the guest, clip,
  time and root placement fix the pose of most of the 21 parts. What they do not fix is what the
  guest cannot know: the tracked head and hands, and what physics adds.

  No number is claimed for the saving. A rough bound, if only the head and two hands carried
  information beyond clip, time and root, is 150 to 250 bytes a send against 815. It is a guess
  until the first rung measures it.

  :: details Loss is another matter
  Zstandard is not an error-correcting code and is not used as one. Compression removes
  redundancy and a code for errors adds it. Loss is concealed by the curve a viewer already
  draws: one lost send costs nothing, and after three a part moves 7% over its top speed for one
  segment. A third interval of playback delay is the first remedy if loss hurts. RFD66606-2327
  has the gait phase the guest matches by, and RFD66606-2363 the controllers that feed it.

  :: details The ladder
  Each rung is held to the rung below it and not to the budget. The budget is where the ladder
  ends.

  Rungs are climbed in this order and none is skipped. A rung is the run of the rung below with
  one thing changed. It is run on the development machine before anything is pushed, and it
  passes when its number is better than the rung below while its controls are caught.

  0. Run `tools/frame_sizes.exs` as it is on the 62 clips. Nothing has to improve: it must give
     8,693 again, so that the baseline is this session's own.
  1. The guest's digest on four hosts, as the MuJoCo guest has. Hosts that agree on `mm_step`
     go from 0 to 4.
  2. Residual frames: each Packet's fields less the predicted pose, for clips played back as
     they are. Bytes a second go below rung 0.
  3. Clip and time in a payload, and the decoder that rebuilds the frame from them. Frames
     rebuilt bit for bit go from none to all.
  4. A body that strays from the clip: head and hands on a recorded track. Bytes a second are
     set against rung 2 and reported as they are.
  5. The codec as a sandbox guest beside `curve.sgd`. Its bytes equal the tool's.

  Rung 1 comes before any coding because a predictor that differs between two machines by one
  bit makes every decoded frame wrong. The MuJoCo guest already has a digest on Linux x86_64,
  Linux arm64, Windows x86_64 and macOS arm64, with the in-process JIT switched off, and that
  check found a defect on its first day.

  :: details Gates and controls
  Each gate prints a `RESULT:` line, and each control plants a defect that must be caught and
  named.

  - Round trip: every frame that is coded decodes to the bytes that were sent. Control: one bit
    of the residual flipped.
  - Alone: a frame decodes with no other frame at hand. Control: a decoder that keeps the clip
    and time of the send before, which must fail when a send is withheld.
  - Version: a viewer whose clip set differs is refused by name. Control: one clip altered.
  - Bytes: the stream is smaller than the rung below on the same sends. Control: a predictor that
    answers the rest pose, which must give no saving.

  :: details Rules a new session must keep
  - The Packet stays 100 bytes and a frame stays 12 Packets. New data goes into a payload.
  - New guest code is SafeGDScript first. Tools are `.exs` and gates are `.gd`. No new Python.
  - Comments are at most 3% of a file's lines. The explanation goes into documentation.
  - Commits are authored as the operator, in sentence case, with no trailer and no agent credit.
  - No file names the reference social VR platform.
  - CI confirms and does not find out: one finished pull request at a time, after the gate and
    its controls have passed on the development machine. No draft pull requests.
  - Meshes are OpenUSD only. The clips come from a private repository whose release awaits a
    provenance check, and they are cleared for this work.

  :: details What is not known
  - Whether `mm_step` is bit-identical across the four hosts. Nothing has run.
  - How far a real player strays from the clips. Only play in a headset shows it, and the bytes
    of rung 4 are a first estimate.
  - The time to code a frame with the predictor. The tick has about 1.8 ms to spare on the
    interpreted tier, so the codec may have to run off the tick.
  - Whether rotation needs its own residual form. The Packet carries rotation in a swing-twist
    code, and a small error there may not be a small number.

  :: details The problem
  The stream is over its budget, the dictionary is spent, and the chosen cadence was kept twice
  by the operator. What is left is to stop sending what both ends already know.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2492", :provides, "motion-predicted-frames"
    relate "rfd-2492", :spends, "elf-guest-native-translation"
    relate "rfd-2492", :is_a, "frame-codec"
  end
end
