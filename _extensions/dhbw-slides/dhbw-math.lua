-- DHBW-Slides: Formeln als rohes TeX in <span class="math inline|display">
-- ausgeben - genau das HTML, das Pandoc bei html-math-method: katex erzeugt.
--
-- Wozu: Enthaelt das Dokument kein Math-Element mehr, setzt Pandoc die
-- Template-Variable "math" nicht, und Quarto haengt keinen CDN-Loader an
-- (der wegen embed-resources sonst MathJax 2 von cdn.jsdelivr.net nachlaedt).
-- Gerendert wird allein mit dem lokalen KaTeX in dhbw-chrome.html; die
-- HTML-Datei braucht damit keinerlei Netz.
--
-- Laeuft nach Quartos eigenen Filtern (at: post-quarto in _extension.yml),
-- damit Gleichungsnummern aus {#eq-...} schon als \tag{...} im TeX stehen.

local function escape_html(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

function Math(el)
  if not quarto.doc.is_format("revealjs") then return nil end
  local kind = el.mathtype == "DisplayMath" and "display" or "inline"
  return pandoc.RawInline("html",
    '<span class="math ' .. kind .. '">' .. escape_html(el.text) .. "</span>")
end
