# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2424, "a free-space sketch is fitted to the avatar from keypoints", :discussion do
  flight_level :l1
  scope "how a sketch drawn in free space is placed on the avatar."

  prose ~S"""
  :: hook
  A sketch drawn in free space is placed on the avatar from keypoints and pushed out of the body.
  :: intrigue
  Can a whole dress session sit outside the body? On CASSIE's dress session, 0 of 12307 points
  end inside the body by winding number, and 4 junctions miss.
  :: exit
  Count the points that end inside the body by winding number, as on CASSIE's dress session where
  0 of 12307 do.
  :: decision
  - A sketch drawn in free space is placed on the avatar from anthropometric keypoints in
    `starforged-std-3001-appendix-e`: stature, crotch height as stature less sitting height, and
    hip breadth. Appendix E carries no waist height, so it comes from the ISO 7250 typical value.
  - Then each stroke, in drawing order, is pushed out of the body by `mujoco.elf`: rays against
    the mesh triangles, a point inside when its exit normal says so, and 4 mm of clearance, about
    five credit cards stacked.
  - A junction stays pinned to the earlier stroke's pushed position.
  :: related
  - RFD66606-2287, where this rule lived before the split.
  """

  details_title "a free-space sketch is fitted to the avatar from keypoints"

  prose ~S"""
  :: details Result and scope
  On CASSIE's dress session, 0 of 12307 points end inside the body by winding number, and 4
  junctions miss. This is placement. The drape stays on the next rung.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2424", :provides, "sketch-keypoint-body-fit"
    relate "rfd-2424", :is_a, "avatar-pipeline"
  end
end
