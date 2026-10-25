-- DHBW-Übungsblätter (Formate dhbw-slides-typst und dhbw-slides-ipynb)
--
--   ::: {.loesung}                 Lösung, steht direkt unter der Aufgabe
--   ::: {.block .alert data-title="…"}   Block wie auf den Folien (nur PDF)
--   ## Aufgabe 1: Titel {punkte=6}  →  „Aufgabe 1 (6 Punkte): Titel“
--   [3]{.punkte}                    →  „(3 Punkte)“, z. B. am Ende einer Teilaufgabe
--
-- Klausur-Modus (nur PDF): ein Block  klausur:  im Dokumentkopf schaltet auf das
-- Layout der DHBW-Klausurvorlage um (Deckblatt, Kopfzeile „Seite x von y“,
-- Arial 12 pt, Teilaufgaben a), b), …). Die Gesamtpunktzahl auf dem Deckblatt
-- ist die Summe der punkte=-Angaben, falls klausur.punkte fehlt.
--
-- PDF: Die Lösungen stehen immer in der .typ-Datei, werden aber nur gezeigt,
-- wenn  loesung: true  gesetzt ist oder die .typ mit  --input loesung=true
-- kompiliert wird. Das Post-Render-Skript loesungen.lua erzeugt so aus einem
-- Rendern beide PDFs.
-- Notebook: Lösungszellen bekommen das Zellen-Tag "loesung"; loesungen.lua
-- schreibt daraus  …-loesung.ipynb  und entfernt sie aus dem Aufgaben-Notebook.

local loesung_meta = false
local klausur_modus = false

local function truthy(v)
  if v == nil then return false end
  if type(v) == "boolean" then return v end
  local s = pandoc.utils.stringify(v):lower()
  return s == "true" or s == "yes" or s == "1"
end

-- Pfad des Logos relativ zur Projektwurzel. Typst behandelt Pfade mit
-- führendem "/" relativ zu --root, und Quarto setzt --root auf das Projekt.
local function logo_path(datei)
  local abs = quarto.utils.resolve_path(datei or "logo.png")
  local root = (quarto.project and quarto.project.directory)
    or pandoc.path.directory(quarto.doc.input_file)
  local rel = pandoc.path.make_relative(abs, root)
  if rel:sub(1, 2) == ".." or pandoc.path.is_absolute(rel) then
    return nil                     -- Extension liegt außerhalb des Projekts
  end
  return "/" .. rel:gsub("\\", "/")
end

local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local function base64(data)
  return ((data:gsub(".", function(x)
    local r, b = "", x:byte()
    for i = 8, 1, -1 do r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and "1" or "0") end
    return r
  end) .. "0000"):gsub("%d%d%d?%d?%d?%d?", function(x)
    if #x < 6 then return "" end
    local c = 0
    for i = 1, 6 do c = c + (x:sub(i, i) == "1" and 2 ^ (6 - i) or 0) end
    return B64:sub(c + 1, c + 1)
  end) .. ({ "", "==", "=" })[#data % 3 + 1])
end

-- Notebook: Logo (als data:-URI, damit das Notebook allein verschickt werden
-- kann) rechts unter dem Titel, dazu Vorlesung und Autor
local nb_kopf = nil

local function inlines(v)
  return pandoc.utils.blocks_to_inlines({ pandoc.Plain(v) })
end

local function read_meta(meta)
  loesung_meta = truthy(meta.loesung)
  if quarto.doc.is_format("ipynb") then
    local img = nil
    local f = io.open(quarto.utils.resolve_path("logo.png"), "rb")
    if f then
      img = pandoc.RawInline("html", '<img src="data:image/png;base64,' .. base64(f:read("a"))
        .. '" alt="DHBW" height="56" align="right">')
      f:close()
    end
    local cfg = meta.dhbw or {}
    local teile = {}
    for _, v in ipairs({ cfg.vorlesung, cfg.author or meta.author }) do
      local s = v and pandoc.utils.stringify(v) or ""
      if s ~= "" then teile[#teile + 1] = s end
    end
    local zeile = pandoc.RawInline("html", '<span style="color:#58636C">'
      .. table.concat(teile, " · ") .. "</span>")

    if meta.title then
      -- Quarto setzt Titel und Untertitel selbst als erste Zelle: Logo und
      -- Zeile in den Untertitel hängen (die Titelzeile darf nicht umbrechen)
      local sub = pandoc.List({})
      if img then sub:insert(img) end
      if meta.subtitle then sub:extend(inlines(meta.subtitle)); sub:insert(pandoc.LineBreak()) end
      sub:insert(zeile)
      meta.subtitle = pandoc.MetaInlines(sub)
    else
      nb_kopf = pandoc.Plain(img and { img, zeile } or { zeile })
    end
  end
  if quarto.doc.is_format("typst") then
    local logo = logo_path()
    if logo then
      meta["dhbw-logo"] = pandoc.MetaInlines({ pandoc.RawInline("typst", logo) })
    end
    if meta.klausur ~= nil and meta.klausur ~= false then
      klausur_modus = true
      local kl = logo_path("logo-klausur.png")
      if kl then
        meta["dhbw-logo-klausur"] = pandoc.MetaInlines({ pandoc.RawInline("typst", kl) })
      end
    end
  end
  return meta
end

local function typst_wrap(open, content)
  local out = pandoc.List({ pandoc.RawBlock("typst", open) })
  out:extend(content)
  out:insert(pandoc.RawBlock("typst", "]"))
  return out
end

local function typst_string(s)
  return '"' .. s:gsub('\\', '\\\\'):gsub('"', '\\"') .. '"'
end

-- alle Zellen (Code-Zellen sind in Quarto Divs mit Klasse "cell") taggen
local function tag_cells(blocks)
  local out = pandoc.List()
  for _, b in ipairs(blocks) do
    if b.t == "Div" and b.classes:includes("cell") then
      local tags = b.attributes["tags"]
      b.attributes["tags"] = tags and (tags:gsub("%]$", ', "loesung"]')) or '["loesung"]'
      out:insert(b)
    else
      -- Markdown-Inhalt als eigene Zelle mit Tag
      out:insert(pandoc.Div({ b }, pandoc.Attr("", { "cell", "markdown" }, { tags = '["loesung"]' })))
    end
  end
  return out
end

-- Punkte: „1 Punkt“, sonst „n Punkte“ (Dezimalkomma bleibt, wie es dasteht)
local function punkte_text(n)
  return n .. (n == "1" and " Punkt" or " Punkte")
end

-- ## Aufgabe 1: Titel {punkte=6}  →  Aufgabe 1 (6 Punkte): Titel
local function punkte_header(el)
  local n = el.attributes["punkte"]
  if not n then return nil end
  el.attributes["punkte"] = nil
  local zusatz = pandoc.Str("(" .. punkte_text(n) .. ")")
  for i, x in ipairs(el.content) do
    if x.t == "Str" and x.text:sub(-1) == ":" then
      x.text = x.text:sub(1, -2)
      el.content:insert(i + 1, pandoc.Space())
      el.content:insert(i + 2, zusatz)
      el.content:insert(i + 3, pandoc.Str(":"))
      return el
    end
  end
  el.content:insert(pandoc.Space())
  el.content:insert(zusatz)
  return el
end

-- [3]{.punkte}  →  (3 Punkte)
local function punkte_span(el)
  if not el.classes:includes("punkte") then return nil end
  return pandoc.Str("(" .. punkte_text(pandoc.utils.stringify(el.content)) .. ")")
end

local function div(el)
  local c = el.classes

  if c:includes("loesung") then
    if quarto.doc.is_format("typst") then
      return typst_wrap(loesung_meta and "#dhbw-loesung(zeigen: true)[" or "#dhbw-loesung[",
                        el.content)
    elseif quarto.doc.is_format("ipynb") then
      local out = pandoc.List({
        pandoc.Div({ pandoc.Para({ pandoc.Strong({ pandoc.Str("Lösung") }) }) },
                   pandoc.Attr("", { "cell", "markdown" }, { tags = '["loesung"]' })),
      })
      out:extend(tag_cells(el.content))
      return out
    else
      return loesung_meta and el.content or {}
    end
  end

  if c:includes("block") and quarto.doc.is_format("typst") then
    local art = "normal"
    for _, a in ipairs({ "alert", "info", "example" }) do
      if c:includes(a) then art = a end
    end
    local titel = el.attributes["data-title"] or el.attributes["title"]
    local open = "#dhbw-block(art: \"" .. art .. "\""
      .. (titel and (", titel: " .. typst_string(titel)) or "") .. ")["
    return typst_wrap(open, el.content)
  end
end

-- PDF: Pandoc schreibt „…“ nach Typst als „…" – und Typst macht aus dem
-- geraden " ein neues öffnendes Zeichen, weil das „ davor kein Typst-Zitat ist
-- (Ergebnis „…„). Deshalb werden „ “ ” als Typst-Anführungszeichen " ausgegeben;
-- Typst setzt sie dann passend zur Sprache (de: „…“).
local QUOTES = { "\226\128\158", "\226\128\156", "\226\128\157" }   -- „ “ ”
local function anfuehrungszeichen(el)
  if not quarto.doc.is_format("typst") then return nil end
  local text = el.text
  local out, pos = pandoc.List(), 1
  while true do
    local naechste, laenge = nil, 0
    for _, q in ipairs(QUOTES) do
      local i = text:find(q, pos, true)
      if i and (not naechste or i < naechste) then naechste, laenge = i, #q end
    end
    if not naechste then break end
    if naechste > pos then out:insert(pandoc.Str(text:sub(pos, naechste - 1))) end
    out:insert(pandoc.RawInline("typst", '"'))
    pos = naechste + laenge
  end
  if #out == 0 then return nil end
  if pos <= #text then out:insert(pandoc.Str(text:sub(pos))) end
  return out
end

-- Notebook: Jupyter-Markdown kennt keine Buchstaben-Listen. Pandoc würde aus
-- a., b., c. ein 1., 2., 3. machen und den Start verlieren (eine Lösungsliste,
-- die mit b. beginnt, hieße dann 1.). Deshalb wird jeder Punkt ein Absatz mit
-- fettem Buchstaben davor; weitere Blöcke des Punkts (Tabellen, Code) folgen.
local function buchstaben_liste(el)
  if klausur_modus and quarto.doc.is_format("typst") then
    local stil = el.listAttributes.style
    if stil == "LowerAlpha" or stil == "UpperAlpha" then
      el.listAttributes.delimiter = "OneParen"
      return el
    end
    return nil
  end
  if not quarto.doc.is_format("ipynb") then return nil end
  local stil = el.listAttributes.style
  if stil ~= "LowerAlpha" and stil ~= "UpperAlpha" then return nil end
  local start = el.listAttributes.start or 1
  local zeichen = (el.listAttributes.delimiter == "OneParen"
    or el.listAttributes.delimiter == "TwoParens") and ")" or "."
  local out = pandoc.List()
  for i, punkt in ipairs(el.content) do
    local label = pandoc.Strong({ pandoc.Str(string.char(
      (stil == "UpperAlpha" and 64 or 96) + start + i - 1) .. zeichen) })
    local erster = punkt[1]
    if erster and (erster.t == "Plain" or erster.t == "Para") then
      local inhalt = pandoc.List({ label, pandoc.Space() })
      inhalt:extend(erster.content)
      out:insert(pandoc.Para(inhalt))
      for j = 2, #punkt do out:insert(punkt[j]) end
    else
      out:insert(pandoc.Para({ label }))
      out:extend(punkt)
    end
  end
  return out
end

local function kopf(doc)
  -- Gesamtpunktzahl für das Klausur-Deckblatt
  local summe, gefunden = 0, false
  doc:walk({ Header = function(h)
    local n = tonumber(((h.attributes["punkte"] or ""):gsub(",", ".")))
    if n then summe, gefunden = summe + n, true end
  end })
  if gefunden then
    local s = (summe == math.floor(summe)) and string.format("%d", summe)
      or tostring(summe):gsub("%.", ",")
    doc.meta["klausur-summe"] = pandoc.MetaString(s)
  end
  if nb_kopf then
    doc.blocks:insert(1, pandoc.Div({ nb_kopf }, pandoc.Attr("", { "cell", "markdown" })))
  end
  return doc
end

return {
  { Meta = read_meta },
  { Pandoc = kopf },                    -- Punkte zählen, solange punkte= noch dasteht
  { Header = punkte_header, Span = punkte_span },
  { Str = anfuehrungszeichen },
  { Div = div },
  { OrderedList = buchstaben_liste },   -- nach den Lösungs-Divs: eine Zelle bleibt eine Zelle
}
