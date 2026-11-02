# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 1000, "Conventions", :published do
  scope "all files"
  attest_in :none

  prose ~S"""
  :: hook
  One convention sets how this repository writes, numbers and states its RFDs.
  :: intrigue
  Two repositories allocated RFD numbers from what each treated as a private space.
  :: exit
  Read below for the numbering rule, and run `mix rfd.check` before you push.
  :: decision
  This repository writes Request-for-Discussion documents in the Oxide
  style. Each RFD has a state: prediscussion, ideation, discussion,
  published, committed, or abandoned.

  Technical writing follows ASD-STE100 Simplified Technical English.
  An essay follows the AI-trope gate, and a section names which one it
  takes. RFD66606-1125 gives that rule. Code and identifiers follow neither.

  Each RFD's `README.md` stays at 40 lines or fewer. It states the
  hook, intrigue, decision and exit (HIDE), in the fewest lines that
  keep them true. The `draft-readable-rfd` skill has the BLUF rules.
  Measurement, verification log, deep walkthrough, or code sample
  moves to a sibling `DETAILS.md`, which the site prints on the same page. Retractions
  move with the rest, and stay next to what they retract.
  :: references
  - RFD style: `rfd-driven-architecture` skill
  - Numbering rule and OID arc: `DETAILS.md`. Serials in use: `SERIALS.usda`
  - STE spec: https://www.asd-ste100.org/ Tropes: https://tropes.fyi
  :: related
  See the DRY policy and the STE policy in `decisions/README.md`.
  """

  details_title "Conventions"

  prose ~S"""
  :: details The STE linter
  STE linter: the `simplified-technical-english` Claude Code plugin
  (`fire/claude-ste-plugin`). RFD66606-1063 records the move off a
  repo-local script.

  :: details Where designs live
  The repository keeps designs in one place. The decisions directory
  records durable decisions. The docs tree holds detailed designs.
  An RFD points to its source. It does not copy the source.
  :: details The problem this rule answers
  Two repositories allocated RFD numbers from what each treated as a private
  space. The spaces were the same space. This repository held 116 RFDs numbered
  0000 to 0123. `v-sekai-fabric/multiplayer-fabric-manuals` held 129 RFDs
  numbered 0000 to 0132. 113 numbers named a document in both places.

  The old rule in this file did not cause the collision on its own. It said
  nothing about numbering at all. The root README said the repository used "one
  shared numbering space", and it meant shared across weftspun projects. The
  fabric repository told its writers to check its own listing and, in its own
  words, "not any other repo's own numbering". Each rule was correct inside its
  repository. Together they guaranteed the collision.
  :: details The rule
  An RFD number has four decimal digits.

  The first digit names the organization. This repository uses digit 1. The
  fabric manuals use digit 2. V-Sekai-fire's private manuals use digit 3
  (operator, 2026-10-12). `fire/manuals` reserves digit 4 and has no RFD.

  The last three digits are the serial number. A new RFD takes the next unused
  serial under its own organization digit. A writer no longer checks another
  repository, because another organization cannot reach this digit.

      RFD 1015    this repository, serial 015
      RFD 2015    the fabric manuals, serial 015

  Three decimal digits give 1000 serials for each organization. This repository
  uses 131 of them.
  :: details Where the organization digit comes from
  The digit is a short name for an arc under an IANA Private Enterprise Number.
  PEN 66606 is assigned to iFire. RFC 9371 gives the
  registration procedure, and the assignment is itself the delegation. No arc
  below 66606 is registered with anybody.

  That is also the hazard. RFC 9371 section 1.1 says plainly that no one controls
  how an assignee uses its PEN. Nothing outside this workspace will stop two of
  our own namespaces from minting the same arc. Only a table we keep will.

  So one arc under the PEN names a namespace, and no namespace mints a sibling of
  another:

      66606.1    documents, one arc for each manual site

  The category arc is not decoration. Without it, a manual site and anything else
  this PEN ever identifies allocate from one space. A fifth site would take arc
  5, and whatever else had picked 5 would already hold it.

  No second category is allocated. This document allocates one when something
  needs one, under RFD66606-1070's rule.

  66606.1 carries the sites, and the site arc is the organization digit:

      66606.1.1    weftspun
      66606.1.2    v-sekai-fabric
      66606.1.3    v-sekai-fire
      66606.1.4    fire

  `fire/manuals` names a decision by its date rather than by a serial, so
  digit 4 is reserved and holds nothing. Digit 3 allocates 3NNN serials, and
  its register stays with the private manuals that allocate from it. A reserved
  digit costs one line here. An unreserved one costs what the collision above
  cost, which was 113 numbers meaning two documents at once.

  Site 1 was decommissioned on 2026-08-31. `SERIALS.usda` at arc 66606.1.1 is
  frozen: existing 1NNN serials stay in place and stay citable, and no new
  serial is allocated there. New RFDs in this repository take the next unused
  2NNN serial from `SERIALS-vsekai-fabric.usda` at arc 66606.1.2, whose site
  was decommissioned on 2026-08-29 and reactivated on 2026-08-31 for that
  purpose. The full argument, and the retraction of the 2026-08-29 sentence
  that promised no further allocations under 66606.1.2, is in
  `pen-66606.usda` `sitesDecommissioned`. When site 2 fills up, site 5 opens
  at arc 66606.1.5 under this rule; site 4 stays reserved for a
  date-named register.

  The full identifier of an RFD is:

      1.3.6.1.4.1.66606.1.<site>.<number>

  RFD66606-1015 is `urn:oid:1.3.6.1.4.1.66606.1.1.1015`. The last arc is the four
  digits the folder name already writes. Its first digit repeats the site arc
  above it, and the repetition is worth its cost. The mapping from a document
  number to its arc is the identity, so a reader who can read one can read the
  other. That is what the decimal rule below was for.

  Two rules carry to whatever takes the next category. It keeps a register of
  what it allocates, in the way `SERIALS.usda` does. A kind of thing gets an arc of
  its own rather than a neighbouring parent number, because `<thing>.1.<id>` and
  `<thing>.2.<id>` say which kind they are and `<thing>` beside `<thing+1>` does
  not.
  :: details The searchable shorthand
  A search engine reads `RFD 1015` as two common words, and `rfd1015` already
  names an unrelated account, so neither finds one of these documents alone.
  The shorthand puts the PEN in the name (operator, 2026-10-24):

      RFD66606-1015    urn:oid:1.3.6.1.4.1.66606.1.1.1015
      RFD66606-2287    urn:oid:1.3.6.1.4.1.66606.1.2.2287

  It holds the PEN and the four digits, and the first digit is the site arc,
  so each shorthand names exactly one full identifier. A web search for
  `RFD66606` found nothing when it was chosen, so a search for it finds only
  these documents.

  Every title, citation, code comment, commit subject and pull request title
  writes this form (operator, 2026-10-24). Code, and text quoted from a commit
  or a person, stays as written. `check-rfd-structure.py` refuses a bare
  `RFD NNNN` in rendered prose outside code and quotes, and
  `check_commit_style.py` refuses one in a commit subject; each has a planted
  control that must fail.
  :: details The HIDE beats
  Every live RFD declares three keywords beside its decision (operator, 2026-10-31).
  `RFD.Hide` checks them when the source compiles, so `mix rfd.render` and `mix rfd.check`
  refuse a source without them. In a `prose` block each one opens with `:: hook`,
  `:: intrigue` or `:: exit`.

  - `hook`: one paragraph, the promise. The README prints it in bold above the decision.
  - `intrigue`: one paragraph that ends in a sentence. The README prints it first in the
    problem.
  - `exit`: one paragraph that ends in a period and is not a list item, a table row or a
    code fence. The README prints it last in the decision.
  - The decision is the Delivery, and the README prints it between the hook and the exit.

  An abandoned stub is outside the rule. The test file `test/rfd_hide_test.exs` plants a
  source that lacks each beat in turn, and each one must be refused.
  """

  rebac do
    verbs_from 2351
    relate "rfd-1000", :provides, "rfd-numbering-rule"
    relate "rfd-1000", :provides, "rfd-state-lifecycle"
  end
end
