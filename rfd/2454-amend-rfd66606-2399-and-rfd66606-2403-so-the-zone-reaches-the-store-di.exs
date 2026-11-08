# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2454,
    "Amend RFD66606-2399 and RFD66606-2403 so the zone reaches the store directly",
    :prediscussion do
  feature "the zone should reach the store directly instead of routing every request through Bao."

  scope "RFD66606-2399's zone journal design and RFD66606-2403's Bao certificate role."

  prose ~S"""
  :: hook
  Should RFD66606-2399 and RFD66606-2403 describe the zone reaching the store directly, now
  that an operator ruling says Bao is not on every store request's path?
  :: intrigue
  RFD66606-2399 says the zone journal lives in Bao over FoundationDB, and RFD66606-2403 gives
  the zone a Bao certificate role with policy on sqlite-fdb/exec and sqlite-fdb/query. Both put
  a Bao call on every store request. An operator ruled that the zone talks to the store
  directly and reaches Bao rarely, with the credential named in the Fly macaroons design, and
  RFD66606-2351 records that ruling. The two RFDs have not caught up: neither yet states the
  direct-store design, dates the ruling, or names the credential the zone presents. How the
  store verifies a macaroon is also unresolved, since FoundationDB carries no macaroon support
  on its own.
  :: exit
  Name the credential the zone presents to the store, then amend both RFDs in one PR each.
  :: decision
  - Amend RFD66606-2399 to state that the zone reaches the store directly and Bao rarely,
    with the ruling dated (proposed).
  - Amend RFD66606-2403 the same way, replacing the on-every-request Bao certificate role with
    the direct-store credential (proposed).
  - Name the credential the zone presents, per the Fly macaroons design (proposed).
  - Decide what in front of the store verifies a macaroon, since FoundationDB has none of its
    own (proposed).
  :: related
  - RFD66606-2399, the zone journal design this amends.
  - RFD66606-2403, the zone's Bao certificate role this amends.
  - RFD66606-2351, the ruling this carries forward.
  """
end
