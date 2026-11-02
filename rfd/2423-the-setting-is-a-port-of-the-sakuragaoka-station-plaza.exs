# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2423, "the setting is a port of the Sakuragaoka station plaza", :discussion do
  flight_level :l1
  scope "the train-station plaza the two players stand in, and how its port is vendored."

  prose ~S"""
  :: hook
  The two players stand in a station plaza that is a port, vendored by one script.
  :: intrigue
  The source scene generates every texture in code and keeps no mesh on disk.
  :: exit
  Run `tools/vendor_station.sh <commit>` with a commit some remote branch contains.
  :: decision
  The two players stand in a train-station plaza, a port of the MIT-licensed procedural three.js
  scene `sakuragaoka-station`, placed at &{repo("sakuragaoka-station")}
  (&{pin("sakuragaoka-station")}). The port lives in
  &{repo("entities-sakuragaoka-station")}, and the pen vendors it with
  `tools/vendor_station.sh <commit>`, which takes only a commit some remote branch contains.
  :: related
  - RFD66606-2287, where this rule lived before the split.
  """

  details_title "the setting is a port of the Sakuragaoka station plaza"

  prose ~S"""
  :: details Why the port rebuilds the scene
  Its 43,727 lines of JavaScript under `src/` generate every texture in code and keep no mesh on
  disk, so the port rebuilds the scene in the engine with MToon materials rather than importing
  it.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2423", :provides, "sakuragaoka-plaza-setting"
  end
end
