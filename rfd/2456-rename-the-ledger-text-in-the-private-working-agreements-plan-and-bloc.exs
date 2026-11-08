# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2456,
    "Rename the ledger text in the private working agreements, plan and blocklist",
    :prediscussion do
  feature "the private working agreements, plan and blocklist should match RFD66606-2351."

  scope "three private-repo documents that the weftspun clone cannot reach."

  prose ~S"""
  :: hook
  Can the private working agreements, plan and blocklist be brought in line with
  RFD66606-2351's renamed ledger text from outside the weftspun clone's reach?
  :: intrigue
  RFD66606-2351 now writes every innovation token as INNOVATION-TOKEN, but three private
  documents, the working agreements, the plan and the blocklist, still say "token" in the
  ledger text, and the plan still reads "The three innovation tokens". All three live in
  private repositories the weftspun clone cannot reach, so the edit needs a session with
  access to those repos rather than this one.
  :: exit
  Open the private working agreements, plan and blocklist in a session with access, and match
  their ledger text to RFD66606-2351.
  :: decision
  - Rename the ledger text in the private working agreements to match RFD66606-2351
    (proposed).
  - Rename the ledger text in the private plan, including "The three innovation tokens", to
    match RFD66606-2351 (proposed).
  - Rename the ledger text in the private blocklist to match RFD66606-2351 (proposed).
  - Carry out all three edits from a session that holds access to the private repos
    (proposed).
  :: related
  - RFD66606-2351, the ledger rename these three documents lag behind.
  """
end
