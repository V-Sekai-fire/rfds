# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2497, "mixer clients live in repositories of their own", :discussion do
  feature "the relay stays small and each client, bridge and contract gets a repository."

  scope "the mixer relay repository and every client, bridge and contract around it."

  prose ~S"""
  :: hook
  Can the mixer relay take a web viewer, a modeller plugin, a native engine client, a
  path-tracer bridge and a CPU render without one repository becoming everyone's copy?
  :: intrigue
  The relay repository already carries a subtree of the zone relay, 145 files that nothing in
  its build reads. The work queued for it is larger: an Erlang modeller, a Rust engine, a
  renderer that builds from source and an OpenUSD stack. Taking each as a subtree would bury
  a wire contract of a few files under code that is not ours.
  :: exit
  Build the relay and run the Python client's tests from a manifest workspace, with the wire
  contract at a pinned ref and the zone relay subtree deleted. It passes when no result changes.
  :: decision
  - Big and third-party code is a sibling checkout placed by a manifest row. A subtree is only
    for small shared source that one repository's own CI must build alone (operator, 2026-11-17).
  - Client repositories are named transport-mixer-x, with x the client (operator, 2026-11-17).
  - The wire spec and its golden packets become the contract repository contract-mixer-wire.
    Each client's CI checks it out at a pinned ref, so there is one source and no copy.
  - The relay serves a viewer from a configured directory that the viewer's repository fills.
  - The cross-client interop suite is a CI job in the relay repository, which checks out the
    clients through the manifest (operator, 2026-11-17).
  :: related
  - RFD66606-2493, the zone relay that the relay repository vendors today.
  - RFD66606-2294, where the rules behind a placement live.
  """

  details_title "mixer clients live in repositories of their own"

  prose ~S"""
  :: details What is where today
  - The relay repository holds the Elixir relay, its tests, the wire spec, a three.js demo, the
    Python client with its Hypothesis tests, the Godot client and the zone relay subtree.
  - The enrollment guest and the SolidCraft guest are repositories already. The old GPL
    add-on repository is archived.
  :: details What gets its own repository
  - The Python client and the headless reference that renders through OpenUSD and Mitsuba 3.
  - The Godot client, which also hosts the SolidCraft guest.
  - The Babylon.js viewer, with WebXR.
  - The Wings3D plugin, which replaces the Blender add-on.
  - A native Rust engine client on Bevy. Fyrox is the alternative and is not planned.
  - The bridge that writes one glTF 2.1 file per zone for the vk_gltf_renderer path tracer.
  :: details Manifest rows
  - A new manifest repository holds the rows, one variant file per stack.
  - Third-party rows are Wings3D, vk_gltf_renderer with nvpro_core2, Mitsuba 3, hdmitsuba and
    the zone relay. The Python environment comes from pixi.
  - hdmitsuba needs the Mitsuba commit its CI validates and does not support the PyPI wheel.
    That pin gets a branch of our own at that commit, so the row still follows a branch.
  - hdmitsuba is tested on Linux and macOS only, so the render variant is limited to those.
  :: details Order of work
  - Finish the open Python client pull request first, because it is mid-flight on that code.
  - Confirm nothing reads the vendored zone relay, then replace it with a row.
  - Create the manifest repository and the contract repository.
  - Split the Python and Godot clients with their history, then start the new clients as
    repositories of their own and retarget their tracker issues.
  :: details Not checked
  - Whether the docs and scripts of the relay repository read the vendored zone relay.
  - Whether Mitsuba 3 carries submodules of its own.
  - Whether the Wings3D licence, listed as other on GitHub, is compatible with the licence gate.
  """
end
