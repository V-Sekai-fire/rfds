# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT

defmodule CffXmpTest do
  use ExUnit.Case, async: true

  @full """
  cff-version: 1.2.0
  message: "Cite it as below."
  title: "A <title> & more"
  abstract: >-
    First line
    joined.

    Second paragraph.
  version: 2.1.0
  date-released: 2026-11-12
  doi: 10.5281/zenodo.1
  repository-code: "https://example.org/repo"
  commit: abc123
  license:
    - Apache-2.0
    - MIT
  keywords:
    - one
    - two
  authors:
    - family-names: Lee
      given-names: "K. S. Ernest (iFire)"
    - name: "The Team"
  """

  defp xmp(text, media \\ %{}), do: text |> Rfd.Cff.parse!() |> Rfd.CffXmp.derive(media)

  test "every field in the matrix produces its property" do
    x = xmp(@full)
    assert x =~ "<cff:schemaVersion>1.2.0</cff:schemaVersion>"
    assert x =~ ~s(<dc:title><rdf:Alt><rdf:li xml:lang="x-default">A &lt;title&gt; &amp; more)

    assert x =~
             "<dc:description><rdf:Alt><rdf:li xml:lang=\"x-default\">First line joined.\nSecond"

    assert x =~ "<prism:version>2.1.0</prism:version>"
    assert x =~ "<xmp:Identifier>2.1.0</xmp:Identifier>"
    assert x =~ "<xmp:CreateDate>2026-11-12</xmp:CreateDate>"
    assert x =~ "<dc:date><rdf:Seq><rdf:li>2026-11-12</rdf:li></rdf:Seq></dc:date>"

    assert x =~
             "<dc:creator><rdf:Seq><rdf:li>K. S. Ernest (iFire) Lee</rdf:li>" <>
               "<rdf:li>The Team</rdf:li></rdf:Seq>"

    assert x =~ ~s(<dc:rights><rdf:Alt><rdf:li xml:lang="x-default">Apache-2.0 OR MIT)
    assert x =~ "<xmpRights:Marked>True</xmpRights:Marked>"
    assert x =~ "<prism:doi>10.5281/zenodo.1</prism:doi>"
    assert x =~ "<dc:identifier>doi:10.5281/zenodo.1</dc:identifier>"
    assert x =~ "<prism:url>https://example.org/repo</prism:url>"
    assert x =~ "<dc:relation>https://example.org/repo</dc:relation>"
    assert x =~ "<dc:subject><rdf:Bag><rdf:li>one</rdf:li><rdf:li>two</rdf:li></rdf:Bag>"
    assert x =~ "<cff:commit>abc123</cff:commit>"
    assert x =~ ~s(<?xpacket begin=)
    assert x =~ ~s(<?xpacket end="r"?>)
  end

  test "a record without a field produces no empty element" do
    x = xmp("cff-version: 1.2.0\ntitle: Only a title\n")

    for p <- ~w(dc:description prism:version xmp:Identifier xmp:CreateDate dc:date dc:creator
               dc:rights xmpRights:Marked prism:doi dc:identifier prism:url dc:relation
               dc:subject cff:commit dc:format xmpDM:duration) do
      refute x =~ "<#{p}>", p
      refute x =~ "<#{p} ", p
    end
  end

  test "message stands in when there is no abstract, url when there is no repository-code" do
    x = xmp("title: T\nmessage: \"Cite me\"\nurl: https://u.example\n")
    assert x =~ ~s(<rdf:li xml:lang="x-default">Cite me</rdf:li>)
    assert x =~ "<prism:url>https://u.example</prism:url>"
  end

  test "a media sidecar states format, frame rate and duration" do
    x = xmp("title: T\n", %{format: "video/lottie+json", frame_rate: 30, frames: 60})
    assert x =~ "<dc:format>video/lottie+json</dc:format>"
    assert x =~ "<xmpDM:videoFrameRate>30</xmpDM:videoFrameRate>"
    assert x =~ "<xmpDM:value>60</xmpDM:value><xmpDM:scale>1/30</xmpDM:scale>"
  end

  test "a .cff that is not a mapping is refused by shape" do
    assert_raise ArgumentError, ~r/not a mapping/, fn -> Rfd.Cff.parse!("- a\n- b\n") end
    assert_raise ArgumentError, ~r/not a mapping/, fn -> Rfd.CffXmp.derive(["a"]) end
  end

  test "an author with neither name nor family-names is refused, named by position" do
    text = "title: T\nauthors:\n  - name: A\n  - given-names: Only\n"
    assert_raise ArgumentError, ~r/author 2/, fn -> xmp(text) end
  end

  test "YAML outside the subset is refused rather than misread" do
    assert_raise ArgumentError, ~r/subset/, fn -> Rfd.Cff.parse!("title: [a, b]\n") end
    assert_raise ArgumentError, ~r/duplicate/, fn -> Rfd.Cff.parse!("title: a\ntitle: b\n") end
  end

  test "the house records parse" do
    root = Path.expand("..", __DIR__)

    for f <-
          ["CITATION.cff", "assets/techtree.cff"] ++
            Path.wildcard(Path.join(root, "apparatus/*/references/*.cff")) do
      cff = Rfd.Cff.read!(Path.expand(f, root))
      assert is_binary(cff["title"]) and cff["title"] != "", f
      assert cff |> Rfd.CffXmp.derive() |> String.contains?("<dc:title>"), f
    end
  end

  test "a multi-line quoted scalar folds" do
    cff = Rfd.Cff.parse!("title: \"Internet X.509 and\n  CRL Profile\"\n")
    assert cff["title"] == "Internet X.509 and CRL Profile"
  end

  test "--check refuses a planted stale sidecar and passes a fresh one" do
    dir = Path.join(System.tmp_dir!(), "cffxmp-#{System.unique_integer([:positive])}")
    File.mkdir_p!(dir)
    cff = Path.join(dir, "a.cff")
    out = Path.join(dir, "a.xmp")
    File.write!(cff, "cff-version: 1.2.0\ntitle: Fresh\n")
    Mix.Tasks.Cff.Xmp.run([cff, out])
    Mix.Tasks.Cff.Xmp.run(["--check", cff, out])
    File.write!(cff, "cff-version: 1.2.0\ntitle: Changed\n")
    assert_raise Mix.Error, ~r/stale/, fn -> Mix.Tasks.Cff.Xmp.run(["--check", cff, out]) end
  end
end
