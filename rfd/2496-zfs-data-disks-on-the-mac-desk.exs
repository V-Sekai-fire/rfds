# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2496, "ZFS data disks on the Mac desk", :discussion do
  feature "a data disk on the Mac desk is one ZFS pool whose settings are fixed at creation."

  scope "the Mac desk's external data disks: the check before a wipe, the pool, its proof."

  prose ~S"""
  :: hook
  Which settings of a ZFS pool can never change once the disk holds data, and what must be
  true of a disk before anyone wipes it?
  :: intrigue
  Nothing in the workspace said how to prepare a ZFS disk. The first one was a 4 TB external
  drive whose partition table named a FAT volume, while its first sector held zeros. Sampling
  125 places across it found only zeros, so the label was stale and the disk was empty. The
  settings that the Mac file browser needs, folded Unicode names and case-insensitive lookups,
  are the ones that cannot be changed afterwards.
  :: exit
  Read the section "The recorded run" for the commands. Run its checks against any pool: it
  passes when every check prints its expected line, and the case control leaves one file.
  :: decision
  - A data disk is one whole-disk pool made with the OpenZFS port for the Mac (operator,
    2026-11-16). The disk is chosen by media name and byte size, never by its disk number.
  - The pool is created with a 4096-byte sector shift, zstd compression, no access times, one
    copy of each block, folded Unicode names, case-insensitive lookups and UTF-8 names only.
  - Before the wipe, the disk is unmounted, sampled for existing data, and the operator
    approves the wipe by name.
  - The pool is done when it reads ONLINE, its settings read back, a written file hashes the
    same after a sync, a second name differing only in case replaces the first, a scrub finds
    no errors and the pool survives an export and an import.
  - A pool is exported before its disk is unplugged. Boot pools on other hosts are out of
    scope.
  :: related
  - RFD66606-2294, the rule that agent knowledge lives in RFDs.
  """

  details_title "ZFS data disks on the Mac desk"

  prose ~S"""
  :: details The recorded run
  The first pool is FIRE202610 on a 4.0 TB external USB drive, 7,814,037,168 sectors of 512
  bytes. The tools are in `/usr/local/zfs/bin`, version 2.3.1, and the kernel module is loaded.

  Before the wipe, the desk read the media name, the byte size and the partition table with
  `diskutil`, then read 4096 bytes at 125 places of the data partition, including the start,
  the middle and the end. All 125 were zeros. A dry run with `zpool create -n` accepted the
  options before the real one.

  The pool is created with these options:

  ```sh
  sudo diskutil unmountDisk force disk6
  sudo /usr/local/zfs/bin/zpool create -f \
    -o ashift=12 -o autoexpand=on \
    -O compression=zstd -O atime=off -O copies=1 \
    -O normalization=formD -O casesensitivity=insensitive -O utf8only=on \
    -O mountpoint=/Volumes/FIRE202610 \
    FIRE202610 /dev/disk6
  ```

  The properties normalization, casesensitivity and utf8only cannot be changed after
  creation. Compression and copies can be changed, and they apply to data written afterwards.

  :: details The checks
  - Status: `zpool status` reads ONLINE with no errors, and `zfs get` reads back each option.
  - Readback: a 200 MB compressible file and a 50 MB random file hash the same before and
    after `sync`.
  - Compression: the test dataset held 243 MB and took 49.7 MB, a ratio of 4.90x. The random
    file takes its full size, so a ratio near 1.00x on it is the control.
  - Case: writing `a.txt` after `A.txt` leaves one file whose content is the second write.
    That is the wanted result on a case-insensitive pool, and a pool that keeps two files
    fails the check.
  - Scrub: `zpool scrub` repairs 0 bytes and reports 0 errors.
  - Table: `diskutil list` shows the data partition as type ZFS and a second 8.4 MB ZFS
    reserve partition, and no FAT or EFI partition remains.
  - Round trip: after `zpool export`, `sudo zpool import` lists the pool ONLINE, and
    `sudo zpool import <name>` mounts it again. `zpool import` without sudo fails with
    permission denied.

  After the import the pool lists its disk by GPT media identifier. That identifier stays the
  same when the drive moves to another port, and the disk number changes, so the record names
  the media and never the number.

  :: details What is not known
  - How often a scrub runs, and who runs it.
  - Whether the filename check holds for decomposed accents. The one test run counted 0 files,
    probably because the shell's locale did not match the accent, so the result proves nothing.
  - The USB link speed of the first drive was not read: `system_profiler` listed no matching
    device.
  - Whether a pool of one disk needs `copies=2` on a dataset worth protecting.
  - How later pools are named.
  """
end
