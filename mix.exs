# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT

defmodule RFD.MixProject do
  use Mix.Project

  def project do
    [
      app: :rfd,
      version: "0.2.0",
      elixir: "~> 1.20",
      deps: [{:mdex, "~> 0.14.6"}]
    ]
  end

  def application do
    [extra_applications: [:logger, :xmerl]]
  end
end
