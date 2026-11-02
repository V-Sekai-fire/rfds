# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT
# The prerequisite tree behind the beta freeze, RFD66606-2360: nodes, links, token spends, skipped-ahead links.
defmodule PagesTree do
  @goal 2360
  @max_depth 4

  @features [
    %{
      name: "See each other",
      text:
        "Two people in the campus zone, one in the Steam Frame on a PC VR stream and one on " <>
          "the desktop, each sees the other's avatar.",
      slices: [2436]
    },
    %{
      name: "Hear each other",
      text: "Voice between the two, played at the speaker's avatar.",
      slices: [2437]
    },
    %{
      name: "Draw and wear",
      text:
        "The pen's first rung, RFD66606-2287, in the campus zone. The other person sees the " <>
          "drawn outfit worn.",
      slices: [2438]
    },
    %{
      name: "An adventure party and a shopkeeper persona",
      text:
        "One player and the three seats, each filled by a friend or a persona, the takeover, " <>
          "the walk from the shop to a room and back, and the shopkeeper persona with its " <>
          "saved world.",
      slices: [2439, 2440]
    }
  ]
  @advanced ~w(committed)
  @unsettled ~w(prediscussion ideation discussion)

  @tokens [
    {1, "Guest ELFs on the pinned double engine", ~r/guest ELF|riscv64|libriscv|godot-sandbox/,
     ~r/guest|riscv/},
    {2, "SQLite on FoundationDB pages", ~r/FoundationDB|fdb-sqlite/, ~r/FoundationDB|fdb/},
    {3, "Bao", ~r/\bBao\b|OpenBao/, ~r/\bBao\b|OpenBao/},
    {4, "Fly", ~r/\bFly\b|Fly\.io/, ~r/\bFly\b/},
    {5, "Tailscale", ~r/Tailscale/, ~r/Tailscale/},
    {6, "FEX", ~r/\bFEX\b/, ~r/\bFEX\b/},
    {7, "Proton", ~r/\bProton\b/, ~r/\bProton\b/}
  ]

  @boring [
    {"B1", "Elixir", ~r/Elixir|BEAM/, ~r/Elixir|BEAM/},
    {"B2", "pixi", ~r/\bpixi\b/, ~r/\bpixi\b/},
    {"B3", "prek", ~r/\bprek\b/, ~r/\bprek\b/},
    {"B4", "cross-build image", ~r/llvm-mingw|osxcross/, ~r/cross-build|llvm-mingw|osxcross/}
  ]

  def build(docs, logs, repos, asof) do
    goal = @goal
    live = Enum.reject(docs, &(&1.state == "abandoned"))
    known = MapSet.new(live, & &1.serial)
    by = Map.new(live, &{&1.serial, &1})
    links = Map.new(live, &{&1.serial, cites(&1, known)})
    depth = depths(links, goal)

    nodes =
      for {serial, d} <- Enum.sort(depth), d <= @max_depth do
        doc = by[serial]

        %{
          n: serial,
          t: String.replace(doc.label, ~r/^RFD66606-\d+: /, ""),
          s: doc.state,
          id: doc.id,
          d: d,
          u: doc.date,
          l: evidence(logs, serial),
          k: for({i, _, re, _} <- @tokens, Regex.match?(re, doc.text), do: i),
          b: for({i, _, re, _} <- @boring, Regex.match?(re, doc.text), do: i),
          c: links[serial] |> Enum.filter(&Map.has_key?(depth, &1)) |> Enum.sort()
        }
      end

    shown = MapSet.new(nodes, & &1.n)

    skips =
      for n <- nodes,
          m <- n.c,
          n.s in @advanced,
          by[m].state in @unsettled,
          m in shown,
          depth[m] > n.d,
          do: [n.n, m]

    %{
      goal: goal,
      asof: asof,
      nodes: nodes,
      skips: skips,
      tokens: tokens(live, nodes),
      boring: boring(live, nodes),
      repos: repos,
      features: @features,
      all: depth |> Map.keys() |> length()
    }
  end

  @context %{VSEKAI: "https://v-sekai.org/", domain: "VSEKAI:planning/domain/"}

  def domain(data) do
    open = Enum.reject(data.nodes, &(&1.s in @advanced))
    tokens = for t <- data.tokens ++ data.boring, do: to_string(t.i)
    ids = MapSet.new(data.nodes, & &1.n)
    ge = fn p -> %{eval: %{type: "pointer/ge", pointer: p, value: 1}} end
    set = fn p -> %{"pointer/set": p, value: 1} end

    need = fn n ->
      for m <- n.c, m in ids, Enum.find(data.nodes, &(&1.n == m)).d > n.d, do: m
    end

    settle =
      for n <- open, into: %{} do
        holds =
          Enum.map(need.(n), &ge.("/rfd/#{&1}")) ++ Enum.map(n.k ++ n.b, &ge.("/token/#{&1}"))

        {"settle-#{n.n}", %{params: [], body: holds ++ [set.("/rfd/#{n.n}")]}}
      end

    acquire =
      for t <- tokens, into: %{} do
        {"acquire-token-#{t}", %{params: [], body: [set.("/token/#{t}")]}}
      end

    methods =
      for n <- open, into: %{} do
        steps =
          Enum.map(need.(n), &["goal", "/rfd/#{&1}"]) ++
            Enum.map(n.k ++ n.b, &["goal", "/token/#{&1}"])

        {"/rfd/#{n.n}",
         %{alternatives: [%{name: "settle", subtasks: steps ++ [["settle-#{n.n}"]]}]}}
      end

    tmethods =
      for t <- tokens, into: %{} do
        {"/token/#{t}", %{alternatives: [%{name: "acquire", subtasks: [["acquire-token-#{t}"]]}]}}
      end

    %{
      "@context": @context,
      "@type": "domain:Definition",
      name: "campus_beta",
      source: "manuals-weftspun",
      version: "0.1.0",
      description:
        "Skills and tokens assembled into a goal: a skill is settled once the skills it needs " <>
          "are settled and the tokens it spends are acquired.",
      variables: [
        %{name: "rfd", type: "int", init: %{}},
        %{name: "token", type: "int", init: %{}}
      ],
      actions: Map.merge(settle, acquire),
      methods: Map.merge(methods, tmethods)
    }
  end

  def problem(data) do
    tokens = for t <- data.tokens ++ data.boring, do: to_string(t.i)
    rfd = Map.new(data.nodes, &{to_string(&1.n), if(&1.s in @advanced, do: 1, else: 0)})

    %{
      "@context": @context,
      "@type": "domain:Problem",
      name: "campus_beta_rfd#{data.goal}",
      domain: "campus_beta",
      source: "manuals-weftspun",
      version: "0.1.0",
      description:
        "As of #{data.asof}: the RFDs that are committed or published are settled, no token " <>
          "is held, and the goal is RFD66606-#{data.goal}.",
      variables: [
        %{name: "rfd", type: "int", init: rfd},
        %{name: "token", type: "int", init: Map.new(tokens, &{&1, 0})}
      ],
      capabilities: %{entities: %{}, graph: %{edges: []}},
      todo_list: [%{goal: [%{pointer: "/rfd/#{data.goal}", eq: 1}]}]
    }
  end

  def json(data) do
    data |> JSON.encode!() |> String.replace("</", "<\\/")
  end

  def markdown(data) do
    by = Map.new(data.nodes, &{&1.n, &1})
    link = fn n -> "[RFD66606-#{n}](##{by[n].id})" end

    [
      "### 1.1. The path to the beta {#s1-1}\n\n" <> beta(data, by, link),
      "### 1.2. How to read the map {#s1-2}\n\n" <> reading(data),
      "### 1.3. Innovation tokens and boring technology {#s1-3}\n\n" <> ledger(data, link),
      "### 1.4. Progress to the goal {#s1-4}\n\n" <> progress(data, by, link),
      "### 1.5. Skipped ahead {#s1-5}\n\n" <> skipped(data, by, link),
      "### 1.6. Technologies with no link {#s1-6}\n\n" <> unlinked(data, link),
      "### 1.7. Repositories on the map {#s1-7}\n\n" <> repos(data, link)
    ]
    |> Enum.join("\n\n")
  end

  @gates [2436, 2437, 2438, 2439, 2440]

  defp slice_needs(by, n) do
    if n.n in @gates do
      for m <- n.c, by[m], m not in @gates, do: by[m]
    else
      needs(by, n)
    end
  end

  defp reach(by, goal, ids) do
    walk = fn walk, todo, seen ->
      case todo do
        [] ->
          seen

        [n | rest] ->
          fresh =
            for m <- slice_needs(by, by[n]), m.n != goal, not MapSet.member?(seen, m.n), do: m.n

          walk.(walk, rest ++ fresh, Enum.reduce(fresh, seen, &MapSet.put(&2, &1)))
      end
    end

    walk.(walk, ids, MapSet.new(ids))
  end

  defp beta(data, by, link) do
    gates = for n <- @gates, do: "#{link.(n)} (#{by[n].s})"
    sets = for f <- data.features, do: reach(by, data.goal, f.slices)
    common = sets |> Enum.reduce(&MapSet.intersection/2) |> MapSet.difference(MapSet.new(@gates))
    open = fn ids -> Enum.count(ids, &(not done?(by[&1]))) end

    rows =
      for {f, set} <- Enum.zip(data.features, sets) do
        own = set |> MapSet.difference(common) |> MapSet.difference(MapSet.new(@gates))
        slices = Enum.map_join(f.slices, ", ", &link.(&1))

        own_text =
          if MapSet.size(own) == 0,
            do: "none: no RFD names a prerequisite of its own",
            else: "#{open.(own)} open of #{MapSet.size(own)}"

        "| #{f.name} | #{slices} | #{own_text} |"
      end

    "A dependency is something that must be in place before a skill can be settled. " <>
      "A skill is " <>
      "an RFD, and it depends on the skills it cites and on the tokens its text names.\n\n" <>
      "RFD66606-#{data.goal} is the beta freeze. It is cut when every gate in " <>
      "RFD66606-2436 to " <>
      "RFD66606-2440 passes with its control: #{Enum.join(gates, "; ")}.\n\n" <>
      "All four features stand on a shared foundation: #{open.(common)} open skills of " <>
      "#{MapSet.size(common)}, reached through RFD66606-2374 and RFD66606-2390, which every " <>
      "slice cites. Past that foundation:\n\n" <>
      "| feature | slice RFDs | skills of its own |\n| --- | --- | --- |\n" <>
      "#{Enum.join(rows, "\n")}\n\n" <>
      "A feature with no skills of its own is a slice that cites nothing specific to itself, " <>
      "so it is skipped ahead without a link to the technology it needs."
  end

  defp needs(by, n), do: for(m <- n.c, by[m] && by[m].d > n.d, do: by[m])
  defp done?(n), do: n.s in @advanced

  def status(by, n) do
    cond do
      done?(n) -> :done
      Enum.all?(needs(by, n), &done?/1) -> :ready
      true -> :blocked
    end
  end

  defp progress(data, by, link) do
    goal = by[data.goal]
    path = path(by, data.goal)
    stat = Enum.frequencies(for n <- path, do: status(by, n))
    ready = for n <- path, status(by, n) == :ready, do: link.(n.n)

    "As of #{data.asof}, #{Map.get(stat, :done, 0)} of the #{length(path)} skills on the " <>
      "goal's path are settled (committed or published), #{Map.get(stat, :ready, 0)} are " <>
      "ready and #{Map.get(stat, :blocked, 0)} are blocked by a skill that is open. " <>
      "The goal, #{link.(goal.n)}, is #{goal.s}.\n\n" <>
      "A skill is ready when it is open and every skill it cites at a deeper ring is settled. " <>
      "Ready now: #{cap(ready, 12)}."
  end

  def path(by, goal) do
    walk = fn walk, todo, seen ->
      case todo do
        [] ->
          seen

        [n | rest] ->
          fresh = for m <- needs(by, by[n]), not MapSet.member?(seen, m.n), do: m.n
          walk.(walk, rest ++ fresh, Enum.reduce(fresh, seen, &MapSet.put(&2, &1)))
      end
    end

    for n <- MapSet.to_list(walk.(walk, [goal], MapSet.new([goal]))), do: by[n]
  end

  defp reading(data) do
    "The journey runs left to right. The first column holds the RFDs that are committed, " <>
      "which is the only state that counts as complete, whatever order they landed in. Each " <>
      "later column holds the open skills that need only the columns before it, and the last " <>
      "column is the goal with its slice gates. #{length(data.nodes)} of the #{data.all} " <>
      "skills reachable from the goal are on it, read as of #{data.asof}.\n\n" <>
      "- A committed RFD outlined in red dashes landed before an RFD it cites.\n" <>
      "- An orange outline is ready: open, with everything it depends on committed.\n" <>
      "- The stripe on a chip is the first token its text names.\n\n" <>
      "Without a script, the tables below carry the same facts."
  end

  defp ledger(data, link) do
    rows =
      for t <- data.tokens ++ data.boring do
        owners = t.owners |> Enum.map(&"RFD66606-#{&1}") |> cap()
        settled = Enum.count(data.nodes, &(&1.n in t.users and done?(&1)))

        "| #{t.i} | #{t.name} | #{owners} | #{settled} of #{length(t.users)} | " <>
          "#{cap(Enum.map(t.users, link), 6)} |"
      end

    "An innovation token is a substrate: delete it and the stack crashes (RFD66606-2351). " <>
      "A boring token is a technology that spends no innovation token: its failure stops a " <>
      "tool or a gate, and nothing ships into the app. Both kinds are counted. Each " <>
      "technology below is tagged from the RFD text, " <>
      "as RFD66606-2351 tagged repositories from their metadata, so a mention counts as a " <>
      "use.\n\n" <>
      "| token | technology | RFDs whose title names it | settled | skills on the map |\n" <>
      "| --- | --- | --- | --- | --- |\n#{Enum.join(rows, "\n")}\n\n" <>
      "The map holds #{length(data.tokens)} innovation tokens and #{length(data.boring)} " <>
      "boring tokens."
  end

  defp cap(items, max \\ 4)
  defp cap([], _max), do: "none"
  defp cap(items, max) when length(items) <= max, do: Enum.join(items, ", ")

  defp cap(items, max) do
    Enum.join(Enum.take(items, max), ", ") <> ", and #{length(items) - max} more"
  end

  defp skipped(data, by, link) do
    items =
      for [a, b] <- data.skips do
        "- #{link.(a)} is #{by[a].s} and cites #{link.(b)}, which is #{by[b].s}."
      end

    "#{length(items)} skills on the map are settled while a skill they need is still open. " <>
      "Each is a technology switched on before its prerequisite.\n\n#{Enum.join(items, "\n")}"
  end

  defp unlinked(data, link) do
    open = Enum.filter(data.tokens ++ data.boring, &(&1.owners == []))

    items =
      for t <- open do
        users =
          if t.users == [],
            do: "no node on the map",
            else: Enum.map_join(t.users, ", ", &link.(&1))

        "- Token #{t.i}, #{t.name}, is spent by #{users}. No RFD title names it."
      end

    "A token the goal spends, with no RFD title naming it, is a technology skipped ahead " <>
      "without a link.\n\n#{Enum.join(items, "\n")}"
  end

  defp repos(data, link) do
    rows =
      for r <- data.repos do
        "- [#{r.repo}](https://github.com/#{r.repo}) holds the code of #{link.(r.n)}. " <> r.note
      end

    Enum.join(rows, "\n")
  end

  defp evidence(logs, serial) do
    hits = for l <- logs, cited?(l.text, serial), do: [l.date, l.label, l.id]
    hits |> Enum.sort(:desc) |> then(&%{total: length(&1), latest: Enum.take(&1, 3)})
  end

  defp cited?(text, serial) do
    tag = "RFD66606-#{serial}"
    String.contains?(text, tag) or Enum.any?(ranges(text), &(serial in &1))
  end

  defp ranges(text) do
    for [_, a, b] <- Regex.scan(~r/RFD66606-(\d{4}) to RFD66606-(\d{4})/, text),
        do: String.to_integer(a)..String.to_integer(b)//1
  end

  defp cites(doc, known) do
    singles = for [_, n] <- Regex.scan(~r/RFD66606-(\d{4})/, doc.text), do: String.to_integer(n)

    ranges =
      for [_, a, b] <- Regex.scan(~r/RFD66606-(\d{4}) to RFD66606-(\d{4})/, doc.text),
          n <- String.to_integer(a)..String.to_integer(b)//1,
          do: n

    (singles ++ ranges) |> Enum.uniq() |> Enum.filter(&(&1 != doc.serial and &1 in known))
  end

  defp depths(links, goal), do: walk([goal], links, %{goal => 0})

  defp walk([], _links, seen), do: seen

  defp walk([n | queue], links, seen) do
    fresh = for m <- Map.get(links, n, []), not Map.has_key?(seen, m), do: m
    seen = Enum.reduce(fresh, seen, &Map.put(&2, &1, seen[n] + 1))
    walk(queue ++ fresh, links, seen)
  end

  defp boring(live, nodes) do
    for {i, name, _, title_re} <- @boring do
      owners = for d <- live, Regex.match?(title_re, d.label), do: d.serial
      users = for n <- nodes, i in n.b, do: n.n
      %{i: i, name: name, owners: owners, users: users}
    end
  end

  defp tokens(live, nodes) do
    for {i, name, _, title_re} <- @tokens do
      owners = for d <- live, Regex.match?(title_re, d.label), do: d.serial
      users = for n <- nodes, i in n.k, do: n.n
      %{i: i, name: name, owners: owners, users: users}
    end
  end
end
