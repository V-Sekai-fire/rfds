# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2363, "a person moves by world grab or by controllers", :discussion do
  flight_level :l2
  scope "how a person moves in the headset."

  prose ~S"""
  :: hook
  In the headset a person moves by world grab or by controllers, and both work.
  :: intrigue
  One grip moves nothing, and a character moved with a gamepad gets no hand-written controller.
  :: exit
  Check a new way of moving a character against the rule: it uses the motion guest in the
  details, and no hand-written character controller is added.
  :: decision
  - In the headset a person moves two ways, and both work.
  - One is xr-grid's world grab: both grips pinch the world, and moving, turning or spreading
    the hands carries, turns or scales it about the hands' midpoint
    (`addons/procedural_3d_grid/core/xr_pinch.gd` on a canvas beside the hands, as
    &{repo("transport-meshing-pen")} wires it). One grip moves nothing.
  - The other is the controllers: smooth stick movement, snap turning and teleport.
  :: related
  - RFD66606-2294, where this rule lived before the split.
  - RFD66606-2422, the first rung's interface, which moves a person by the world grab described
    here.
  """

  details_title "a person moves by world grab or by controllers"

  prose ~S"""
  :: details Moving a character with a gamepad
  A character moved with a gamepad uses &{repo("interactor-motion-guest")}: the motion models on
  ggml-rd with compute-rd in a godot-sandbox guest, retargeted onto the avatar,
  with the stick setting movement and facing. No hand-written character
  controller is added.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2363", :provides, "xr-world-grab-locomotion"
  end
end
