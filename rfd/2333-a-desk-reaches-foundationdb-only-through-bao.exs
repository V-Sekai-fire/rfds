# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2333, "A desk reaches FoundationDB only through Bao", :discussion do
  feature "desks and other endpoints keep state in FoundationDB through a Bao engine that checks
each request, never through an FDB client of their own"

  scope "the SQL engine for Bao on FoundationDB, the Bao policies and ReBAC tuples that gate it,
and every desk-side client that stores state, first the cua-driver fork's Elixir tool"

  prose ~S"""
  :: hook
  A desk keeps state in FoundationDB through Bao and holds no FDB client of its own.
  :: intrigue
  FoundationDB checks no permission per key: a client certificate opens every key, Bao's
  own storage included.
  :: exit
  Before a desk keeps state in FDB, route it through
  &{repo("service-bao-sqlite-fdb")} with the desk's agent certificate. Read RFD66606-2316 for
  what Bao may hold.
  :: decision
  - No desk or other endpoint outside the cluster's machines holds an FDB client certificate
    or a route into the cluster's private network (operator, 2026-10-23).
  - Desk state that must live in FDB goes through &{repo("service-bao-sqlite-fdb")} beside Bao.
    The desk logs in with its own agent certificate, and Bao policy plus the ReBAC tuples of
    RFD66606-2200 and RFD66606-2202 check every request before the engine touches FDB (operator,
    2026-10-23). The desk keeps no standing credential.
  - Structure is code and churn is data (operator, 2026-10-23): the engine runs only statements
    its startup catalog registers, and only the rows they write go to FDB.
  - The engine picks the caller's database from the caller's Bao identity, not from the path.
  - Each database has a size cap, a write-rate cap and a growth gate, as RFD66606-2316 asks.
  """

  details_title "A desk reaches FoundationDB only through Bao"

  prose ~S"""
  :: details Related
  - RFD66606-2140 and RFD66606-2353, Bao on FDB; RFD66606-2316, what Bao may hold.

  :: details Sources
  Written on 2026-10-23 from the operator's rulings in one session: route desk state through
  Bao as zero-trust ReBAC rather than store ReBAC as FDB variables; FDB has no ReBAC, and the
  tracer runs on endpoints far from the cluster's security; make the structure into code and
  the churn into FDB. The engine's paths, catalog and modes were read from its checkout; the
  mounts were read from a running Bao with a desk's agent login.

  :: details What a desk could reach before this RFD
  - FDB's own TLS checks the peer's certificate name and nothing else. A peer that passes may
    read and write any key, including the encrypted entries Bao keeps there.
  - An FDB client reads the coordinators from its cluster file and then dials every process at
    the address the process advertises. A single forwarded port, or a tunnel to one machine,
    reaches the coordinators and no further, so a desk client would need a route into the
    cluster's private network as well as a certificate.
  - A desk already reaches Bao over the tailnet with its agent certificate. That path is
    authenticated per login and carries no FDB credential.

  :: details The request path
  1. The desk logs in to Bao with its agent certificate and gets a short-lived token.
  2. It calls a named statement on the engine's mount, `exec/<db>/<name>` or
     `query/<db>/<name>`, with that statement's parameters only.
  3. Bao checks the token's policies. A templated policy scopes each identity to its own
     database; sharing a database is a ReBAC tuple, `<agent>--<verb>--<db>`, turned into
     identity-group membership by the reconciler of RFD66606-2202.
  4. The engine checks again that the database belongs to the caller's identity or to a group
     the caller is in, so a policy mistake alone cannot open another identity's rows.
  5. The engine opens the database through the SQLite VFS on FDB, runs the one registered
     statement, and returns rows. No SQL arrives with a request.
  The engine is the only FDB client the desk's data ever meets, and it runs on the cluster's
  own machines.

  :: details What the engine holds today
  - Paths `query/<name>`, `query/<db>/<name>`, `exec/<db>/<name>`, and listings of both.
  - A startup catalog of named statements; the engine does not start without one.
  - A fabric mode that opens databases through the SQLite VFS on FDB, and a plain mode on
    local files.
  - It does not read the caller's identity, so the database comes from the request path.
  - It has no size or write-rate cap and no growth gate.
  - It is not mounted on the production Bao.

  :: details Caps and the bounded set
  RFD66606-2316 keeps Bao's storage the same size whatever the traffic. The engine's rows sit
  outside Bao's barrier storage but on the same small cluster, whose writes also reach the
  backup, so every database carries:
  - a page cap, set with SQLite's maximum page count, which refuses a write past it;
  - a write-rate cap per identity, refused at the engine before any FDB transaction;
  - a growth gate: many requests leave Bao's own storage unchanged, and a control that writes
    a lease or record per request fails it.
  A desk client coalesces its writes: the latest value of a binding replaces the earlier one
  rather than appending.

  :: details The first consumer
  The cua-driver fork gains an Elixir evaluation tool. The BEAM evaluates the code on the
  desk; the tool itself, in Rust, saves the session's bindings through the engine and restores
  them when a session reopens. The bindings are the churn; the statements that save and load
  them are catalog entries.

  :: details Gates and controls
  - The engine refuses a call naming another identity's database, with the policy left open;
    the control removes the identity check and the call must then succeed, so the gate is not
    vacuous.
  - A database at its page cap refuses one more insert; a control with the cap off accepts it.
  - A burst above the write-rate cap is refused after the cap; a control with no cap accepts
    every write.
  - The growth gate as RFD66606-2316 states it, with its storing control.
  - A desk with only its agent certificate saves and restores a binding; the same desk with
    its token revoked is refused.
  These run first against a local single-process FDB, then on a throwaway ladder cluster, and
  reach production only through the operator's deploy.

  :: details Rollout
  1. The engine reads the caller's identity, and the caps and the growth gate land, with the
     gates above on a local FDB.
  2. The Elixir tool in the cua-driver fork saves and restores through a local Bao and that
     engine.
  3. A ladder cluster carries both, with its own tailnet name.
  4. The operator mounts the engine on the production Bao, writes the templated policy and the
     tuples, and the desks switch over. Nothing on the production cluster changes before this
     step.

  :: details What is not known
  - The page and write-rate caps: no desk workload has been measured. The first consumer's
    tests record its sizes, and the caps are set from them.
  - Whether a templated policy can name a database by the cert login's alias, or needs the
    entity id; the engine-side check settles the identity either way.
  - Latency through Bao against a direct FDB client; the first consumer's tests measure it.
  :: details The problem
  Desks are the least guarded machines in the workspace, so an FDB client
  there would hand the whole cluster to the weakest host.
  """
end
