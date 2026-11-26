# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2501, "binaries come from each repository's flake", :discussion do
  feature "a repository's binaries are built by the NixOS flake in that repository, and published
as ORAS folders for the client and as a container image for a server"
  scope "the binaries of the V-Sekai-fire repositories and the CI that publishes and fetches
them"

  prose ~S"""
  :: hook
  Each repository builds its own binaries in its own NixOS flake.
  :: intrigue
  A fresh checkout must load with no download from another repository's CI and no hand build.
  :: exit
  Run `nix build` in the repository that owns a binary, or `oras pull` it by digest in CI.
  :: decision
  - A repository's binaries are built by the `flake.nix` in that repository, never by another
    repository's CI or by hand. The targets are Windows x86_64 and Linux x86_64 and aarch64, at
    single and double precision where the Variant size matters.
  - Files, such as libraries, guest ELFs and addons, are pushed with ORAS as plain-file OCI
    artifacts to `ghcr.io/v-sekai-fire/<repository>`, tagged with the commit's Go
    pseudo-version (RFD66606-2312). CI pulls them by digest with `oras pull`.
  - The PC client ships as folders pushed with ORAS and pulled by digest (operator, 2026-11-26).
  - A server piece is a NixOS flake that builds an OCI image with `dockerTools.buildLayeredImage`
    from nixpkgs, holding only the service and its closure. Podman runs it under Eclipse Ankaios:
    each server is an Ankaios workload whose manifest pins the image by digest and names its ports
    and restart policy. CI extracts an image with skopeo and umoci, and Docker Engine is not used.
    No server piece ships as win64 or runs under NSSM (operator, 2026-11-26).
  - The build works offline: the lock file pins every input and no derivation fetches. CI is one
    job that restores the Nix store from a zstd-compressed cache, builds, and publishes on `main`.
  - Flakes compose. Each takes one `nixpkgs` input that a consumer can make `follows` its own,
    and exposes `packages` and `overlays.default`. Another offline flake takes it as an input.
  :: related
  - RFD66606-2312, release tags are Go pseudo-versions.
  - RFD66606-2391, the precisions the beta runs.
  """

  details_title "binaries come from each repository's flake"

  prose ~S"""
  :: details Where the tools come from
  ORAS pushes and pulls plain files as OCI artifacts: https://oras.land/docs/quickstart/
  Eclipse Ankaios runs and orchestrates the server workloads, with Podman as its runtime:
  https://github.com/eclipse-ankaios/ankaios
  """
end
