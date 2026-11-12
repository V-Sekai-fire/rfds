# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2256, "WebTransport inside a sandbox guest", :discussion do
  feature "A godot-sandbox guest carries bulk game traffic over QUIC,
HTTP/3 and WebTransport at binary-translated speed, and the first
channel it carries mints tokens from a key the host never sees"
  scope "a godot-sandbox guest ELF running the QUIC stack, the zone
server and clients that host it, and a token-minting channel;
`interactor-fabric-zone`'s ELFs (RFD66606-2287) are its first user"

  prose ~S"""
  :: hook
  A sandbox guest carries QUIC traffic and mints tokens from a key the host never sees.
  :: intrigue
  A key on the desk, or a helper that hands out a token, is open to every script there.
  :: exit
  The signer's app key stays in guest memory. Each token request is checked against a tuple.
  :: decision
  QUIC, HTTP/3 and WebTransport run inside a RISC-V guest ELF that
  libriscv binary-translates to near native speed: picoquic with
  h3zero, TLS 1.3 through picotls on mbedTLS. The first channel is a signer on a zone server whose
  app key lives only in guest memory. It checks a ReBAC tuple and
  returns a one-hour installation token, never the key.
  :: related
  - RFD66606-2255 (SSH tunnel to Bao), the path the signer peer's
    identity can use to reach Bao.
  - RFD66606-2060 (org-scoped app token), the token this mints.
  - RFD66606-2200 (ReBAC agent roles as tuples), the authorization.
  """

  details_title "a token-minting guest over WebTransport"

  prose ~S"""
  :: details The host's part
  The host relays UDP through `PacketPeerUDP` and ticks timers without seeing plaintext.
  :: details The exchange
  1. The signer guest starts, logs in to Bao with its own cert
     identity over mTLS terminated inside the guest, and reads the
     app key into guest memory.
  2. An agent's guest opens a WebTransport session to the zone
     server on UDP 7443 and sends a mint request naming itself.
  3. The signer checks `agent:<cn>#mint@app:<app>` in the
     relationship store and refuses without it.
  4. It signs a JWT, exchanges it for an installation token over
     TLS inside the guest, and returns the token and its expiry.
  :: details What is not settled
  - **Throughput.** Bulk game traffic needs the binary-translated
    guest to keep up with a native QUIC stack. Nothing is measured
    yet; the comparison is the same stack built native against the
    translated guest, same payload, same link.
  - **Per-call instruction budget.** Translation shortens a TLS 1.3
    handshake but does not remove the sandbox's per-call limit, so
    the budget for this guest is set from a measured handshake.
  - **Transport.** WebTransport is the proposal; ENet through the
    existing ENet sandbox is the fallback if the translated QUIC
    guest cannot carry the traffic.
  - **Licences.** picoquic, picotls and mbedTLS are MIT or
    Apache-2.0. libriscv and godot-sandbox are BSD-3-Clause, so
    an MIT-or-Apache-only rule needs an exception for the host.
  - **Which peer.** A zone server the operator runs, on owned
    hardware or the existing hosting; the choice decides who can
    read that peer's memory.
  :: details The problem
  Only a separate peer keeps it out of reach.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2256", :provides, "webtransport-guest-signer"
    relate "rfd-2256", :spends, "rebac-agent-role-tuples"
    relate "rfd-2256", :is_a, "guest-runtime"
  end
end
