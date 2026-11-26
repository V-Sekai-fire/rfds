# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT

defmodule RfdNextTest do
  use ExUnit.Case, async: true
  alias Mix.Tasks.Rfd.Next

  defp reg(rows), do: %RFD.Register{name: "T", layer: %{site: 2}, rows: rows}

  @rows [{:allocated, 2001, "a", []}, {:allocated, 2005, "b", []}]

  test "the next serial is one past the highest allocated row, not the lowest gap" do
    assert Next.next(reg(@rows)) == 2006
  end

  test "a deleted serial is spent, so it is never handed out again" do
    assert Next.next(reg(@rows ++ [{:deleted, 2009, "gone", []}])) == 2010
  end

  test "a serial claimed by a pushed branch or a source on disk is skipped" do
    assert Next.next(reg(@rows), [2007]) == 2008
  end

  test "a claim from another site does not move this site's serial" do
    assert Next.next(reg(@rows), [3012]) == 2006
  end

  test "the register that allocates is the one site not decommissioned" do
    frozen = %RFD.Register{name: "F", layer: %{site: 1, note: {:decommissioned, "x"}}, rows: []}
    open = %RFD.Register{name: "T", layer: %{site: 2, note: {:reactivated, "y"}}, rows: @rows}
    assert Next.allocating([frozen, open]) == open
    assert_raise Mix.Error, fn -> Next.allocating([frozen]) end
  end

  test "a full site raises rather than spilling into the next site's digit" do
    assert_raise Mix.Error, fn -> Next.next(reg([{:allocated, 2999, "z", []}])) end
  end
end
