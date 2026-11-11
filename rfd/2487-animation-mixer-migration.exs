# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2487, "Walk mode's clips should rejoin the AnimationMixer ecosystem", :discussion do
  flight_level :l1
  feature "the motion-matching guest's pose database is built from a real AnimationLibrary, " <>
            "not from raw per-clip files copied into the pack by a build script."

  scope "the motion-matching guest's bake step, the walk mode viewer's clip loading, and the " <>
          "release pipeline steps that currently move clip files around."

  prose ~S"""
  :: hook
  Why does a clip the guest needs sometimes never reach the shipped package, with nothing
  catching it until a user opens the app?
  :: intrigue
  A release once shipped walk mode with its clip data missing. Two fixes were tried and
  withdrawn: a loader change and a pack allowlist change, each disproven by planting a real
  clip in a fresh export and watching it come through fine either way. The honest cause is
  narrower: the one script step that copies clip files into the project before packing wrote
  nothing, once, and nothing in the resource system noticed, because raw files carry no such
  check. The guest's own data loader already changed shape once for this port: a comment in
  the guest's pose code says clips arrive as flat transforms instead of animation tracks,
  changed only for the sandboxed port. Upstream's own baker reads a real AnimationLibrary
  directly, built from a mixer and a skeleton.
  :: exit
  Clip data for a shipped package is as safe as any other imported resource: if it is still
  missing, the package itself failed to build, not merely to work once launched.
  :: decision
  - Build one AnimationLibrary resource per clip set, keyed one track at a time, in place of
    the flat transform files and the clip list file.
  - Decide whether the guest bakes its own pose database from that library over the sandbox's
    existing calls into engine objects, or whether baking happens once on the engine side and
    only the finished flat arrays cross into the guest, as they do today.
  - Drop the three script steps whose only job is moving clip files between repositories and
    into the exported package once the library carries the same data as a tracked resource.
  :: related
  - RFD66606-2382, which names the datasource store these release steps also move data for.
  """

  details_title "Walk mode's clips should rejoin the AnimationMixer ecosystem"

  prose ~S"""
  :: details Current data flow
  Clip data is produced as a set of per-bone transform arrays, a clip list file, a skeleton
  description and a parent list, one set of files per clip. A release step copies these files
  from the source repository into the project, where an editor setting is relied on to carry
  them into the exported package as plain files. The guest reads its own copy of these files
  at run time and parses the transform layout itself to build its pose search structure.

  :: details Where the raw layout came from
  The guest is a port of an existing engine plugin whose pose database is built directly from
  an AnimationLibrary, over a real mixer and skeleton, using the engine's own animation
  tracks. The port's own comment records that clips were changed to arrive as flat transforms
  "instead of Godot Animation tracks", changed for the sandboxed port alone.

  :: details Target data flow
  A build step reads the same source transform arrays once and writes one AnimationLibrary
  resource, one Animation per clip, each built by adding a track and inserting a key at a
  time rather than copying bytes. That resource is tracked and imported like any other
  project asset, so the normal export path carries it with no special allowlist. The guest
  reads pose data through the sandbox's existing calls into engine objects rather than
  through a file.

  :: details Open question
  Two shapes remain undecided. In one, the guest keeps baking its own pose search structure,
  now reading the AnimationLibrary's tracks over the sandbox's calls into engine objects
  instead of a file, closest to the original plugin's design. In the other, baking moves to
  the engine side entirely, producing the same flat arrays the guest reads today, handed
  across once rather than read from a file. The guest's own search code stays as it is. The
  choice needs a measurement of how much the sandbox's call overhead costs when pulling every
  key of every clip once at bake time, not at the frame rate the search itself runs at.
  """
end
