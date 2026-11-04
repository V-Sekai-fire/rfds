# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2312, "release tags are go pseudo-versions", :committed do
  feature "a release tag is the Go pseudo-version of the commit it points at, so every tag sorts
by time in a file listing and parses as a version in every package tool"
  scope "release tags in the V-Sekai-fire and chibifire-stages repositories, cut from
2026-10-13 on, and `scripts/check_release_tags.exs`"

  prose ~S"""
  :: hook
  A release tag is computed from its commit, so it sorts by time and parses everywhere.
  :: intrigue
  The orgs' releases carry four naming schemes and no rule. No single scheme among them
  sorts by time in a file listing and also parses as a version in Mix, Cargo, npm and Go.
  :: exit
  Run `elixir scripts/check_release_tags.exs` to recompute every tag, and read below for the later
  parts.
  :: decision
  A release tag is `v0.0.0-<time>-<hash>`: the tagged commit's committer
  time in UTC as `YYYYMMDDhhmmss`, then the first 12 hex digits of the
  commit. It is the shape of a Go pseudo-version, and it is computed from
  the commit, never typed. The core stays `v0.0.0`. A stage, a rung name or
  a "1.0" goes in the release title and the stage branch, not in the tag.
  The operator chose the form on 2026-10-12 ("I like go's").

  :: related
  - RFD66606-2294, interchangeable sessions: the stage branches this RFD leaves
    the stage to.
  - RFD66606-2295, calibrated replies: the times here are UTC, as there.
  """

  details_title "release tags are go pseudo-versions"

  prose ~S"""
  :: details The three parts
  The tag is the first of three parts of one release system. Each part does
  one job: identity is a hash, order is a fixed-width UTC time, stage is a
  pointer that moves, and compatibility is a version on the interface that
  breaks. The details give the later parts.
  :: details Sources
  Drafted on 2026-10-12 from the release inventory, the sort runs and the
  parser runs below, all taken the same day. The form and the "everywhere"
  bar are the operator's.

  :: details What a tag has to satisfy
  The operator's bar: a tag sorts in filesystem order, and the same string
  works everywhere a version is read. Measured on 2026-10-12, each candidate
  through each tool's own parser:

  | Candidate | `ls` order | Mix | Cargo | npm | Go |
  | --- | --- | --- | --- | --- | --- |
  | `v2026.01.05`, padded calendar date | yes | no | no | no | no |
  | `v2026.1.5`, unpadded calendar date | no | yes | yes | yes | yes |
  | `v1.0.0-beta.1` and `v1.0.0` | no | yes | yes | yes | yes |
  | `v0.0.0-20261012203512-50cc405a1b2c` | yes | yes | yes | yes | yes |

  - SemVer forbids a leading zero in a number, so a padded month fails every
    package tool. Unpadded, `2026.10.12` sorts before `2026.9.1`.
  - No file listing puts a release after its own pre-releases: `ls`, `sort
    -V` and Finder all list `v1.0.0` before `v1.0.0-beta.1`.
  - The Go form carries the date inside one alphanumeric pre-release field,
    where SemVer allows the zeros. `ls`, `sort -V` and Finder each put
    samples from January, October, the next day and the next year in time
    order.
  - Python's PEP 440 rejects the Go form. A Python package from the same
    commit is `0.0.0.devYYYYMMDDhhmmss`. Docker's tag grammar admits the form;
    no Docker daemon ran in the measurement.

  :: details What others do
  Read off the live registries on 2026-10-12. Builds between releases put an
  ISO basic date inside the pre-release: TypeScript `7.1.0-dev.20261012.1`,
  React `19.3.0-canary-9f2e1f88-20261012`, Node.js
  `v27.0.0-nightly202610123b639be3a4`, Go `v0.0.0-20261011100332-faecfb24eb49`.
  Calendar versions that must stay SemVer drop the padding: pip `26.2.1`,
  Home Assistant `2026.10.1`. Projects that list versions as strings pad
  instead: the Arch Linux ISOs, `YYYY.0M.0D` since 2012. Only Go's form,
  whose core never moves, sorts as plain bytes and parses as SemVer at once.

  :: details The check
  `scripts/check_release_tags.exs` recomputes every tag from its commit:

      elixir scripts/check_release_tags.exs [<repo>]
      elixir scripts/check_release_tags.exs --self-test

  A tag on a commit from before 2026-10-13 is legacy, counted and named
  rather than failed; renaming a published tag breaks whatever points at it.
  The self-test plants six tags in a scratch repository. The commit's own
  pseudo-version passes; a seven-digit hash, a local-time stamp, a `v1.0.0`
  core, a padded calendar date and a stage-suffixed date each fail by name;
  a pre-cutover tag reads as legacy. Go's own `module.IsPseudoVersion`
  accepts a seven-digit hash, so the 12-digit rule is this check's, not
  Go's. Go does hold a pseudo-version to its commit's time and hash, which is
  why the tag is computed:

      TZ=UTC git log -1 --format='v0.0.0-%cd-%h' \
        --date=format-local:%Y%m%d%H%M%S --abbrev=12

  :: details The later parts
  Each part starts once the one before it runs.

  1. The tag, this RFD.
  2. The stage is a pointer. A moving tag per stage (`dev`, `beta`, `rc`,
     `release`) names the build that stage holds. Promotion moves the
     pointer to the same commit; nothing is rebuilt or renamed. The GitHub
     pre-release flag follows the pointer.
  3. One release record per repository, and every other format derived from
     it. The Godot engine already works this way: `version.py` holds major,
     minor, patch and status; the build adds the commit hash and committer
     timestamp from git; the Windows resource takes `FILEVERSION` from the
     numbers; the Android build turns the status into a digit of
     `versionCode` (dev 1, alpha 2, beta 3). Here the record is the
     repository's `CITATION.cff` (operator, 2026-10-12), in two halves. The
     committed file holds what does not change per build: title, authors,
     licence, the interface versions. A commit cannot carry its own hash, so
     the release step writes the per-build half into the copy that ships
     with the artifact: `version` is the tag, `commit` the full hash,
     `date-released` the UTC date. CFF 1.2.0 admits no other top-level key;
     a `status` key fails its schema. The stage, the derived forms and the
     artifact digests ride as `identifiers` of type `other`: `stage:dev`,
     `windows:YYYY.MMDD.hhmm.0`, `android:<versionCode>`,
     `pep440:0.0.0.devYYYYMMDDhhmmss`, `sha256:<digest>`. A sample of that
     shape validates against the CFF 1.2.0 JSON schema. The check recomputes
     every derived value from the `commit` field.
  4. Compatibility rides on the interface that breaks: a protocol, ABI or
     save-format version that moves only when that interface does, as Go
     moves a module path to `/v2`.
  5. A signed attestation binds the record to the artifact's digest.

  :: details The problem
  Of 60 GitHub
  releases in repositories pushed since 2026-06-01, 33 are SemVer
  pre-releases in at least four spellings, 7 are dates, 2 are plain SemVer
  and 18 are free names.
  """
end
