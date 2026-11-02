# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2397,
    "the transport step puts a certificate authority and capabilities in guests",
    :discussion do
  flight_level :l1
  scope "the transport and lock-down step: zone and voice guests, the CA and capabilities."

  prose ~S"""
  :: hook
  Two guest repositories carry the transport, a certificate authority and capabilities for zones.
  :: intrigue
  A certificate from another CA is accepted by the null verifier, and a transfer with no
  capability goes through a table that skips the bit test.
  :: exit
  Run the Lean tests over the compiled C++ with an in-memory UDP pair, and make each control fail.
  :: decision
  - Two repositories shaped like &{repo("interactor-lasso")}, placed after it:
    &{repo("interactor-fabric-zone")} and &{repo("interactor-voice")}.
  - `zone.elf` has a player mode, as `FabricZone::is_player` does, so there is no `client.elf`.
  - picoquic lives only in `zone.elf`. `ca.elf` carries mbedTLS only.
  :: related
  - RFD66606-2293, where this rule lived before the split.
  """

  details_title "the transport step puts a certificate authority and capabilities in guests"

  prose ~S"""
  :: details The guests and the host
  - `guest/transport`: `quic_picoquic_backend.cpp` rewritten without
    `picoquic_packet_loop` and its thread: `picoquic_incoming_packet`
    and `picoquic_prepare_next_packet_ex`, driven by `tick(now_us)`.
    Entropy and clock come from the host (`net_seed`, `zone_tick`'s
    wall time). The null verifier is replaced by
    `ptls_mbedtls_get_certificate_verifier` over the session root DER,
    `thirdparty/webtransportd/frame.c` verbatim.
  - `guest/ca`: a root key made in guest memory at `ca_open`,
    `ca_issue(csr, name, now)` issues one-hour certificates for names
    matching `^[a-z0-9-]+\\.zone\\.fabric\\.internal$`. `ca.elf` has no
    transfer entry point at all.
  - `guest/capability`: macaroons as an HMAC-SHA256 chain with caveats
    vm, verb, object, expires, epoch. The host (`stages/capability.gd`)
    holds the root key and hands each VM a derived key, so `ca.elf`,
    which gets none, can verify no transfer. The per-VM bit in the
    godot-sandbox host-call table lands in
    &{repo("entities-godot-sandbox", planned: "4-entities")}.
  - Host: `stages/zone_stage.gd` owns a `PacketPeerUDP`, drains it into
    `net_rx`, sends `net_tx`, calls `zone_tick` once a frame. Enrolment
    is a CSR on an `ENROL` stream the desktop hands to `ca_stage.gd`,
    then a reconnect with mTLS. The root DER passes out of band as a
    launch argument.
  - Vendored at riscv64 from the fabric tag by
    `tools/vendor/from_godot_fabric.py`: picoquic without its socket
    loops and other TLS backends, picotls's four files, mbedTLS with
    `FS_IO`, `THREADING`, `NET` and `SSL` off, SQLite as `OS_OTHER` on
    `spmemvfs`, zstd's three directories. Each directory with a
    `CITATION.cff` naming the tag.

  :: details Check and controls
  Check, Lean tests over the compiled C++ with an in-memory UDP pair:
  a certificate from another CA is refused (control: the null verifier
  accepts it). An expired one is refused (control: the clock frozen at
  issue accepts it). An out-of-pattern name is not issued (control: a
  suffix check issues `a.zone.fabric.internal.evil.com`). A transfer
  with no capability is refused and goes ahead once minted (control: a
  table that skips the bit test lets it through. A macaroon with one
  caveat altered still verifies).
  """

  rebac do
    verbs_from 2351
    relate "rfd-2397", :provides, "guest-ca-capabilities-repos"
    relate "rfd-2397", :provides, "zone-player-mode-elf"
  end
end
