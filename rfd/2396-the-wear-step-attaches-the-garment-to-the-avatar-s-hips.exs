# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2396, "the wear step attaches the garment to the avatar's hips", :discussion do
  flight_level :l1
  scope "the wear step: avatar glTF, humanoid TSV, hip attachment and its check."

  prose ~S"""
  :: hook
  The wear step pins the garment to the avatar's hips, so it follows the body when the hips move.
  :: intrigue
  A garment left under `Body` stays put when the hips move, and the displacement reads zero.
  :: exit
  Run the check in `tools/gate_xr_scripted.gd` after DONE: move the hips bone 0.100 m up and read
  the garment's box centre one frame later.
  :: decision
  - `xr/xr_world.gd` on `attach_ready` makes a `BoneAttachment3D` on the TSV's Hips joint and
    reparents `Body/Garment` under it with the global transform kept. A haptic pulse marks it.
  - Each avatar repository, in `chibifire-stages` itself, gets a commit with a glTF exported once
    by this Mac's Blender from `Mire.blend` and `Marocchino.fbx` and a `<name>.humanoid.tsv` of
    role to joint.
  :: related
  - RFD66606-2293, where this rule lived before the split.
  """

  details_title "the wear step attaches the garment to the avatar's hips"

  prose ~S"""
  :: details Avatar repositories
  Each avatar repository gets a glTF exported (Godot master imports glTF and FBX, not USD) and a
  `<name>.humanoid.tsv` of 53 roles in `SkeletonProfileHumanoid`'s vocabulary, derived from
  Marocchino's `.fbx.meta` and Mire's `.unitypackage`. The manifest gains a `chibifire-stages`
  remote and links each glTF into the pen's `avatars/`.

  :: details Loading and the mirror
  `util/avatar_load.gd` loads the glTF at runtime (`GLTFDocument.append_from_file`,
  `generate_scene`), returns the `Skeleton3D`, the rest-pose body surfaces, and a rig
  `{positions, bones, names}` that `util/skeleton15.gd`'s `adapt` already maps by alias (`Hips`,
  `Upper_leg_L`, `Lower_leg_L`, `Upper_arm_L`, `LeftHand` are in Marocchino's joint list).
  `stages/infer_stage.gd` takes `opts.avatar` and keeps FoxGirl as the fixture when it is empty.

  The mirror, `xr/mirror.gd`: a `SubViewport` camera on the mirror plane facing the person, shown
  on a 1 by 2 m quad 2 m away, a world-locked video mirror, which is what it is called.

  `tools/frame/push.sh` rsyncs the pen, the engine and the DLL to `~/rfd2287/`, because the
  headset sync was never recorded.

  :: details Check and control
  Check, in `tools/gate_xr_scripted.gd` after DONE: move the hips bone 0.100 m up and read the
  garment's box centre one frame later. Displacement 0.100 m within 0.002 m (a tenth of a metre,
  about a soda can and a half across. The tolerance about a credit card and a half). The waist
  loop's mean height within 0.15 m below and 0.05 m above the hips. `--png` and `still.sh` give
  the stills, one of them in the mirror. Control: `--control=no_attach` leaves the garment under
  `Body`, displacement zero, FAIL.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2396", :provides, "garment-follows-hips"
    relate "rfd-2396", :provides, "avatar-repo-humanoid-tsv"
  end
end
