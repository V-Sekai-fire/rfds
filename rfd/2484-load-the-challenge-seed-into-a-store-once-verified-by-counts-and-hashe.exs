# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2484,
    "Load the challenge seed into a store once, verified by counts and hashes",
    :prediscussion do
  feature "the challenge seed loads once into a SQLite-on-FoundationDB store through the " <>
            "VFS, with its row counts and content hashes checked against the seed file."

  scope "the import path for `seed/feed.db` into one store, and the counts, hashes and " <>
          "integrity check that verify the import."

  prose ~S"""
  :: hook
  Can the challenge seed be loaded once into a store through the VFS, and verified?
  :: intrigue
  The seed file `seed/feed.db` is 238 MB: 50,000 users, 500,000 posts, and 2,016,005 likes,
  with its schema fixed by `schema.sql`. This table is also the 50 MB to 200 MB table that a
  sibling measurement needs. The seed is in WAL mode, but the VFS (the SQLite-on-FoundationDB
  virtual file system) needs `journal_mode=MEMORY` and `locking_mode=EXCLUSIVE`, and a 4 KiB
  page size, so the import cannot simply reopen the seed file as-is. The VFS already stages a
  commit too large for one FoundationDB transaction, which bounds one transaction to 10 MB,
  so SQLite's backup API or `VACUUM INTO` through the VFS may do the job without hand-chunking.
  :: exit
  Row counts per table match the file seed, a per-table content hash over an ordered `SELECT`
  matches the file seed, and `PRAGMA integrity_check` passes. A planted control, 1,000 posts
  dropped from the store after import, must be caught by the hash and the count.
  :: decision
  - Look first for an existing import path in `datasource-store`: `prove_big_commit.c`,
    `sqlrun.c`, `weft_sql.c`, `tpcc.c`, and `fly/backup-fresh.sh`; try SQLite's backup API or
    `VACUUM INTO` through the VFS before hand-chunking with `ATTACH` and rowid-ranged
    `INSERT ... SELECT` sized well under 10 MB.
  - Import the seed once, not at server start, with `journal_mode=MEMORY` and
    `locking_mode=EXCLUSIVE` set and a 4 KiB page size; record which path ran.
  - Verify with row counts per table against the file seed, a per-table content hash over an
    ordered `SELECT` compared with the file seed (reusing the content sha256 that
    `seed/make-seed.sh` prints, if it exposes one), and `PRAGMA integrity_check`.
  - Run the control: drop 1,000 posts from the store after import and confirm the hash and
    the count both catch it; record import wall time, bytes in the store, and
    `cluster.data.partitions_count` afterwards.
  :: related
  - RFD66606-2382, the skateboard's manifest, which names datasource-store's SQLite VFS over
    FoundationDB as the store this seed loads into.
  """

  details_title "Load the challenge seed into a store once, verified by counts and hashes"

  prose ~S"""
  :: details Look first for an existing path
  Candidates in `datasource-store`: `prove_big_commit.c`, `sqlrun.c`, `weft_sql.c`, `tpcc.c`,
  `fly/backup-fresh.sh`. The VFS already stages a commit too large for one FoundationDB
  transaction (the 10 MB limit), so SQLite's backup API or `VACUUM INTO` through the VFS may
  do the job. Hand-chunk only if nothing exists.

  :: details Method notes
  - The seed is in WAL mode. The VFS needs `journal_mode=MEMORY` and
    `locking_mode=EXCLUSIVE`, and the page size must be 4 KiB.
  - Import once, not at server start.
  - If hand-chunking: `ATTACH` the file seed and `INSERT ... SELECT` in rowid ranges sized
    well under 10 MB, or rely on staging, and record which path ran.

  :: details Verification
  - Row counts per table against the file seed.
  - A per-table content hash over an ordered `SELECT`, compared with the file seed. Reuse
    the content sha256 that `seed/make-seed.sh` prints if it exposes one.
  - `PRAGMA integrity_check`.

  :: details Control that must be able to fail
  A planted missing batch (drop 1,000 posts from the store after import) must be caught by
  the hash and the count.

  :: details Record
  Import wall time, bytes in the store, `cluster.data.partitions_count` afterwards, and
  which path was taken.

  :: details Acceptance
  Counts and hashes match, the planted control fails, the numbers are committed, and the
  sibling measurement that needs this table is told it now has a table to use.
  """
end
