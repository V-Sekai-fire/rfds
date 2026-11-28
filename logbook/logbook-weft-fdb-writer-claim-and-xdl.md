# Logbook: weft_fdb writers per database, a wrong retraction, and no extension loading
RETRACTED, MINE, TWICE. First I said a `weft_fdb` database admits one
process at a time and gave "EXCLUSIVE locking" as the reason, taken from
skill text and not from a test. Then, on the owner's "you can parallel
commit", I retracted that and wrote a memory note saying several
processes may write one database. Measured, the first reading was right and
the retraction was wrong. Separately, a database opened through the VFS
could not load a SQLite extension at all: the process crashed.
## The apparatus
datasource-store at `495d87b` (main), `fdb_vfs.c` and its `weftfdb`
loadable extension built out of tree with Nix (cmake, gcc, nixpkgs
sqlite 3.54, foundationdb 7.3.68 client). FDB cluster `weftspun-fdb` on
127.0.0.1:4700. Python 3.12 from nixpkgs. Databases opened as
`file:<name>.v1?vfs=weft_fdb`. Scratch scripts in the session scratchpad,
not committed.
## What the runs proved
Spike 1: process A wrote and held its connection; process B opened the
same database and committed a row. I read that as concurrent writing. It
was a fence handoff: opening raises the database's fence, so B became the
owner and A would have been refused on its next write.
Writer test: three processes, one database, 30 single-row commits each,
started together. One finished 30 of 30 in about 1.2 s. The other two
finished 0 of 30. Their errors were `attempt to write a readonly database`
(11) and `disk I/O error` (79). The 30 rows of the winner were all present;
nothing was dropped silently. `BEGIN` and `BEGIN IMMEDIATE` behaved the same.
The VFS says this in its own comments (`fdb_vfs.c`, "Locking is a no-op.
An actor is the single writer of its own store. The fence, not a lock, is
what stops a second writer"). `spec/ParallelCommit.lean` models what the
owner meant: parallel commit is the CockroachDB-style protocol that stages
several databases' pages and commits them with one transaction record. It
makes a group of databases commit together. It does not admit two writers
on one database; the fence refuses the stale one.
Extension loading: `SELECT load_extension(...)` on a `weft_fdb`
connection killed the process (SIGSEGV). `weft_fdb` leaves `xDlOpen`,
`xDlSym`, `xDlClose` and `xDlError` unset, and SQLite calls the
connection's own VFS for them. Loading sqlite-vec on `:memory:` or on a
database with the weft VFS merely registered was fine; the crash needed an
open `weft_fdb` handle.
## Why
1. I stated an invariant from a skill's summary and did not run it.
2. I then replaced it with the opposite claim from one ambiguous
   experiment and one ambiguous sentence, again without the three-writer
   run that decided it. The skills (`port-service-on-our-stack`,
   `sqlite-on-fdb-elixir`) were right all along; only my memory note was wrong.
3. Nothing had ever loaded an extension through this VFS, so the missing
   methods had no test.
## What stands
- One writer per database. Several databases commit atomically with
  `weft_txn_join`; that function is declared in `fdb_vfs.c` only, not in
  `weft_fdb_vfs.h` and not in the extension.
- Fix for the crash: the four `xDl*` methods delegate to the base VFS
  (null-safe). On local branch `dev/vfs-delegate-dl` in datasource-store,
  not committed, not pushed. With it, sqlite-vec `vec0` cosine nearest
  neighbours (200 rows, exact match first), an FTS5 trigram search and a
  reopen in a second connection all work over `weft_fdb`.
- Python still segfaults at interpreter exit with an open `weft_fdb`
  handle; `close()` then `os._exit(0)` exits 0. Cause not found.
- Not tested: a read-only second handle seeing another process's commits
  (the VFS documents it; planned for the auto-ontology port).
- During the work a `pkill -f <script name>` killed my own shell, because
  the pattern was in its own command line.
## Addendum: the measurements above omitted the required pragmas
Later in the same session a BPF profile (bpftrace uprobes on `weftfdb.so` and `libfdb_c`) showed the test scripts never set
`PRAGMA journal_mode=MEMORY` and `PRAGMA locking_mode=EXCLUSIVE`, which `fdb_vfs.c` says every caller must set. Without them SQLite
created and deleted a journal file in FDB on each transaction, and the writer thread spent 87% of the time blocked on FDB.
- The rates quoted for the three-writer test (30 of 30 in about 1.2 s) came from that broken configuration. Corrected: one writer does
  244 single-row commits/s on the live cluster, 454/s on a RAM-backed FDB.
- Writers per database, rerun with the pragmas: 5 of 5 barrier trials had exactly one writer commit everything and two refused with
  `disk I/O error`; rows, ids and a shared counter all consistent, integrity ok. So the one-writer conclusion stands.
- One earlier run with pragmas and no barrier had two writers both finish 2500 of 2500 with all rows present. Unexplained, not reproduced.
- A third mistake of this kind, after the two above: I presented timing numbers without checking the configuration they ran in.
