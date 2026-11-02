# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2399, "the zone journal lives in Bao over FoundationDB", :discussion do
  flight_level :l1
  scope "where the zone journal lives, how it is written and read back."

  prose ~S"""
  :: hook
  The zone journal leaves the guest for Bao over FoundationDB, so a restarted zone resumes.
  :: intrigue
  What if a zone restarts and its journal stayed in the guest? One owner per entity would hold
  only across a hand-off.
  :: exit
  Run `bao read` for a row the zone wrote and check that its entity id and tick match.
  :: decision
  The journal does not stay in the guest. `OpenBao -> fdb -> s3` is the placement.
  `stages/zone_stage.gd` drains `zone_journal_export` under the write capability every tick that
  changed a row and hands the rows to the host's Bao client, which runs the catalogued execs
  `append_mutation` and `append_snapshot` on the database `zone-<id>`. A zone that restarts loads
  its last snapshot back through `query/zone-<id>/latest_snapshot` into `zone_load_snapshot`.
  :: related
  - RFD66606-2293, where this rule lived before the split.
  - RFD66606-2142, the shape of the desk's agent identity over Tailscale.
  """

  details_title "the zone journal lives in Bao over FoundationDB"

  prose ~S"""
  :: details The placement
  The placement is &{repo("service-openbao")} on FoundationDB, &{repo("datasource-store")}'s
  `fdb_vfs.c` giving SQLite pages that live in the same cluster, and
  &{repo("service-bao-sqlite-fdb")} answering `bao read <mount>/query/<name>` and
  `bao write <mount>/exec/<db>/<name>` from a startup catalog and nothing else.

  :: details The write and the schema
  The host's Bao client is the desk's agent identity over Tailscale, RFD66606-2142's shape. The
  schema is `fabric_zone_journal.cpp`'s two tables, `entity_mutations` and `entity_snapshots`, in
  a `schema "zone-*"` block.

  :: details The restart and the garment index
  So one owner per entity holds across a restart as well as across a hand-off. The garment's index
  hash is a row in the same journal, so step 6's fetch has a record a session later.

  :: details Check and controls
  Check: a row the zone wrote is read back by `bao read` with the same entity id and tick, and a
  restarted zone resumes at its last snapshot's tick. Controls: an export with no write capability
  is refused by `capability.gd` before any Bao call. An exec name not in the catalog is refused by
  Bao. The plugin's own `--self-test` plants a fenced database opened without its fence.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2399", :provides, "zone-journal-in-bao-fdb"
  end
end
