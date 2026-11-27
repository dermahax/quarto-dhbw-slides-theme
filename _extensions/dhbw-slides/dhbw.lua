-- DHBW-Slides: Kapitelleiste/Autor aus den YAML-Metadaten in die Seite geben
-- und KaTeX aus dem Extension-Ordner einbinden (statt vom CDN).

local FONTS = {
  "KaTeX_AMS-Regular", "KaTeX_Caligraphic-Bold", "KaTeX_Caligraphic-Regular",
  "KaTeX_Fraktur-Bold", "KaTeX_Fraktur-Regular", "KaTeX_Main-Bold",
  "KaTeX_Main-BoldItalic", "KaTeX_Main-Italic", "KaTeX_Main-Regular",
  "KaTeX_Math-BoldItalic", "KaTeX_Math-Italic", "KaTeX_SansSerif-Bold",
  "KaTeX_SansSerif-Italic", "KaTeX_SansSerif-Regular", "KaTeX_Script-Regular",
  "KaTeX_Size1-Regular", "KaTeX_Size2-Regular", "KaTeX_Size3-Regular",
  "KaTeX_Size4-Regular", "KaTeX_Typewriter-Regular",
}

local function json_string(s)
  return '"' .. s:gsub('\\', '\\\\'):gsub('"', '\\"') .. '"'
end

local function as_strings(v)
  local out = {}
  if v == nil then return out end
  -- Metadaten-Listen sind in Pandoc 3 eine pandoc.List; das Feld .t ist dort
  -- nil, deshalb ueber pandoc.utils.type pruefen.
  if pandoc.utils.type(v) == "List" then
    for _, item in ipairs(v) do
      local s = pandoc.utils.stringify(item)
      if s ~= "" then out[#out + 1] = s end
    end
  else
    local s = pandoc.utils.stringify(v)
    if s ~= "" then out[#out + 1] = s end
  end
  return out
end

function Meta(meta)
  if not quarto.doc.is_format("revealjs") then return meta end

  -- KaTeX lokal: Skripte, Stylesheet und die Schriften als Ressourcen
  local resources = {}
  for _, f in ipairs(FONTS) do
    resources[#resources + 1] = {
      name = "fonts/" .. f .. ".woff2",
      path = "katex/fonts/" .. f .. ".woff2",
    }
  end
  quarto.doc.add_html_dependency({
    name = "dhbw-katex",
    version = "0.16.0",
    scripts = { "katex/katex.min.js", "katex/auto-render.min.js" },
    stylesheets = { "katex/katex.min.css" },
    resources = resources,
  })

  -- Konfiguration aus dem YAML-Block  dhbw:  in die Seite schreiben
  local cfg = meta.dhbw or {}
  local chapters = as_strings(cfg.chapters)
  local author = pandoc.utils.stringify(cfg.author or meta.author or "Prof. Dr. M. Bergau")
  local chapter = pandoc.utils.stringify(cfg.chapter or "")
  -- Kapitelpfeile: nur mit dhbw.crumbs: true (Vorgabe: aus)
  local crumbs = cfg.crumbs
  if crumbs ~= nil and type(crumbs) ~= "boolean" then
    crumbs = pandoc.utils.stringify(crumbs) == "true"
  end

  local parts = {}
  for _, c in ipairs(chapters) do parts[#parts + 1] = json_string(c) end

  local js = "<script>window.DHBW = {chapters: [" .. table.concat(parts, ", ")
    .. "], author: " .. json_string(author)
    .. (chapter ~= "" and (", chapter: " .. chapter) or "")
    .. (crumbs ~= nil and (", crumbs: " .. tostring(crumbs)) or "")
    .. "};</script>"
  quarto.doc.include_text("after-body", js)

  return meta
end

-- .popup: ohne eigene Fragment-Angabe automatisch als Fragment, das erscheint
-- und beim nächsten Schritt wieder verschwindet. Steht schon .fragment dran
-- (z. B. .fragment .fade-in), bleibt die eigene Angabe; .static = immer sichtbar.
-- ::: {.incremental} um eine Tabelle: jede Zeile des Tabellenkörpers wird ein
-- Fragment, die Kopfzeile steht sofort da (Pandoc kennt .incremental nur für
-- Listen). Im PDF baut sich die Folie nur auf, also eine Seite (siehe 1.14.0).
local function zeilen_als_fragmente(el)
  local gefunden = false
  el = el:walk({
    Table = function(tbl)
      for _, body in ipairs(tbl.bodies) do
        for _, row in ipairs(body.body) do
          if not row.attr.classes:includes("fragment") then
            row.attr.classes:insert("fragment")
          end
        end
      end
      gefunden = true
      return tbl
    end
  })
  return el, gefunden
end

function Div(el)
  if not quarto.doc.is_format("revealjs") then return nil end
  local c = el.classes
  if c:includes("incremental") then
    local neu, gefunden = zeilen_als_fragmente(el)
    if gefunden then return neu end
    return nil
  end
  if not c:includes("popup") or c:includes("static") or c:includes("fragment") then
    return nil
  end
  c:insert("fragment")
  c:insert("fade-in-then-out")
  return el
end

-- Inhalt vertikal mittig: Eine Folie ohne Fragmente bekommt die Klasse
-- .dhbw-mitte, ihr Inhalt unter dem Frametitel wird in ein Div .dhbw-inhalt
-- gepackt, das dhbw.scss in der freien Höhe zentriert. Folien mit Fragmenten
-- bleiben oben bündig (sonst springt der Inhalt beim Aufdecken), ebenso
-- Folien mit einem Bild direkt auf der Folie (Quartos Auto-Stretch braucht es
-- dort als direktes Kind) und Folien mit .oben, .vollbild oder .center.
-- Ist der Inhalt höher als der freie Platz, sieht die Folie aus wie vorher.
local AUSNAHMEN = { "oben", "vollbild", "center", "r-fit-text", "pdf-eine-seite" }
local FRAGMENT_KLASSEN = { "fragment", "incremental", "r-stretch" }

local function hat_klasse(classes, liste)
  for _, k in ipairs(liste) do
    if classes:includes(k) then return true end
  end
  return false
end

local function ist_pause(b)
  -- ". . ." in einer eigenen Zeile = Pause in reveal.js
  return b.t == "Para" and pandoc.utils.stringify(b):gsub("%s", "") == "..."
end

local function ist_bild(b)
  if b.t == "Figure" then return true end
  if (b.t == "Para" or b.t == "Plain") and #b.content == 1 and b.content[1].t == "Image" then
    return true
  end
  return false
end

local function hat_fragmente(blocks, listen_inkrementell)
  local gefunden = false
  local function pruefe_attr(el)
    if el.attr and hat_klasse(el.attr.classes, FRAGMENT_KLASSEN) then gefunden = true end
    if el.attr and el.attr.classes:includes("popup") and not el.attr.classes:includes("static") then
      gefunden = true
    end
  end
  for _, b in ipairs(blocks) do
    if ist_pause(b) then gefunden = true end
  end
  pandoc.Div(blocks):walk({
    Div = pruefe_attr, Span = pruefe_attr, Image = pruefe_attr,
    CodeBlock = pruefe_attr, Table = function(t) pruefe_attr(t) end,
    Header = pruefe_attr,
    RawBlock = function(r) if r.text:find("fragment") then gefunden = true end end,
    RawInline = function(r) if r.text:find("fragment") then gefunden = true end end,
    BulletList = function() if listen_inkrementell then gefunden = true end end,
    OrderedList = function() if listen_inkrementell then gefunden = true end end,
  })
  return gefunden
end

local function ist_notes(b)
  return b.t == "Div" and b.classes:includes("notes")
end

function Pandoc(doc)
  if not quarto.doc.is_format("revealjs") then return nil end
  local listen_inkrementell = doc.meta.incremental == true
    or pandoc.utils.stringify(doc.meta.incremental or "") == "true"
  local raus = pandoc.Blocks({})
  local i, n = 1, #doc.blocks
  while i <= n do
    local b = doc.blocks[i]
    raus:insert(b)
    i = i + 1
    if b.t == "Header" and b.level == 2 then
      local inhalt, notes = pandoc.Blocks({}), pandoc.Blocks({})
      while i <= n do
        local c = doc.blocks[i]
        if (c.t == "Header" and c.level <= 2) or c.t == "HorizontalRule" then break end
        if ist_notes(c) then notes:insert(c) else inhalt:insert(c) end
        i = i + 1
      end
      local bild = false
      for _, c in ipairs(inhalt) do if ist_bild(c) then bild = true end end
      if #inhalt > 0 and not bild
        and not hat_klasse(b.classes, AUSNAHMEN)
        and not hat_fragmente(inhalt, listen_inkrementell) then
        b.classes:insert("dhbw-mitte")
        raus:insert(pandoc.Div(inhalt, pandoc.Attr("", { "dhbw-inhalt" })))
      else
        raus:extend(inhalt)
      end
      raus:extend(notes)
    end
  end
  doc.blocks = raus
  return doc
end
