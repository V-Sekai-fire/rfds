# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT

defmodule RegisterJournalTest do
  use ExUnit.Case, async: true

  alias RFD.Register.Journal

  @layer %{
    arc: "urn:oid:1.3.6.1.4.1.66606.1.9",
    site: 9,
    site_name: "test",
    category: 1,
    category_name: "documents",
    pen: "urn:oid:1.3.6.1.4.1.66606",
    rule: "rfd/9000-conventions/DETAILS.md",
    note:
      {:reactivated,
       "A note long enough that a wrapping journal would break it over more than one line."}
  }

  @model %{
    sites: [
      %{
        site: 9,
        name: "Test",
        day: "2026-08-25",
        layer: @layer,
        thesis: "Every serial this site has allocated.\nA second line.",
        sections: [
          {:allocated, nil, []},
          {:unused, "Never written.", [9004]},
          {:deleted, "A deleted serial keeps its row.", [9003, 9002]}
        ]
      }
    ],
    rows: %{
      9002 => %{
        serial: 9002,
        day: "2026-08-25",
        site: "Test",
        table: :retired,
        slug: nil,
        opts: [recorded_in: 9000]
      },
      9003 => %{
        serial: 9003,
        day: "2026-09-01",
        site: "Test",
        table: :deleted,
        slug: "gone",
        opts: [flight_level: :l1]
      },
      9004 => %{
        serial: 9004,
        day: "2026-08-25",
        site: "Test",
        table: :never_written,
        slug: nil,
        opts: []
      }
    }
  }

  defp rfd(serial, slug, site \\ "Test", tags \\ []) do
    code = "RFD66606-#{serial}"

    {"rfd/#{serial}-#{slug}.txn",
     "2026-08-25T00:00:00Z (#{code}) 'A title\n # uuid: #{RFD.Txn.v5("rfd", code)}\n" <>
       " # tags: #{Enum.join(["rfd:title" | tags], ", ")}\n RFD:Published  1 RFD\n" <>
       " Serials:#{site}\n"}
  end

  defp tree(journal, rfds) do
    root = Path.join(System.tmp_dir!(), "register-journal-#{System.unique_integer([:positive])}")
    File.mkdir_p!(Path.join(root, "journal"))
    File.mkdir_p!(Path.join(root, "rfd"))
    File.write!(Path.join(root, "journal/serials.txn"), journal)
    for {path, text} <- rfds, do: File.write!(Path.join(root, path), text)
    on_exit(fn -> File.rm_rf!(root) end)
    root
  end

  test "the journal round-trips, is tackler, and carries no comment" do
    text = Journal.write(@model)
    assert {:ok, txns} = RFD.Txn.Parser.parse(text)
    assert length(txns) > 10
    assert Journal.read!(text) == @model
    assert Journal.canonical(text) == text
    refute Enum.any?(String.split(text, "\n"), &String.starts_with?(String.trim_leading(&1), ";"))
    refute text =~ "site:wrap"

    assert text =~
             "'A note long enough that a wrapping journal would break it over more than one line.\n # tags: site:note:reactivated\n"
  end

  test "the registers are the RFD journals plus the serials journal" do
    root =
      tree(Journal.write(@model), [
        rfd(9000, "conventions"),
        rfd(9001, "a-slug", "Test", ["rfd:flight-level:l2"])
      ])

    assert [
             %RFD.Register{
               name: "Test",
               layer: @layer,
               sections: [{:allocated, nil}, {:unused, "Never written."}, {:deleted, _}],
               rows: [
                 {:allocated, 9000, "conventions", []},
                 {:allocated, 9001, "a-slug", [flight_level: :l2]},
                 {:never_written, 9004, nil, []},
                 {:deleted, 9003, "gone", [flight_level: :l1]},
                 {:retired, 9002, nil, [recorded_in: 9000]}
               ]
             }
           ] = RFD.Register.from_journals(root)
  end

  # Negative controls: each must be refused, or the journal certifies the defect.
  test "a row no section lists, a comment, and an RFD from an unknown site are refused" do
    unlisted =
      Regex.replace(
        ~r/[^\n]+'RFD66606-9003\n # tags: site:row\n Text:Site9  1 LINE\n Text:Written\n\n/,
        Journal.write(@model),
        ""
      )

    root = tree(unlisted, [rfd(9000, "conventions"), rfd(9001, "a-slug")])

    assert_raise ArgumentError, ~r/RFD66606-9003 belongs in Test's deleted section/, fn ->
      RFD.Register.from_journals(root)
    end

    commented =
      String.replace(Journal.write(@model), "site:category:1\n", "site:category:1\n ; why\n")

    assert_raise ArgumentError, ~r/a comment is not durable data/, fn ->
      Journal.read!(commented)
    end

    root = tree(Journal.write(@model), [rfd(9000, "conventions"), rfd(9001, "a-slug", "Other")])
    assert_raise ArgumentError, ~r/Serials:Other/, fn -> RFD.Register.from_journals(root) end
  end

  test "an allocated row's flight level comes from its RFD journal alone" do
    with_level =
      String.replace(
        Journal.write(@model),
        "'allocated\n # tags: site:section\n Text:Site9  1 LINE\n Text:Written\n",
        "'allocated\n # tags: site:section\n Text:Site9  1 LINE\n Text:Written\n\n" <>
          "2026-08-25T00:59:59Z (SITE66606-9) 'RFD66606-9001\n" <>
          " # tags: site:flight-level:l2\n Text:Site9  1 LINE\n Text:Written\n"
      )

    assert with_level != Journal.write(@model)
    assert_raise ArgumentError, ~r/site:flight-level:l2/, fn -> Journal.read!(with_level) end
  end

  test "a deleted serial with an RFD journal is a serial listed twice" do
    root =
      tree(Journal.write(@model), [
        rfd(9000, "conventions"),
        rfd(9001, "a-slug"),
        rfd(9003, "gone")
      ])

    assert_raise ArgumentError, ~r/serial listed twice: \[9003\]/, fn ->
      RFD.Register.from_journals(root)
    end
  end

  test "the repository's serials journal is tackler, comment-free and in its written form" do
    text = File.read!("journal/serials.txn")
    assert {:ok, [_ | _]} = RFD.Txn.Parser.parse(text)
    refute Enum.any?(String.split(text, "\n"), &String.starts_with?(String.trim_leading(&1), ";"))
    assert Journal.canonical(text) == text
    assert [%{name: "Weftspun"}, %{name: "VSekaiFabric"}] = RFD.Register.from_journals(".")
  end
end
