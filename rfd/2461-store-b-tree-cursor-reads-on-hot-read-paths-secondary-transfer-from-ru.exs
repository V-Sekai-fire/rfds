# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2461,
    "Store: B-tree cursor reads on hot read paths (secondary transfer from " <>
      "rust-iouring-kensac)",
    :prediscussion do
  feature "hot store reads would skip SQLite's bytecode engine via direct B-tree cursor walks."

  scope "the store's read paths over the weft_fdb VFS, with a SQL fallback kept."

  prose ~S"""
  :: hook
  Does skipping SQLite's bytecode engine on the store's hot read paths buy a real win once the
  read side is already network-bound?
  :: intrigue
  The same outside challenge entry that inspired the compaction thread also walks SQLite's
  B-tree cursors directly inside a read transaction, skipping the SQL engine and its column
  copies, and decoding record bytes by hand with a SQL fallback kept for safety. The store's
  reads already go through prepare and step today. The honest read is that this is a
  constant-factor win, not a network round-trip win: the store's existing speculative reads and
  read-ahead already save roughly a round trip per read and turn two hundred fifty six pages
  into about two round trips, so the entry's trick can add at most something like five to
  fifteen percent, and only if profiling shows the SQL engine's overhead is real.
  :: exit
  Profile the hot read paths first; only build the cursor-based reader if profiling shows
  engine overhead worth the complexity, and keep the existing speculative read and read-ahead
  engineering untouched either way.
  :: decision
  - Profile the store's hot read paths before writing any cursor-reading code, to confirm
    whether the SQL engine's prepare and step overhead is actually a measurable share of read
    latency.
  - If profiling supports it, add a cursor-based reader that walks the B-tree directly inside a
    read transaction and decodes record bytes by hand, with the existing SQL path kept as a
    fallback rather than removed.
  - Treat any win here as a constant-factor improvement on top of the already network-bound
    read path, not a replacement for the speculative-read and read-ahead work already in place.
  - Do not spend further effort on this transfer unless the profiling step above actually shows
    engine overhead large enough to matter.
  """
end
