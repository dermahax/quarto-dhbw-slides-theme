-- DHBW-Übungsblätter (Formate dhbw-slides-typst und dhbw-slides-ipynb)
--
--   ::: {.loesung}                 Lösung, steht direkt unter der Aufgabe
--   ::: {.block .alert data-title="…"}   Block wie auf den Folien (nur PDF)
--
-- PDF: Die Lösungen stehen immer in der .typ-Datei, werden aber nur gezeigt,
-- wenn  loesung: true  gesetzt ist oder die .typ mit  --input loesung=true
-- kompiliert wird. Das Post-Render-Skript loesungen.lua erzeugt so aus einem
-- Rendern beide PDFs.
-- Notebook: Lösungszellen bekommen das Zellen-Tag "loesung"; loesungen.lua
-- schreibt daraus  …-loesung.ipynb  und entfernt sie aus dem Aufgaben-Notebook.

local loesung_meta = false

local function truthy(v)
  if v == nil then return false end
  if type(v) == "boolean" then return v end
  local s = pandoc.utils.stringify(v):lower()
  return s == "true" or s == "yes" or s == "1"
end

-- Pfad des Logos relativ zur Projektwurzel. Typst behandelt Pfade mit
-- führendem "/" relativ zu --root, und Quarto setzt --root auf das Projekt.
local function logo_path()
  local abs = quarto.utils.resolve_path("logo.png")
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

local function kopf(doc)
  if nb_kopf then
    doc.blocks:insert(1, pandoc.Div({ nb_kopf }, pandoc.Attr("", { "cell", "markdown" })))
  end
  return doc
end

return {
  { Meta = read_meta },
  { Div = div },
  { Pandoc = kopf },
}
