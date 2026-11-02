# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2288, "guest capabilities: macaroons minted from ReBAC", :discussion do
  flight_level :l1
  feature "A guest ELF reaches outside its own memory only through a
capability: a macaroon that a ReBAC check mints, checked once at the host
call and cached for the VM"
  scope "the godot-sandbox addon's host-call table, every guest ELF that
makes host calls, and the ReBAC tuples of RFD66606-2200"

  prose ~S"""
  :: hook
  A guest ELF reaches outside its own memory only through a macaroon minted from ReBAC.
  :: intrigue
  A ReBAC check on every host call is too slow for calls made every frame, and no check makes
  every guest a leak.
  :: exit
  Read RFD66606-2200 next for the ReBAC tuples that decide what a capability grants.
  :: decision
  Capabilities are an allowlist. A guest starts with none. Each host
  call that reaches outside the guest's own memory needs one, and a new
  need gets a new, narrow capability, never a wider old one. A
  capability is a macaroon. A ReBAC check (RFD66606-2200) mints it, with
  caveats that name the VM, the verb, the object, an expiry at most 5 s
  away and the VM's revocation epoch. The host verifies the macaroon's
  HMAC chain once and caches the grant in that VM's host-call table, so
  each later call costs a bit test and two integer compares. The host
  verifies the macaroon again every 5 s. Bumping a VM's epoch voids its
  cached grants at their next call. A guest's writes to its own memory
  are not host calls, and nothing checks them.
  :: related
  - RFD66606-2200, the ReBAC tuples that decide what a capability grants.
  """

  details_title "guest capabilities: macaroons minted from ReBAC"

  prose ~S"""
  :: details Related
  RFD66606-2287, whose CA relies on no transfer capability for its VM.
  :: details Why check once per grant
  RFD66606-2287's CA keeps its root key in guest memory, but a VM transfer
  carries all of that memory, and so does a host read of it. So the check runs once per grant,
  needs no network round trip, and costs little to repeat.
  :: details The macaroon
  The host that runs the guest holds the macaroon root key and mints.
  Before it mints, it asks the ReBAC store whether a tuple relates the
  subject to the object with the verb. No tuple, no macaroon. The
  caveats are `vm`, `verb`, `object`, `expires` and `epoch`. A zone that
  hands work to another zone adds caveats before it passes the
  macaroon on, which narrows it without a round trip. Nobody can remove
  a caveat, because the HMAC chain then fails.
  :: details The hot path
  The host-call table holds, per VM, one bit per granted capability,
  its expiry and the epoch it was granted at. A host call checks the
  bit, compares the clock with the expiry, and compares the stored
  epoch with the VM's current one. Past the expiry the host verifies the
  macaroon again and refreshes the entry. The 5 s bound keeps a revoked
  grant short-lived and a retry cheap.
  :: details Adding a capability
  A capability names one verb on one object, and the table below carries
  the three that exist as `capability` declarations (RFD66606-2291, ReBAC as a
  DSL feature), so a reader counts them rather than reading for them. A
  new need adds a declaration for that narrow verb and object, and a
  tuple that mints it. A wider capability is not allowed; a second,
  narrow one is. `ca.elf` gets no `transfer` or memory-read capability.
  """

  rebac do
    verbs_from 2200
    verbs_from 2351
    relate "rfd-2288", :provides, "guest-macaroon-capabilities"
    verb :send, "the guest sends a frame to the object relay"
    verb :write, "the guest appends to the object file the zone holds"
    verb :transfer, "the guest's VM moves to the object zone"
    capability :send, object: "session-relay", caveats: [:vm, :verb, :object, :expires, :epoch]
    capability :write, object: "zone-journal", caveats: [:vm, :verb, :object, :expires, :epoch]
    capability :transfer, object: "vm", caveats: [:vm, :verb, :object, :expires, :epoch]
  end

  details "Checks", ~S"""
  Each has a control, and each runs with the guest's real host calls.

  - A host call with no capability is refused. Control: the same call
    with its capability goes ahead.
  - A call after an epoch bump is refused; the same call before the
    bump goes ahead.
  - A call past the expiry is refused until the macaroon verifies
    again.
  - A macaroon with one caveat changed fails its HMAC check, and so
    does one with a caveat removed.
  - A narrowed macaroon passed to another zone cannot do what the wider
    one could.
  - The cost per call is measured against the same call with no check.
    The guest's own memory writes show no change.
  """
end
