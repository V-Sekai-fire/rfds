# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT
defmodule Rfd.CffXmp do
  @moduledoc "Derives an XMP sidecar (ISO 16684-1, RDF/XML) from a CFF 1.2.0 record."

  @ns [
    dc: "http://purl.org/dc/elements/1.1/",
    xmp: "http://ns.adobe.com/xap/1.0/",
    xmpRights: "http://ns.adobe.com/xap/1.0/rights/",
    prism: "http://prismstandard.org/namespaces/basic/3.0/",
    xmpDM: "http://ns.adobe.com/xmp/1.0/DynamicMedia/",
    cff: "https://citation-file-format.github.io/1.2.0/schema.json#"
  ]

  def derive(cff, media \\ %{})

  def derive(cff, media) when is_map(cff) do
    props =
      plain(cff["cff-version"], "cff:schemaVersion") ++
        alt(cff["title"], "dc:title") ++
        alt(first(cff, ["abstract", "message"]), "dc:description") ++
        plain(cff["version"], "prism:version") ++
        plain(cff["version"], "xmp:Identifier") ++
        plain(cff["date-released"], "xmp:CreateDate") ++
        array(List.wrap(cff["date-released"]), "dc:date", "Seq") ++
        array(authors(cff["authors"]), "dc:creator", "Seq") ++
        rights(cff["license"]) ++
        plain(cff["doi"], "prism:doi") ++
        plain(cff["doi"] && "doi:" <> cff["doi"], "dc:identifier") ++
        plain(first(cff, ["repository-code", "url"]), "prism:url") ++
        plain(first(cff, ["repository-code", "url"]), "dc:relation") ++
        array(List.wrap(cff["keywords"]), "dc:subject", "Bag") ++
        plain(cff["commit"], "cff:commit") ++ media(media)

    xmlns = Enum.map_join(@ns, "\n", fn {p, uri} -> ~s(    xmlns:#{p}="#{uri}") end)

    """
    <?xpacket begin="\uFEFF" id="W5M0MpCehiHzreSzNTczkc9d"?>
    <x:xmpmeta xmlns:x="adobe:ns:meta/">
     <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
      <rdf:Description rdf:about=""
    #{xmlns}>
    #{Enum.map_join(props, "\n", &("   " <> &1))}
      </rdf:Description>
     </rdf:RDF>
    </x:xmpmeta>
    <?xpacket end="r"?>
    """
  end

  def derive(_, _), do: raise(ArgumentError, "a .cff that is not a mapping is refused")

  defp first(cff, keys), do: Enum.find_value(keys, &present(cff[&1]))

  defp present(v) when v in [nil, "", []], do: nil
  defp present(v), do: v

  defp authors(nil), do: []

  defp authors(list) when is_list(list) do
    list
    |> Enum.with_index(1)
    |> Enum.map(fn {a, i} ->
      cond do
        is_map(a) and present(a["name"]) -> a["name"]
        is_map(a) and present(a["family-names"]) -> given(a) <> a["family-names"]
        true -> raise ArgumentError, "author #{i} has neither name nor family-names"
      end
    end)
  end

  defp given(a), do: if(present(a["given-names"]), do: a["given-names"] <> " ", else: "")

  defp rights(nil), do: []
  defp rights([]), do: []

  defp rights(license) do
    alt(license |> List.wrap() |> Enum.join(" OR "), "dc:rights") ++
      plain("True", "xmpRights:Marked")
  end

  defp media(m) do
    plain(m[:format], "dc:format") ++
      plain(m[:frame_rate] && "#{m[:frame_rate]}", "xmpDM:videoFrameRate") ++
      duration(m[:frames], m[:frame_rate])
  end

  defp duration(nil, _), do: []
  defp duration(_, nil), do: []

  defp duration(frames, rate) do
    [
      ~s(<xmpDM:duration rdf:parseType="Resource">) <>
        "<xmpDM:value>#{frames}</xmpDM:value><xmpDM:scale>1/#{rate}</xmpDM:scale>" <>
        "</xmpDM:duration>"
    ]
  end

  defp plain(v, prop) do
    case present(v) do
      nil -> []
      v -> ["<#{prop}>#{esc(v)}</#{prop}>"]
    end
  end

  defp alt(v, prop) do
    case present(v) do
      nil ->
        []

      v ->
        [
          ~s(<#{prop}><rdf:Alt><rdf:li xml:lang="x-default">#{esc(v)}</rdf:li>) <>
            "</rdf:Alt></#{prop}>"
        ]
    end
  end

  defp array([], _prop, _kind), do: []

  defp array(items, prop, kind) do
    lis = Enum.map_join(items, "", &"<rdf:li>#{esc(&1)}</rdf:li>")
    ["<#{prop}><rdf:#{kind}>#{lis}</rdf:#{kind}></#{prop}>"]
  end

  defp esc(v) do
    v
    |> to_string()
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("\"", "&quot;")
  end
end
