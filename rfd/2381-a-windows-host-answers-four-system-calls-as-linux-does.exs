# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2381, "a Windows host answers four system calls as Linux does", :discussion do
  flight_level :l2
  scope "what a Linux guest needs from the emulator's Windows host."

  prose ~S"""
  :: hook
  A Linux guest runs on the Windows host once four system calls answer as they do on Linux.
  :: intrigue
  A Rust guest linked against static glibc failed on the Windows host, translated and
  interpreted alike, and so did the released addon. The first three fixes left the crash in
  place.
  :: exit
  Check that the Windows host answers `brk`, `clock_gettime`, error numbers and
  `sched_getaffinity` as the Linux host does.
  :: decision
  The emulator's Windows host answers four system calls as its Linux host does:
  - `brk` keeps the new break.
  - `clock_gettime` writes the 64-bit guest's two 64-bit fields.
  - Error numbers map to the Linux numbers in one header.
  - `sched_getaffinity` reports one CPU, as the Linux and macOS hosts do.
  :: related
  - RFD66606-2294, where this rule lived before the split.
  """

  details_title "a Windows host answers four system calls as Linux does"

  prose ~S"""
  :: details What went wrong
  The emulator's Windows host answered four system calls differently from its Linux host:

  - `brk` did not keep the new break. Static glibc puts the main thread's
    thread-local block at the first break, so the heap handed out memory inside it
    and, later, an address in read-only data. This was the crash.
  - `clock_gettime` wrote the host's own `timespec`, a 32-bit nanosecond field with
    padding, where the 64-bit guest reads two 64-bit fields.
  - Error numbers above `ERANGE` follow the Windows C runtime (`ENOSYS` is 40, where
    Linux has 38). glibc chooses its `rseq` and `clone3` fallbacks on `ENOSYS`, so
    the host now maps errors to the Linux numbers in one header.
  - `sched_getaffinity` was missing. The Linux and macOS hosts report one CPU, and
    the Windows host now does the same.

  :: details How the break was found
  A dump of the guest registers and the page's permissions at the fault found the break. The
  fixes are in our libriscv fork, and the addon takes them with Linux's `ENOSYS` for an unknown
  system call.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2381", :provides, "windows-host-four-syscalls"
    relate "rfd-2381", :is_a, "guest-runtime"
  end
end
