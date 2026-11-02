# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2379, "desktop zips ship as release assets", :discussion do
  flight_level :l2
  scope "where the desktop zips ship, and what the page and the Space carry."

  prose ~S"""
  :: hook
  The desktop zips ship as release assets, so the Space stays under its limit.
  :: intrigue
  A Space holds at most 1 GB, and the upload of three zips of 69, 84 and 91 MB was refused
  at the limit. Every earlier upload of the zips still counted in its history.
  :: exit
  Upload the next zip as an asset of the guest's GitHub release, not to the Space, and let
  the game Space link to it.
  :: decision
  - The macOS, Windows and Linux zips are assets of a GitHub release of the guest's
    repository, tagged by RFD66606-2312, and the game Space links to them (operator,
    2026-10-17).
  - The Space keeps the web game and the page.
  - The upload script deletes any zip from the Space.
  :: related
  - RFD66606-2294, where this rule lived before the split.
  - RFD66606-2321, the autobattler game, which this release carries.
  - RFD66606-2312, which tags the release.
  """

  details_title "desktop zips ship as release assets"

  prose ~S"""
  :: details The Space limit
  The upload of three zips of 69, 84 and 91 MB was refused at the limit. The Space history
  was squashed to one commit to free it, and the upload script now deletes any zip from the
  Space.

  :: details The page and the preview
  The page shows the downloads on its first slide and the web game on its last slide, as a
  preview (operator, 2026-10-17). The preview starts its download only when that slide
  opens.

  :: details A change to the game script
  A change to the game script alone leaves the guest and every translation hash as they
  were, so only the `.pck` of each zip is replaced. Each new zip started translated and
  printed `RESULT PASS` on its own system on 2026-10-17. The web game's slowest frame in the
  first round read 139 to 145 ms before and after the change.
  :: details The problem
  A Space holds at most 1 GB, and every earlier upload of the zips still counted in its history.
  """

  rebac do
    verbs_from 2351
    relate "rfd-2379", :provides, "desktop-zips-release-assets"
    relate "rfd-2379", :is_a, "deployment"
  end
end
