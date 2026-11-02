# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2370, "a visual comparison is a labelled contact sheet", :discussion do
  flight_level :l2
  scope "the contact sheet that delivers a visual comparison."

  prose ~S"""
  :: hook
  A visual comparison arrives as one labelled contact sheet that a model and a human both read.
  :: intrigue
  A sheet is composed by rendering, never by a GDScript loop over pixels, and no gate reads a
  sheet.
  :: exit
  Check a new visual comparison against the rule: one row per case, one column per source, each
  cell labelled with its metric, failures first.
  :: decision
  - A visual comparison is delivered as a labelled contact sheet, the format for both vision-model
    review and human QA: one row per case, one column per source (original, before, after, diff),
    each cell labelled with its metric, failures first, and the numbers kept beside the sheet.
  - These rules hold by agreement. No gate reads a sheet.
  :: related
  - RFD66606-2294, where this rule lived before the split.
  - RFD66606-2283, verification by recording, which the contact sheets deliver.
  - RFD66606-2240, the `.cff` and `<stem>.xmp` sidecar of each sheet.
  """

  details_title "a visual comparison is a labelled contact sheet"

  prose ~S"""
  :: details The layout and how a sheet is made
  &{repo("entities-sakuragaoka-station")}'s `tools/prop_shots.gd` is the precedent for that layout
  only (RFD66606-2283). A sheet is composed by rendering, with fragment shaders into a
  `SubViewport`, or in a godot-sandbox guest, never by a GDScript loop over pixels. Its script
  ships
  as `.sgd`, and its views come from `sphere_hammersley_sequence`.

  :: details Sidecars and copies
  Each sheet carries a `.cff` and its `<stem>.xmp` sidecar (RFD66606-2240). A copy goes to
  `lookdev-contact-sheets/` on the Desktop of the desk that made it, as `<topic>-NN.png`, the
  number
  rising so that no sheet is overwritten.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2370", :provides, "labelled-contact-sheet-compare"
  end
end
