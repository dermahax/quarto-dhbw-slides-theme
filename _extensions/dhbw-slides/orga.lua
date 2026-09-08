-- Shortcode {{< orga >}}: baut die Organisatorisches-Folie (Steckbrief) aus
-- dem YAML-Block  dhbw.orga  (siehe README). Fehlende Felder werden ausgelassen.
--
-- dhbw:
--   orga:
--     inhalt:   [ "…", "…" ]            Liste -> Aufzählung
--     zeitraum: "…"                      Text (Markdown erlaubt)
--     pruefung: "…"
--     links:    [ { text: "…", url: "…" }, "…" ]
--     kontakt:  "…"  oder Liste
--     extra:    [ { label: "Übungen", value: "…" } ]   weitere Zeilen, optional

local LABELS = {
  { key = "inhalt",   label = "Inhalt" },
  { key = "zeitraum", label = "Zeitraum" },
  { key = "pruefung", label = "Prüfung" },
  { key = "links",    label = "Links" },
  { key = "kontakt",  label = "Kontakt" },
}

local function is_list(v)
  return pandoc.utils.type(v) == "List"
end

local function inlines_html(v)
  -- MetaInlines / MetaString -> HTML (Markdown-Auszeichnung bleibt erhalten)
  local t = pandoc.utils.type(v)
  if t == "Inlines" then
    return pandoc.write(pandoc.Pandoc({ pandoc.Plain(v) }), "html")
  elseif t == "Blocks" then
    return pandoc.write(pandoc.Pandoc(v), "html")
  else
    return pandoc.utils.stringify(v)
  end
end

local function item_html(v)
  -- ein Listeneintrag: Text, oder {text, url} fuer einen Link
  if pandoc.utils.type(v) == "table" and v.url then
    local text = v.text and inlines_html(v.text) or pandoc.utils.stringify(v.url)
    return '<a href="' .. pandoc.utils.stringify(v.url) .. '">' .. text .. '</a>'
  end
  return inlines_html(v)
end

local function value_html(v)
  if is_list(v) then
    local n = #v
    -- Listen mit Links kompakt untereinander, sonst Aufzaehlung
    local all_links = n > 0
    for _, item in ipairs(v) do
      if not (pandoc.utils.type(item) == "table" and item.url) then all_links = false end
    end
    if all_links then
      local parts = {}
      for _, item in ipairs(v) do parts[#parts + 1] = item_html(item) end
      return table.concat(parts, "<br>")
    end
    local out = { "<ul>" }
    for _, item in ipairs(v) do out[#out + 1] = "<li>" .. item_html(item) .. "</li>" end
    out[#out + 1] = "</ul>"
    return table.concat(out)
  end
  return item_html(v)
end

local function row(label, value)
  return '<tr><th scope="row">' .. label .. "</th><td>" .. value_html(value) .. "</td></tr>"
end

return {
  ["orga"] = function(args, kwargs, meta)
    if not quarto.doc.is_format("revealjs") then return pandoc.Null() end
    local cfg = meta.dhbw and meta.dhbw.orga
    if not cfg then
      quarto.log.warning("{{< orga >}}: kein Block dhbw.orga in den Metadaten gefunden")
      return pandoc.Null()
    end
    local rows = {}
    for _, f in ipairs(LABELS) do
      if cfg[f.key] then rows[#rows + 1] = row(f.label, cfg[f.key]) end
    end
    if cfg.extra and is_list(cfg.extra) then
      for _, e in ipairs(cfg.extra) do
        if e.label and e.value then
          rows[#rows + 1] = row(inlines_html(e.label), e.value)
        end
      end
    end
    return pandoc.RawBlock("html", '<table class="orga">' .. table.concat(rows) .. "</table>")
  end,
}
