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
  local author = pandoc.utils.stringify(cfg.author or meta.author or "")
  local chapter = pandoc.utils.stringify(cfg.chapter or "")

  local parts = {}
  for _, c in ipairs(chapters) do parts[#parts + 1] = json_string(c) end

  local js = "<script>window.DHBW = {chapters: [" .. table.concat(parts, ", ")
    .. "], author: " .. json_string(author)
    .. (chapter ~= "" and (", chapter: " .. chapter) or "")
    .. "};</script>"
  quarto.doc.include_text("after-body", js)

  return meta
end
