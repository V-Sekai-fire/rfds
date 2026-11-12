# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT
# The prerequisite tree behind the beta freeze, RFD66606-2360: nodes, links, token spends, skipped-ahead links.
defmodule PagesTree do
  @goal 2360
  @org "weftspun"

  @features [
    %{
      name: "See each other",
      text:
        "Two people in the campus zone, one in the standalone Steam Frame and one on the " <>
          "desktop, each sees the other's avatar.",
      slices: [2436]
    }
  ]
  @advanced ~w(committed)
  @unsettled ~w(prediscussion ideation discussion)

  @tokens [
    {1, "Guest ELFs on the pinned double engine", "guest-elf-double"},
    {2, "SQLite on FoundationDB pages", "fdb-sqlite"},
    {6, "FEX", "fex"},
    {7, "Proton", "proton"}
  ]
  @boring [
    {"B1", "Elixir", "elixir"},
    {"B2", "pixi", "pixi"},
    {"B3", "prek", "prek"},
    {"B4", "cross-build image", "cross-build-image"},
    {"B5", "Bao", "bao"},
    {"B6", "Tailscale", "tailscale"},
    {"B7", "steamac", "steamac"},
    {"B8", "Fly", "fly"}
  ]
  defp acquired do
    case File.read(Path.join(__DIR__, "acquired.json")) do
      {:ok, text} -> JSON.decode!(text)
      {:error, _} -> %{}
    end
  end

  def build(docs, logs, repos, asof) do
    goal = @goal
    live = Enum.reject(docs, &(&1.state == "abandoned"))
    by = Map.new(live, &{&1.serial, &1})
    declared = declared()
    options = Map.new(live, &{&1.serial, options(&1.serial, declared, by)})

    links = Map.new(options, fn {n, opts} -> {n, providers(opts)} end)

    depth = depths(links, goal)

    nodes =
      for {serial, d} <- Enum.sort(depth) do
        doc = by[serial]
        spent = Map.get(declared.spends, serial, [])

        %{
          n: serial,
          t: String.replace(doc.label, ~r/^RFD66606-\d+: /, ""),
          s: doc.state,
          id: doc.id,
          d: d,
          u: doc.date,
          a: Map.get(acquired(), to_string(serial), ""),
          l: evidence(logs, serial),
          k: for({i, _, slug} <- @tokens, held?(slug, spent, declared), do: i),
          b: for({i, _, slug} <- @boring, held?(slug, spent, declared), do: i),
          c: options[serial] |> Enum.map(fn {_, [p | _]} -> p end) |> Enum.uniq(),
          q:
            for({t, ps} <- options[serial], uniq: true) do
              if match?([_], ps), do: "reach-rfd-#{hd(ps)}", else: "reach-cap-#{t}"
            end,
          p1: for({_, [p]} <- options[serial], do: p),
          alts: for({t, [_, _ | _] = ps} <- options[serial], do: %{token: t, providers: ps})
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
      caps: Map.new(for(n <- nodes, a <- n.alts, do: {a.token, a.providers})),
      tokens: tokens(declared, nodes),
      boring: boring(declared, nodes),
      repos: repos,
      features: @features,
      all: depth |> Map.keys() |> length()
    }
  end

  @context %{VSEKAI: "https://v-sekai.org/", domain: "VSEKAI:planning/domain/"}

  def domain(data) do
    open = Enum.reject(data.nodes, &(&1.s in @advanced))
    tokens = for t <- data.tokens ++ data.boring, do: to_string(t.i)

    ge = fn p ->
      %{eval: %{type: "math/ge", a: %{type: "pointer/get", pointer: p}, b: 1}}
    end

    set = fn p -> %{"pointer/set": p, value: 1} end

    held = fn p -> %{name: "held", check: [ge.(p)], subtasks: []} end

    settle =
      for n <- open, into: %{} do
        holds =
          Enum.map(n.p1, &ge.("/rfd/#{&1}")) ++ Enum.map(n.k ++ n.b, &ge.("/token/#{&1}"))

        {"settle-#{n.n}", %{params: [], body: holds ++ [set.("/rfd/#{n.n}")]}}
      end

    by_id = Map.new(data.tokens ++ data.boring, &{to_string(&1.i), &1})
    via = fn t -> Enum.map(by_id[t].via, &ge.("/token/#{&1}")) end

    check = fn t, rel ->
      %{eval: %{type: "rebac/check", subject: @org, rel: rel, object: by_id[t].slug}}
    end

    acquire =
      for t <- tokens,
          {suffix, rel} <- [{"owned", "owns"}, {"access", "has-capability"}],
          into: %{} do
        {"acquire-token-#{t}-#{suffix}",
         %{params: [], body: [check.(t, rel)] ++ via.(t) ++ [set.("/token/#{t}")]}}
      end

    rfd_methods =
      for n <- data.nodes, into: %{} do
        settle_alt =
          if n.s in @advanced do
            []
          else
            steps =
              Enum.map(n.q, &[&1]) ++
                Enum.map(n.k ++ n.b, &["reach-token-#{&1}"])

            [%{name: "settle", subtasks: steps ++ [["settle-#{n.n}"]]}]
          end

        {"reach-rfd-#{n.n}", %{params: [], alternatives: [held.("/rfd/#{n.n}") | settle_alt]}}
      end

    cap_methods =
      for {token, providers} <- data.caps, into: %{} do
        {"reach-cap-#{token}",
         %{
           params: [],
           alternatives:
             for(p <- providers, do: %{name: "via-rfd-#{p}", subtasks: [["reach-rfd-#{p}"]]})
         }}
      end

    token_methods =
      for t <- tokens, into: %{} do
        {"reach-token-#{t}",
         %{
           params: [],
           alternatives: [
             held.("/token/#{t}"),
             %{
               name: "acquire-owned",
               subtasks:
                 Enum.map(by_id[t].via, &["reach-token-#{&1}"]) ++ [["acquire-token-#{t}-owned"]]
             },
             %{
               name: "acquire-access",
               subtasks:
                 Enum.map(by_id[t].via, &["reach-token-#{&1}"]) ++ [["acquire-token-#{t}-access"]]
             }
           ]
         }}
      end

    %{
      "@context": @context,
      "@type": "domain:Definition",
      name: "campus_beta",
      source: "manuals-weftspun",
      version: "0.2.0",
      description:
        "Skills and tokens assembled into a goal: a skill is settled once the skills it needs " <>
          "are settled and the tokens it spends are acquired.",
      variables: [
        %{name: "rfd", type: "int", init: %{}},
        %{name: "token", type: "int", init: %{}}
      ],
      actions: Map.merge(settle, acquire),
      methods: rfd_methods |> Map.merge(token_methods) |> Map.merge(cap_methods)
    }
  end

  def problem(data) do
    tokens = for t <- data.tokens ++ data.boring, do: to_string(t.i)
    rfd = Map.new(data.nodes, &{to_string(&1.n), if(&1.s in @advanced, do: 1, else: 0)})

    %{
      "@context": @context,
      "@type": "domain:Problem",
      name: "campus_beta_rfd#{data.goal}",
      source: "manuals-weftspun",
      version: "0.2.0",
      description:
        "As of #{data.asof}: the RFDs that are committed are settled, no token is held, " <>
          "and the goal is RFD66606-#{data.goal}. The problem belongs to the domain " <>
          "campus_beta.",
      variables: [
        %{name: "rfd", type: "int", init: rfd},
        %{name: "token", type: "int", init: Map.new(tokens, &{&1, 0})}
      ],
      capabilities: %{entities: %{}, graph: %{edges: access_edges(data)}},
      todo_list: [["reach-rfd-#{data.goal}"]]
    }
  end

  defp access_edges(data) do
    for t <- data.tokens ++ data.boring, t.access do
      %{subject: @org, rel: if(t.own, do: "owns", else: "has-capability"), object: t.slug}
    end
  end

  def json(data) do
    data |> JSON.encode!() |> String.replace("</", "<\\/")
  end

  def markdown(data) do
    by = Map.new(data.nodes, &{&1.n, &1})
    link = fn n -> "[RFD66606-#{n}](##{by[n].id})" end

    [
      "### The path to the beta {#s1-1}\n\n" <> beta(data, by, link),
      "### Innovation tokens and boring technology {#s1-2}\n\n" <> ledger(data, link),
      "### Progress to the goal {#s1-3}\n\n" <> progress(data, by, link),
      "### Skipped ahead {#s1-4}\n\n" <> skipped(data, by, link),
      "### Technologies with no link {#s1-5}\n\n" <> unlinked(data, link),
      "### Repositories on the path {#s1-6}\n\n" <> repos(data, link)
    ]
    |> Enum.join("\n\n")
  end

  @gates [2436]

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
      "RFD66606-2436 passes with its control: #{Enum.join(gates, "; ")}.\n\n" <>
      "The feature stands on a shared foundation: #{open.(common)} open skills of " <>
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
      "goal's path are settled (committed), #{Map.get(stat, :ready, 0)} are " <>
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

  defp ledger(data, link) do
    rows =
      for t <- data.tokens ++ data.boring do
        kind =
          cond do
            t.own -> "ours"
            t.denied -> "abandoned"
            t.access -> "third party"
            true -> "no access"
          end
        owners = ([kind] ++ Enum.map(t.owners, &"RFD66606-#{&1}") ++ t.repos) |> cap()
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
      "| token | technology | RFDs whose title names it | settled | skills on the path |\n" <>
      "| --- | --- | --- | --- | --- |\n#{Enum.join(rows, "\n")}\n\n" <>
      "The path holds #{length(data.tokens)} innovation tokens and #{length(data.boring)} " <>
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

    "#{length(items)} skills on the path are settled while a skill they need is still open. " <>
      "Each is a technology switched on before its prerequisite.\n\n#{Enum.join(items, "\n")}"
  end

  defp unlinked(data, link) do
    open = Enum.filter(data.tokens ++ data.boring, &(&1.owners == [] and &1.repos == []))

    items =
      for t <- open do
        users =
          if t.users == [],
            do: "no skill on the path",
            else: Enum.map_join(t.users, ", ", &link.(&1))

        "- Token #{t.i}, #{t.name}, is spent by #{users}. No RFD title names it."
      end

    "A token the goal spends, with no RFD title naming it, is a technology skipped ahead " <>
      "without a link.\n\n#{Enum.join(items, "\n")}"
  end

  defp repos(data, link) do
    live = MapSet.new(data.nodes, & &1.n)

    rows =
      for r <- data.repos, MapSet.member?(live, r.n) do
        "- [#{r.repo}](https://github.com/#{r.repo}) holds the code of #{link.(r.n)}. " <> r.note
      end

    if rows == [],
      do: "No repository on the path to the beta yet.",
      else: Enum.join(rows, "\n")
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

  defp declared do
    tuples =
      for path <- RFD.Source.all(),
          doc = RFD.Source.load(path),
          doc.rebac != nil,
          t <- doc.rebac.tuples,
          not t.deny,
          do: {subject_of(t.subject), t.verb, t.object}

    base =
      %{
        provides:
          for(
            {s, :provides, o} <- tuples,
            reduce: %{},
            do: (acc -> Map.update(acc, o, [s], &[s | &1]))
          ),
        spends:
          for(
            {s, :spends, o} <- tuples,
            reduce: %{},
            do: (acc -> Map.update(acc, s, [o], &[o | &1]))
          ),
        denied:
          for(
            path <- RFD.Source.all(),
            doc = RFD.Source.load(path),
            doc.rebac != nil,
            t <- doc.rebac.tuples,
            t.deny,
            t.subject == @org,
            t.verb == :has_capability,
            do: t.object
          ),
        owned: for({"weftspun", :owns, o} <- tuples, do: o),
        access: for({"weftspun", :has_capability, o} <- tuples, do: o)
      }

    serials = for path <- RFD.Source.all(), doc = RFD.Source.load(path), do: doc.serial
    parts = for {s, :owns, "rfd-" <> _ = o} <- tuples, is_integer(s), do: {s, o}

    %{
      base
      | provides:
          Enum.reduce(serials, base.provides, fn s, acc ->
            Map.update(acc, "rfd-#{s}", [s], &[s | &1])
          end),
        spends:
          Enum.reduce(parts, base.spends, fn {s, o}, acc ->
            Map.update(acc, s, [o], &Enum.uniq([o | &1]))
          end)
    }
  end

  defp subject_of("rfd-" <> n), do: String.to_integer(n)
  defp subject_of(entity), do: entity

  defp options(serial, declared, by) do
    for token <- Map.get(declared.spends, serial, []),
        ps =
          for(
            p <- Map.get(declared.provides, token, []),
            is_integer(p),
            p != serial,
            Map.has_key?(by, p),
            do: p
          ),
        ps != [] do
      {token, ps |> Enum.uniq() |> Enum.sort_by(&{rank(by[&1].state), &1})}
    end
  end

  defp providers(opts), do: opts |> Enum.flat_map(&elem(&1, 1)) |> Enum.uniq()

  defp rank("committed"), do: 0
  defp rank("published"), do: 1
  defp rank(_), do: 2

  defp rfd_owners(declared, slug),
    do: for(p <- Map.get(declared.provides, slug, []), is_integer(p), do: p)

  defp held?(slug, spent, declared), do: slug in spent and rfd_owners(declared, slug) == []

  defp via(declared, slug) do
    for t <- Map.get(declared.spends, slug, []),
        {i, _, ^t} <- @tokens ++ @boring,
        do: i
  end

  defp token_fields(declared, slug) do
    if slug in declared.owned and slug in declared.denied,
      do: raise("a token #{@org} owns cannot be denied: #{slug}")

    %{
      slug: slug,
      owners: rfd_owners(declared, slug),
      repos: for(p <- Map.get(declared.provides, slug, []), is_binary(p), do: p),
      via: via(declared, slug),
      own: slug in declared.owned,
      denied: slug in declared.denied,
      access: (slug in declared.owned or slug in declared.access) and slug not in declared.denied
    }
  end

  defp depths(links, goal) do
    relax(%{goal => 0}, links)
  end

  defp relax(depth, links) do
    next =
      for {a, d} <- depth, p <- Map.get(links, a, []), reduce: depth do
        acc -> Map.update(acc, p, d + 1, &max(&1, d + 1))
      end

    if next == depth, do: depth, else: relax(next, links)
  end

  defp boring(declared, nodes) do
    for {i, name, slug} <- @boring do
      users = for n <- nodes, i in n.b, do: n.n
      Map.merge(%{i: i, name: name, users: users}, token_fields(declared, slug))
    end
  end

  defp tokens(declared, nodes) do
    for {i, name, slug} <- @tokens do
      users = for n <- nodes, i in n.k, do: n.n
      Map.merge(%{i: i, name: name, users: users}, token_fields(declared, slug))
    end
  end
end
