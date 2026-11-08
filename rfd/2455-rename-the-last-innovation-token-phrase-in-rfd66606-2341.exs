# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2455, "Rename the last innovation token phrase in RFD66606-2341", :prediscussion do
  feature "the last innovation token phrase in RFD66606-2341 should match the renamed ledger."

  scope "RFD66606-2341's prose and its household-units gate on two carried lengths."

  prose ~S"""
  :: hook
  Can the last innovation token phrase in RFD66606-2341 be renamed without tripping the
  household-units gate?
  :: intrigue
  RFD66606-2341 still writes "spends no innovation token" while the rest of the ledger now
  uses INNOVATION-TOKEN after the rename in RFD66606-2351. Editing that phrase trips the
  household-units gate on two lengths the file already carries, 3 cm and 5 mm, because the
  edit touches lines the gate already tracks. The gate needs household anchors for both
  lengths added in the same change, or the rename alone will fail it. This was found while
  renaming the ledger in RFD66606-2351.
  :: exit
  Add household anchors for 3 cm and 5 mm, rename the phrase, then run the household-units
  gate.
  :: decision
  - Add a household anchor for the 3 cm length in RFD66606-2341 (proposed).
  - Add a household anchor for the 5 mm length in RFD66606-2341 (proposed).
  - Rename "innovation token" to INNOVATION-TOKEN in the remaining phrase (proposed).
  - Run the household-units gate to confirm both anchors clear it (proposed).
  :: related
  - RFD66606-2351, the ledger rename this phrase lagged behind.
  """
end
