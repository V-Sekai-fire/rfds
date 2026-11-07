# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2445, "the lesson surface is an independent native slice", :discussion do
  flight_level :l1
  feature "a teacher puts a board and a shared screen in the campus zone; learners see both."

  scope "the board and the shared screen as one native program, its gate and its control."

  prose ~S"""
  :: hook
  Can a teacher teach a daily lesson in the campus zone with a board and a screen to show?
  :: intrigue
  The campus beta lets two people see, hear and draw. A lesson also needs a flat surface that
  everyone in the zone reads at once: strokes on a board, and a window from the teacher's desktop.
  Nothing built yet carries a surface that is not an avatar.
  :: exit
  Run the board gate and the screen gate against recorded inputs. A dropped stroke and a frozen
  frame must each fail their gate.
  :: decision
  - The lesson surface ships as one native program with no editor or browser. It owns two things
    in a zone: a board that takes pen strokes, and a screen that shows frames from a window on
    the teacher's desktop (operator, 2026-11-07).
  - The board is the pen's first rung, RFD66606-2287, drawn on a flat surface in place of a
    garment. The slice reuses the stroke message of RFD66606-2438 and adds no second stroke
    format.
  - The slice runs with no avatar, voice, party or shop present. Its inputs are a recorded stroke
    stream and a recorded frame stream in place of those parts (operator, 2026-11-07).
  - Native means a riscv64 guest ELF for the sandbox, run binary-translated (operator,
    2026-11-07). Its gates run on the CPU guest as the parity oracle (RFD66606-2374,
    RFD66606-2390).
  - The host is the win64 build of RFD66606-2360. It runs on the Steam Frame and the Steam Deck
    through FEX, and the slice's gates run there too (operator, 2026-11-07).
  :: related
  - RFD66606-2360, the one beta.
  - RFD66606-2438, the pen and its stroke message.
  - RFD66606-2436, the zone's list of people.
  """

  details_title "the lesson surface is an independent native slice"

  prose ~S"""
  :: details What the beta asks
  The operator teaches a lesson for 2 hours every day, one on one or to the party's seats. The
  teacher draws on a board and shows a window, and each learner in the zone sees both. The slice
  holds that and nothing more: a board and a screen that every person in the zone reads alike.

  :: details The board and the screen
  The board is a flat surface with a list of strokes. A stroke is drawn once and every viewer
  lists it once, in order. The screen is a flat surface that shows the newest frame of a window.
  A frame arrives once and a viewer never shows an older frame after a newer one. The two surfaces
  share the zone and the capability that lets one person write to them.

  :: details The slice's edge
  In: a zone, a teacher, a recorded stroke stream and a recorded frame stream.
  Out: avatars, voice, outfits, seats and books, which are the sibling slices, and how a window is
  captured on the teacher's desktop. The edge is a message shape between the teacher's program,
  the zone and a viewer. Its first step writes it down.

  :: details Gates and controls
  Each gate has a control that plants the defect and must fail.

  - Board: a viewer replays a stroke stream and its board lists every stroke once, in order.
    Control: a stream with a stroke dropped.
  - Screen: a viewer replays a frame stream and its screen shows the newest frame at every step,
    never an older one after a newer one. Control: a stream that freezes on one frame.
  - Capability: the teacher's strokes and frames are shown. Control: the same message from another
    person, which must be refused.
  - Alone: the program starts and passes its board and screen gates with every sibling slice
    absent. Control: a sibling's message planted in the input, which the program must refuse by
    name.

  :: details Frontier learning picks the runs
  The slice's gates run as levels in RFD66606-2309's sense, scheduled the way RFD66606-2323
  schedules the store's attacks.
  A level is an input family with fixed attributes: the stroke rate, the frame rate, the frame
  size and the loss pattern in the recorded stream. A problem is one 5 minute replay of a
  stream with a drawn seed and offset.

  | Level | Planted defect | Found when |
  | --- | --- | --- |
  | stroke drop | the zone drops a stroke | a viewer's board lacks a stroke |
  | stroke double | a stroke is listed twice | a viewer's board lists it twice |
  | stroke order | strokes arrive out of order | a viewer's board differs from the replay |
  | frozen frame | the screen stops on one frame | the screen shows an old frame |
  | stale frame | an older frame follows a newer one | the screen steps back |
  | wrong writer | another person writes to a surface | the surface accepts it |
  | sibling input | a sibling's message planted | the program accepts it |

  Each level runs on the slice as it is and on the slice with that level's defect planted. On the
  planted target, success is the defect found. Regret `1[s ≥ 1] − s/n` over the last eight runs
  is high when a level finds its defect only some of the time. Mutation moves one attribute and
  is kept only when the planted find rate rises.
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
  - How long a frame may take from the teacher's desktop to a viewer before a lesson feels broken.
    Nothing has run, and no number is claimed.
  - How large a frame the guest can decode on the Steam Frame through FEX at the pose rate of
    RFD66606-2442. Each is read from a run before a size is fixed.
  - Whether the board is a flat surface the pen of RFD66606-2438 already draws on, or needs a
    surface type of its own. The first step reads that source.
  :: details The problem
  RFD66606-2360 listed five features, and none of them gives a lesson a board or a screen.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2445", :provides, "lesson-surface"
    relate "rfd-2445", :spends, "binary-translated-only-timings"
    relate "rfd-2445", :spends, "elf-guest-native-translation"
    relate "rfd-2445", :spends, "fex"
    relate "rfd-2445", :is_a, "native-slice"
  end
end
