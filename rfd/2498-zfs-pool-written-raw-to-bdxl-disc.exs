# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2498, "A ZFS pool written raw to a BDXL disc", :discussion do
  feature "a 100 GB BDXL archive is an encrypted ZFS pool image written to the disc raw."

  scope "the encrypted archive image that is written raw to a 100 GB BDXL disc and its contents."

  prose ~S"""
  :: hook
  Can a 100 GB BDXL disc hold an encrypted ZFS pool with no filesystem of its own, and how
  many bytes of files does that leave room for?
  :: intrigue
  A disc normally carries a UDF filesystem, which takes space and hides the blocks from ZFS.
  Written raw to a blank disc, the pool image fills the whole raw capacity of about 100.1
  billion bytes, and ZFS reads the disc device itself. ZFS still keeps about 3% of the pool
  free, so the files get about 96.7 GB.
  :: exit
  Read the section "Layout and budget" for the measured counts. The check passes when the disc
  is read back to the same hash as the image, the pool imports from the disc read-only and
  its files match the budget.
  :: decision
  A BDXL archive is one ZFS pool image of 100,103,356,416 bytes with native encryption, written
  raw to a blank disc, with one dataset per file set and at most 96,500,000,000 bytes of files.
  - The pool's one disk is a file with the 4096-byte sector shift of RFD66606-2496 (ZFS data
    disks). It encrypts with aes-256-gcm and compresses every dataset with zstd.
  - Each file set is one dataset named for the set, and files keep their names and paths.
  - ZFS block checksums replace a separate checksum list. The pool is exported before the
    image is written, and the disc is never mounted or formatted.
  - The disc holds one copy of each block, so only a second disc repairs a damaged one.
  - The image size is the disc's raw capacity, a multiple of 4096 bytes. The burn is refused
    when the blank disc reports fewer blocks than the image holds.
  - The passphrase is a fresh 24-word BIP39 seed phrase, never a wallet seed. The agent makes
    it, pipes it to the pool and stores it in 1Password and the keychain (operator, 2026-11-18).
  - A file set is stored as an encrypted dataset with its own passphrase on a data pool such
    as FIRE202610, and archived by copying it into the disc's pool (operator, 2026-11-18).
  - An M-DISC BDXL disc counts as the same capacity as a BD-R XL disc until a blank one has
    been read in a drive.
  :: related
  - RFD66606-2496 (ZFS data disks), the pool options this archive inherits.
  """

  details_title "Layout and budget for a raw BDXL archive"

  prose ~S"""
  :: details Layout and budget
  The raw capacity of a triple-layer BD-R XL disc is 100,103,356,416 bytes, which is
  48,878,592 logical sectors of 2048 bytes. The figure is listed for BD-R XL and BD-RE XL on
  the Wikipedia page for recordable Blu-ray discs, and the multiplication checks out. The
  ISO standard for these discs and the Blu-ray Disc Association paper give only the rounded
  100 GB, so the exact figure rests on that page and on burning tools that report real
  discs. A raw write needs no UDF space and no formatting, so the image may use all of it.
  A disc that was formatted with defect management first would hold 256 MiB less.

  A trial on the Mac made a pool of exactly that size on a file, with OpenZFS 2.3.1 and the
  options below. The pool reported 99,857,989,632 bytes, and the top dataset offered
  96,753,676,288 bytes to files, because ZFS holds back a share of the pool as slop space. A
  scrub found no errors, and the exported pool imported read-only from the file and loaded its
  key. The 96,500,000,000-byte budget keeps about 253 MB of that offer in reserve. The trial
  did not write to a disc, so the raw write and the read from a disc device are untested.

  :: details Making the pool image
  The options follow RFD66606-2496, with encryption added and a mount point under /Volumes.
  The properties normalization, casesensitivity and utf8only cannot be changed after
  creation. The trial used a key file in place of the passphrase prompt. Set the four
  variables first. IMG is an absolute path, because a file disk needs one. The passphrase
  never goes in a variable: the pool prompts for it.

  ```sh
  export ZBIN=/usr/local/zfs/bin POOL=NAME SET=<set> IMG=/abs/path/NAME.img
  truncate -s 100103356416 "$IMG"
  sudo "$ZBIN/zpool" create -f \
    -o ashift=12 \
    -O encryption=aes-256-gcm -O keyformat=passphrase -O keylocation=prompt \
    -O compression=zstd -O atime=off -O copies=1 \
    -O normalization=formD -O casesensitivity=insensitive -O utf8only=on \
    -O mountpoint="/Volumes/$POOL" \
    "$POOL" "$IMG"
  sudo "$ZBIN/zfs" create "$POOL/$SET"
  sudo "$ZBIN/zpool" scrub -w "$POOL"
  sudo "$ZBIN/zpool" export "$POOL"
  ```

  - The passphrase reaches the prompt on standard input, so no variable or history line holds
    it.
  - The image file is on the internal APFS volume. On the Mac, a file disk on the FIRE202610
    ZFS pool failed with "no such device in pool", and the same create on APFS ran.
  - Autoexpand stays off, so the pool never grows past the image.
  - Compression is zstd on the pool and every dataset inherits it. No dataset sets it to off
    or to another algorithm, because the setting is part of what the checks read back.
  - A scrub needs a writable pool, so it runs before the export and not on the disc.

  :: details Store and archive
  Native encryption is per dataset, so the data pool stays unencrypted and each file set is
  one encrypted dataset: `zfs create -o encryption=aes-256-gcm -o keyformat=passphrase -o
  keylocation=prompt POOL/SET`. Names, sizes and properties of datasets stay readable without
  the key, and file contents, names and paths do not. The archive copies the stored dataset
  into the disc's pool. Whether a raw `zfs send` keeps the stored key or the disc pool's key
  governs the copy is untested, so the first archive records which tool was used.

  :: details Writing the disc
  The first burn tests the write path, so record which tool and flags worked. The candidate on
  the Mac is `xorriso -as cdrecord`, which writes a raw data track from an image file. Read
  the blank disc's reported block count first and refuse the burn when it is under
  48,878,592. After the write, read the whole disc back and hash it against the image.

  :: details The passphrase
  The passphrase is a 24-word BIP39 seed phrase, which carries 256 bits. The agent draws 32
  random bytes, appends the 8 checksum bits and maps each 11 bits to a word of the list, then
  stores the phrase in 1Password and the login keychain without printing it. The operator may
  also keep it on paper apart from the disc. The pool takes the words themselves, lowercase
  and separated by single spaces, as the passphrase, piped from the keychain to the prompt.
  The pool derives no wallet seed from the words. The word list is the attachment
  `bip39_english.txt` in this RFD's apparatus directory, with its source and license in the
  `NOTICE.md` beside it. The agent recomputes the checksum bits from the stored phrase before
  the pool is made, and reads the keychain and 1Password entries back to the same words.

  :: details Checks
  - Capacity: the blank disc reports at least 48,878,592 blocks, and a blank M-DISC BDXL disc
    is read in a drive and compared with the raw figure above.
  - Compression: `zfs get -r compression NAME` reads zstd on the pool and on every dataset,
    run before the export.
  - Budget: the files total at most 96,500,000,000 bytes, read from the datasets' used space.
  - Readback: the whole disc reads back to the same SHA-256 as the image.
  - Import: the pool imports from the disc device read-only, the key loads, and the files
    open.
  - Cross host: the same disc imports on Linux and Windows with OpenZFS.
  """
end
