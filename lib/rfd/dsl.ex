# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT

defmodule RFD.DSL do
  @moduledoc """
  Author an RFD as Elixir. The block builds an `RFD.Doc`, validates it against
  RFD66606-1000 while the file compiles, and exposes it as `__rfd__/0`.

      use RFD.DSL

      rfd 2232, "RFD authoring as an Elixir DSL", :discussion do
        flight_level :l2
        feature "one source file per RFD, the README and DETAILS rendered from it"
        scope "the Mix project at the root, every rfd/NNNN-slug.exs"

        prose ~S\"\"\"
        :: decision
        ...
        :: intrigue
        ...
        \"\"\"

        references ["RFD 1000", "RFD 2177"]
        related "RFD 1000 (the shape), RFD 2177 (the register tag)."
        details "How the renderer is checked", \"\"\"
        ...
        \"\"\"
      end

  At the top of a file `rfd` defines the module `RFD2232` itself, and `prose` stands for
  the `decision` and `details` calls its `::` lines open. `drafted_by` defaults
  to `:ai`. The `defmodule RFD2232 do ... end` form with `state` inside the block still loads.

  Sections render in the order they are declared; the spine must still run
  Decision, References, Related. A file that breaks the shape does not
  compile; the error names the rule.
  """

  defmacro __using__(_opts) do
    quote do
      import RFD.DSL, only: [rfd: 3, rfd: 4]
    end
  end

  defmacro rfd(serial, title, do: block), do: rfd_body(serial, title, [], block, __CALLER__)

  # The compact form: `use RFD.DSL` at the top of the file, the state positional.
  defmacro rfd(serial, title, state, do: block),
    do: rfd_body(serial, title, [state: state], block, __CALLER__)

  defp rfd_body(serial, title, head, block, %{module: nil}) when is_integer(serial) do
    quote do
      defmodule unquote(:"Elixir.RFD#{serial}") do
        unquote(rfd_body(serial, title, head, block, :module))
      end
    end
  end

  defp rfd_body(serial, title, head, block, _caller) do
    quote do
      Module.register_attribute(__MODULE__, :rfd_fields, accumulate: true)
      Module.register_attribute(__MODULE__, :rfd_details, accumulate: true)
      Module.register_attribute(__MODULE__, :rfd_sections, accumulate: true)
      Module.register_attribute(__MODULE__, :rfd_order, accumulate: true)
      unquote(for {k, v} <- head, do: quote(do: @rfd_fields({unquote(k), unquote(v)})))
      import Kernel, except: [exit: 1]
      import RFD.DSL.Fields
      unquote(block)
      import RFD.DSL.Fields, only: []
      import Kernel

      @rfd_doc RFD.DSL.build(
                 unquote(serial),
                 unquote(title),
                 @rfd_fields,
                 @rfd_details,
                 @rfd_sections,
                 @rfd_order
               )
      def __rfd__, do: @rfd_doc
    end
  end

  @madr [
    context: "Context and problem statement",
    drivers: "Decision drivers",
    options: "Considered options",
    outcome: "Decision outcome",
    consequences: "Consequences",
    confirmation: "Confirmation",
    more_information: "More information"
  ]
  @madr_required [:context, :outcome]

  @doc "The MADR sections the `madr` block owns, keyword to canonical heading, in template order."
  def madr_sections, do: @madr

  @doc false
  def put_madr!(module, entries) do
    entries = Enum.reverse(entries)
    keys = Enum.map(entries, &elem(&1, 0))
    where = "madr in #{inspect(module)}"

    if entries == [], do: raise(ArgumentError, "#{where}: the block declares no section")

    dup = for {k, n} <- Enum.frequencies(keys), n > 1, do: k

    if dup != [],
      do: raise(ArgumentError, "#{where}: section given twice: #{inspect(dup)}")

    ranks = for k <- keys, do: Enum.find_index(Keyword.keys(@madr), &(&1 == k))

    if ranks != Enum.sort(ranks),
      do:
        raise(
          ArgumentError,
          "#{where}: sections run #{Enum.join(Keyword.keys(@madr), ", ")}; " <>
            "got #{Enum.join(keys, ", ")}"
        )

    for k <- @madr_required, k not in keys do
      raise ArgumentError, "#{where}: a MADR block states its #{k}"
    end

    for {k, body} <- entries do
      Module.put_attribute(
        module,
        :rfd_details,
        {Keyword.fetch!(@madr, k), madr_body!(where, k, body)}
      )
    end

    :ok
  end

  defp madr_body!(_where, _key, body) when is_binary(body), do: body

  defp madr_body!(where, :consequences, [{side, _} | _] = body) when side in [:good, :bad] do
    unless Keyword.keyword?(body) and Keyword.keys(body) -- [:good, :bad] == [],
      do: raise(ArgumentError, "#{where}: consequences takes good: and bad: only")

    for {side, items} <- body, item <- bullets!(where, :consequences, items) do
      "- #{side |> Atom.to_string() |> String.capitalize()}: #{item}"
    end
    |> Enum.join("\n")
  end

  defp madr_body!(where, key, body) when is_list(body) do
    Enum.map_join(bullets!(where, key, body), "\n", &("- " <> &1))
  end

  defp madr_body!(where, key, body) do
    raise ArgumentError,
          "#{where}: #{key} takes a string or a list of strings, got #{inspect(body)}"
  end

  defp bullets!(where, key, items) do
    unless is_list(items) and items != [] and Enum.all?(items, &is_binary/1),
      do: raise(ArgumentError, "#{where}: #{key} takes a non-empty list of strings")

    items
  end

  @doc false
  def put_rebac!(module, entries) do
    entries = Enum.reverse(entries)
    where = "rebac in #{inspect(module)}"

    if entries == [], do: raise(ArgumentError, "#{where}: the block declares nothing")

    rebac = %RFD.ReBAC{
      verbs: for({:verb, v} <- entries, do: v),
      tuples: for({:tuple, t} <- entries, do: t),
      capabilities: for({:capability, c} <- entries, do: c),
      verbs_from: for({:verbs_from, s} <- entries, do: s),
      renders_into: for({:renders_into, r} <- entries, do: r)
    }

    # A tuple's verb is checkable here only when this block owns the vocabulary;
    # `verbs_from` resolves across the corpus, in `mix rfd.rebac`.
    known = if rebac.verbs_from == [], do: MapSet.new(RFD.ReBAC.verb_names(rebac))

    case RFD.ReBAC.problems(rebac, known) do
      [] -> rebac
      ps -> raise ArgumentError, "#{where}:\n  " <> Enum.join(ps, "\n  ")
    end
  end

  @prose_one ~w(hook intrigue exit decision references related preamble details_preamble)a
  @prose_two ~w(details section)a

  @doc "The fields a `prose` block may open, without and with a heading."
  def prose_fields, do: {@prose_one, @prose_two}

  @doc false
  def split_prose!(text) do
    names = Map.new(@prose_one ++ @prose_two, &{Atom.to_string(&1), &1})

    text
    |> String.split("\n")
    |> Enum.drop(-1)
    |> Enum.reduce([], fn line, acc ->
      case {Regex.run(~r/^:: ([a-z_]+)(?: (.+))?$/, line), acc} do
        {[_ | [name | heading]], _} ->
          field = Map.get(names, name) || raise ArgumentError, "prose: no field #{inspect(name)}"

          if field in @prose_two != (heading != []),
            do:
              raise(
                ArgumentError,
                "prose: #{name} takes a heading only if it is #{inspect(@prose_two)}"
              )

          [{field, List.first(heading), []} | acc]

        {nil, [{f, h, lines} | rest]} ->
          [{f, h, [line | lines]} | rest]

        {nil, []} ->
          raise ArgumentError, "prose: the first line opens a field with `:: name`"
      end
    end)
    |> Enum.reverse()
    |> Enum.map(fn {f, h, lines} ->
      {f, h, lines |> Enum.reverse() |> Enum.map_join(&(&1 <> "\n"))}
    end)
  end

  @doc false
  def put_steps!(module, entries) do
    steps = Enum.reverse(entries)
    where = "steps in #{inspect(module)}"

    if steps == [], do: raise(ArgumentError, "#{where}: the block declares no step")

    case RFD.RECTGTN.problems(%{steps: steps}) do
      [] -> steps
      ps -> raise ArgumentError, "#{where}:\n  " <> Enum.join(ps, "\n  ")
    end
  end

  @doc false
  def build(serial, title, fields, details, sections \\ [], order \\ []) do
    fields =
      Enum.reverse(fields) ++ [sections: Enum.reverse(sections), order: Enum.reverse(order)]

    dup =
      fields
      |> Enum.map(&elem(&1, 0))
      |> Enum.frequencies()
      |> Enum.filter(fn {_, n} -> n > 1 end)

    if dup != [],
      do:
        raise(
          ArgumentError,
          "RFD #{serial}: field given twice: #{inspect(Enum.map(dup, &elem(&1, 0)))}"
        )

    fields = abandoned(serial, fields)

    struct!(RFD.Doc, [serial: serial, title: title, details: Enum.reverse(details)] ++ fields)
    |> expand()
    |> RFD.Doc.validate!()
  end

  defp abandoned(serial, fields) do
    case fields[:abandoned_at] do
      nil ->
        fields

      sha ->
        if fields[:state] != :abandoned,
          do: raise(ArgumentError, "RFD #{serial}: abandoned_at needs state :abandoned")

        if Keyword.has_key?(fields, :decision),
          do: raise(ArgumentError, "RFD #{serial}: an abandoned_at stub renders its own decision")

        fields ++ [decision: RFD.Ref.abandoned!(serial, sha)]
    end
  end

  defp expand(%RFD.Doc{} = d) do
    if Application.get_env(:rfd, :expand_refs, true), do: expand_refs(d), else: d
  end

  @doc "Run `fun` with `&{...}` references kept as written, for conversion and refs."
  def unexpanded(fun) do
    before = Application.get_env(:rfd, :expand_refs, true)
    Application.put_env(:rfd, :expand_refs, false)

    try do
      fun.()
    after
      Application.put_env(:rfd, :expand_refs, before)
    end
  end

  defp expand_refs(%RFD.Doc{} = d) do
    pair = fn {h, b} -> {RFD.Ref.expand!(h), RFD.Ref.expand!(b)} end

    d
    |> Map.from_struct()
    |> Map.new(fn
      {k, v} when k in [:details, :sections] -> {k, Enum.map(v, pair)}
      {k, v} when is_list(v) -> {k, Enum.map(v, &RFD.Ref.expand!/1)}
      {k, v} -> {k, RFD.Ref.expand!(v)}
    end)
    |> then(&struct!(RFD.Doc, &1))
  end

  defmodule Fields do
    @moduledoc false
    defmacro state(v), do: field(:state, v)
    defmacro feature(v), do: field(:feature, v)
    defmacro scope(v), do: field(:scope, v)
    defmacro flight_level(v), do: field(:flight_level, v)
    defmacro hook(v), do: field(:hook, v)
    defmacro intrigue(v), do: field(:intrigue, v)
    defmacro exit(v), do: field(:exit, v)
    defmacro decision(v), do: ordered(:decision, v)
    defmacro references(v), do: ordered(:references, v)
    defmacro related(v), do: ordered(:related, v)
    defmacro drafted_by(v), do: field(:drafted_by, v)
    defmacro attest_in(v), do: field(:attest_in, v)
    defmacro details_pointer(v), do: field(:details_pointer, v)
    defmacro details_title(v), do: field(:details_title, v)
    defmacro details_preamble(v), do: field(:details_preamble, v)
    defmacro preamble(v), do: field(:preamble, v)
    defmacro front_matter(v), do: field(:front_matter, v)
    defmacro compact_head(v), do: field(:compact_head, v)
    defmacro abandoned_at(sha), do: field(:abandoned_at, sha)

    # Consecutive heredoc fields as one `~S` heredoc, each opened by `:: field [heading]`.
    defmacro prose({:sigil_S, _, [{:<<>>, _, [text]}, []]}) do
      for {name, heading, body} <- RFD.DSL.split_prose!(text) do
        args = if heading, do: [heading, body], else: [body]
        quote do: RFD.DSL.Fields.unquote(name)(unquote_splicing(args))
      end
    end

    defmacro details(heading, body) do
      quote do
        @rfd_details {unquote(heading), unquote(body)}
      end
    end

    # The MADR template as sections the DSL names and orders, in place of seven `details` strings.
    defmacro madr(do: block) do
      quote do
        if Module.has_attribute?(__MODULE__, :rfd_madr),
          do:
            raise(ArgumentError, "madr in #{inspect(__MODULE__)}: one block carries the template")

        Module.register_attribute(__MODULE__, :rfd_madr, accumulate: true)
        import RFD.DSL.MADR
        unquote(block)
        import RFD.DSL.MADR, only: []
        RFD.DSL.put_madr!(__MODULE__, @rfd_madr)
      end
    end

    # Capability-ReBAC as declarations rather than a Markdown table a gate parses.
    defmacro rebac(do: block) do
      quote do
        if Module.has_attribute?(__MODULE__, :rfd_rebac),
          do: raise(ArgumentError, "rebac in #{inspect(__MODULE__)}: one block carries the model")

        Module.register_attribute(__MODULE__, :rfd_rebac, accumulate: true)
        import RFD.DSL.ReBAC
        unquote(block)
        import RFD.DSL.ReBAC, only: []
        @rfd_fields {:rebac, RFD.DSL.put_rebac!(__MODULE__, @rfd_rebac)}
      end
    end

    # A critical path as ordered declarations, which the RECTGTN problem plans over.
    defmacro steps(do: block) do
      quote do
        if Module.has_attribute?(__MODULE__, :rfd_steps),
          do: raise(ArgumentError, "steps in #{inspect(__MODULE__)}: one block carries the path")

        Module.register_attribute(__MODULE__, :rfd_steps, accumulate: true)
        import RFD.DSL.Steps
        unquote(block)
        import RFD.DSL.Steps, only: []
        @rfd_fields {:steps, RFD.DSL.put_steps!(__MODULE__, @rfd_steps)}
      end
    end

    # A README section outside the spine (RFD66606-1000 allows them), in declaration order.
    defmacro section(heading, body) do
      quote do
        @rfd_sections {unquote(heading), unquote(body)}
        @rfd_order {:section, unquote(heading)}
      end
    end

    defp ordered(name, v) do
      quote do
        @rfd_fields {unquote(name), unquote(v)}
        @rfd_order unquote(name)
      end
    end

    defp field(name, v) do
      quote do
        @rfd_fields {unquote(name), unquote(v)}
      end
    end
  end

  defmodule MADR do
    @moduledoc false
    defmacro context(body), do: entry(:context, body)
    defmacro drivers(body), do: entry(:drivers, body)
    defmacro options(body), do: entry(:options, body)
    defmacro outcome(body), do: entry(:outcome, body)
    defmacro consequences(body), do: entry(:consequences, body)
    defmacro confirmation(body), do: entry(:confirmation, body)
    defmacro more_information(body), do: entry(:more_information, body)

    defp entry(key, body) do
      quote do
        @rfd_madr {unquote(key), unquote(body)}
      end
    end
  end

  defmodule Steps do
    @moduledoc false
    defmacro step(name, opts) do
      quote do: @rfd_steps(RFD.DSL.Steps.step!(unquote(name), unquote(opts)))
    end

    @doc false
    def step!(name, opts) do
      unknown = Keyword.keys(opts) -- [:repos, :missing, :check, :control, :state]

      if unknown != [],
        do: raise(ArgumentError, "step #{inspect(name)}: unknown fields #{inspect(unknown)}")

      %RFD.Step{
        name: name,
        repos: opts |> Keyword.get(:repos, []) |> List.wrap(),
        missing: Keyword.get(opts, :missing),
        check: Keyword.get(opts, :check),
        control: Keyword.get(opts, :control),
        state: Keyword.get(opts, :state, :ready)
      }
    end
  end

  defmodule ReBAC do
    @moduledoc false
    defmacro verb(name, meaning) do
      entry(:verb, quote(do: %{name: unquote(name), meaning: unquote(meaning)}))
    end

    defmacro relate(subject, verb, object, note \\ nil) do
      entry(:tuple, row(subject, verb, object, false, note))
    end

    defmacro deny(subject, verb, object, reason) do
      entry(:tuple, row(subject, verb, object, true, reason))
    end

    defmacro capability(name, opts) do
      entry(:capability, quote(do: RFD.DSL.ReBAC.cap!(unquote(name), unquote(opts))))
    end

    defmacro verbs_from(serial), do: entry(:verbs_from, serial)

    defmacro renders_into(path, opts \\ []) do
      entry(:renders_into, quote(do: {unquote(path), Keyword.get(unquote(opts), :subject)}))
    end

    @doc false
    def cap!(name, opts) do
      unknown = Keyword.keys(opts) -- [:verb, :object, :caveats]

      if unknown != [],
        do:
          raise(ArgumentError, "capability #{inspect(name)}: unknown fields #{inspect(unknown)}")

      %{
        name: name,
        verb: Keyword.get(opts, :verb, name),
        object: Keyword.get(opts, :object),
        caveats: Keyword.get(opts, :caveats, [])
      }
    end

    defp row(subject, verb, object, deny, reason) do
      quote do
        %{
          subject: unquote(subject),
          verb: unquote(verb),
          object: unquote(object),
          deny: unquote(deny),
          reason: unquote(reason)
        }
      end
    end

    defp entry(tag, value) do
      quote do: @rfd_rebac({unquote(tag), unquote(value)})
    end
  end
end
