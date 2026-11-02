# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 1125, "Two prose gates, one for each kind of writing", :discussion do
  feature "prose enforcement, and which rule reads which kind of writing"
  scope "`1000-conventions/README.md`, `tropes-removal-model`"
  attest_in :none

  prose ~S"""
  :: hook
  Technical writing answers to ASD-STE100, and an essay answers to the AI-trope table.
  :: intrigue
  RFD66606-1000 requires ASD-STE100 for every document here, and that rule was written for one
  kind of writing but is applied to two.
  :: exit
  Mark each section with its gate (RFD66606-2361), and run the table against the corpus
  first (RFD66606-2362).
  :: decision
  **Technical writing answers to ASD-STE100**, through the existing enforcer:
  code comments, error messages, procedures, any measurement or schema.

  **An essay answers to `seeds/ai_trope.parquet`**, which already exists,
  seeded from https://tropes.fyi. A `README.md` is an essay throughout. That
  table assigns READMEs to ASD-STE100 today, and this RFD reverses it.
  :: related
  RFD66606-1000 states the rule this supersedes. RFD66606-1063 moved enforcement to a
  write-time hook, so this adds a hook and not a script. RFD66606-1124 gives the
  measure-first rule, and the reason these gates read an AST.
  RFD66606-2361 marks sections, and RFD66606-2362 measures the AI-trope table.
  """

  details_title "Two prose gates, one for each kind of writing"

  prose ~S"""
  :: details Why the rule was split
  <!-- gate: tropes -->

  The blanket rule was not wrong when it was written. It was written for one kind
  of document, and the repository then grew a second kind without anyone noticing
  that the rule had stopped fitting.

  ASD-STE100 exists so a maintenance technician reading in their second language
  can take a procedure and act on it correctly the first time. Every constraint it
  carries serves that: bounded sentences, one approved term per referent, no
  contractions, no ambiguity about what a pronoun points at. Applied to a schema
  table or an install step, those constraints are exactly right.

  Applied to an argument they remove the structure of its reasons. A decision
  persuades through how its reasons sit against each other, and a controlled
  vocabulary flattens that into a list of assertions. The reader loses the ability
  to tell a load-bearing claim from an incidental one.

  The failure an essay actually has is one ASD-STE100 says nothing about. An essay
  fails by reading as though nobody wrote it. The tropes.fyi catalog names that
  failure, which is why a second gate buys something instead of duplicating the
  first.

  :: details The conflict this RFD resolves
  <!-- gate: tropes -->

  `seed_ai_tropes.py` already assigns work to each table, and it puts READMEs on
  the ASD-STE100 side:

      trope.parquet      ASD-STE100        READMEs, procedures, reference, rules
      ai_trope.parquet   AI-writing tells  essays, design notes, logbook entries

  This RFD moves READMEs to the other column. The disagreement belongs in the open
  rather than under a silent overwrite.

  That assignment is defensible on its own terms. A README in most repositories is
  reference material, and reference material belongs under a controlled language.
  It is wrong here because an RFD README is not that kind of README. RFD66606-1000 asks
  it to state a problem and a decision in forty lines, which makes it the most
  compressed argument in the repository rather than the most procedural document.

  The measurement decides it rather than merely permitting it. Both tables were run
  over the same 119 READMEs, through the same extractor:

  | table                    | documents flagged | hits  |
  | ------------------------ | ----------------- | ----- |
  | `ai_trope.parquet`       | 10 of 119         | 11    |
  | `trope.parquet` patterns | 119 of 119        | 4,397 |

  Three orders of magnitude apart, on identical input. `Three+ Nouns in a Row`
  alone flags every document in the corpus. `Contraction Used` flags roughly two
  thirds of them, and `Semicolon Used` about a quarter.

  Neither number is a verdict, and the trope side is not flattered by the
  comparison: its 11 hits are all false positives, as RFD66606-2362 records.
  These are weak-label screens from `scripts/seed_labels.py` rather than the
  shipped classifier, which applies thresholds these patterns do not. Read them as
  direction and magnitude, not as counts of real defects.

  The direction is the whole argument. A gate that fails 119 documents out of 119
  is not holding a standard, it is producing noise, and people stop running it.
  `prose_nodes.py` was written to avoid the same outcome, which arrives here
  through the choice of table rather than through the choice of parser.
  :: details The problem
  ASD-STE100 is a controlled language for technical writing, and a schema table is better under
  it. An argument is not, because a controlled vocabulary flattens an argument into a
  specification. An essay also fails in a way ASD-STE100 never describes, since it can read as
  though a model wrote it. Neither kind owns a whole file either: a `DETAILS.md` carries a
  measurement beside the reasoning that motivates it.
  """

  rebac do
    verbs_from 2351
    relate "rfd-1125", :provides, "prose-gate-per-section"
  end
end
