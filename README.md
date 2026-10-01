# quarto-dhbw-slides-theme

Quarto-Format-Extension für reveal.js-Folien im DHBW-Look: Blöcke im
Beamer-Stil, Chevron-Kapitelleiste, Fußzeile, KaTeX offline – alles in einer
einzelnen, ohne Internet lauffähigen HTML-Datei. Dazu Übungsblätter im selben
Stil (PDF oder Notebook) und automatischer PDF-Export der Folien.

Die Extension liegt in `_extensions/dhbw-slides/` und wird von allen
Vorlesungsprojekten gemeinsam genutzt. **Änderungen immer hier machen** und in
die Projekte nachziehen – `quarto update` überschreibt die Projektkopie.

## Installieren und aktualisieren

Im Projektordner (dort, wo `_quarto.yml` liegt):

```
quarto add dermahax/quarto-dhbw-slides-theme       # einmalig
quarto update dermahax/quarto-dhbw-slides-theme    # nach jeder neuen Version
```

Die Extension landet in `_extensions/dermahax/dhbw-slides/` und wird mit ins
Projekt-Repo eingecheckt, damit jedes Projekt ohne Netz baubar bleibt.
Offline oder bei privatem Repo geht ein lokaler Klon als Quelle:
`quarto add ../quarto-dhbw-slides-theme`.

**Neue Version veröffentlichen:** `version` in `_extensions/dhbw-slides/_extension.yml`
anheben, Eintrag unter [Änderungen](#änderungen), committen, pushen.

## Projekt aufsetzen

`_quarto.yml`:

```yaml
project:
  title: "Name der Vorlesung"
  post-render:                                          # beide optional
    - _extensions/dermahax/dhbw-slides/loesungen.ts     # Lösungsfassungen der Übungsblätter
    - _extensions/dermahax/dhbw-slides/folien-pdf.ts    # Folien zusätzlich als PDF

lang: de

format:
  dhbw-slides-revealjs: default

dhbw:
  author: "M. Bergau"
  vorlesung: "Name der Vorlesung"           # Kopfzeile der Übungsblätter
  chapters: ["Mengen", "Relationen", "Abbildungen"]
```

Kapiteldateien heißen `01-mengen.qmd`, `02-relationen.qmd`, … und brauchen im
Kopf nur `title:`. Die führende Nummer markiert das aktive Chevron
(`dhbw.chapter` überschreibt sie, `00-…` lässt keins aktiv).

| Schlüssel        | Bedeutung                                                 |
|------------------|-----------------------------------------------------------|
| `dhbw.author`    | Name in der Fußzeile (Rückfall: `author`)                  |
| `dhbw.chapters`  | Beschriftungen der Chevrons, in Reihenfolge               |
| `dhbw.chapter`   | aktives Kapitel (1-basiert), optional                     |
| `dhbw.vorlesung` | Vorlesungsname in der Kopfzeile der Übungsblätter         |
| `dhbw.orga`      | Daten für die Organisatorisches-Folie (siehe unten)       |
| `subtitle`       | Untertitel auf der Titelfolie                             |

## Bauen

| Befehl                                          | Folien-HTML | Folien-PDF |
|-------------------------------------------------|-------------|------------|
| `quarto render`                                 | ✓           | ✓          |
| `quarto render 03-kapitel.qmd`                  | ✓           | –          |
| `quarto render 03-kapitel.qmd --profile pdf`    | ✓           | ✓          |
| `quarto preview …` / VS Code Strg+Umschalt+K    | ✓           | –          |

**Folien-PDF** (`folien-pdf.ts`): druckt jede `NN-kapitel.html` mit gleichnamiger
`.qmd` per Chrome oder Edge (headless) nach `NN-kapitel.pdf`, eine Seite pro
Fragment-Schritt (`pdf-separate-fragments`, abschaltbar im Format). Browser wird
automatisch gesucht, sonst Pfad in `DHBW_PDF_BROWSER`. Ein im Viewer geöffnetes
PDF wird mit Warnung übersprungen. Interaktive Inhalte (iframes, Widgets)
erscheinen im PDF nur im Anfangszustand.

## Organisatorisches-Folie

Der Shortcode `{{< orga >}}` baut aus `dhbw.orga` eine Steckbrief-Folie. Alle
Felder sind optional, Markdown ist erlaubt:

```yaml
dhbw:
  orga:
    inhalt: ["Mengen, Relationen, Abbildungen", "Aussagen- und Prädikatenlogik"]
    zeitraum: "01.10.2026 – 20.12.2026"
    pruefung: "**Klausur** (Modul T4INF1002, 5 ECTS)"
    links:
      - { text: "Moodle-Kurs", url: "https://moodle.…" }
    kontakt: "Vorname Name · vorname.name@dhbw-loerrach.de"
    extra:
      - { label: "Übungen", value: "freitags, 14:00 Uhr" }
```

In `00-orga.qmd` unter einer `##`-Folie einfach `{{< orga >}}` schreiben.

## Übungsblätter

Eine `.qmd` je Blatt im Vorlesungsprojekt (z. B. `Uebungen/`, kein eigenes
Unterprojekt), die Lösung direkt unter der Aufgabe:

```markdown
---
title: "Übungsblatt 1: Einführung"
format: dhbw-slides-typst          # PDF;  dhbw-slides-ipynb für ein Notebook
---

## Aufgabe 1

Beweisen Sie …

::: {.loesung}
**Induktionsanfang** …
:::
```

Mit `loesungen.ts` entstehen `ueb-01.pdf` und `ueb-01-loesung.pdf` (bzw.
`.ipynb`, Lösungszellen mit Tag `loesung`). Ohne Skript nur die Aufgaben;
`-M loesung:true` zeigt die Lösungen direkt. Folienblöcke funktionieren auch im
PDF; Bilder mit `../figures/…`. Notebooks werden nicht ausgeführt
(`jupyter: python3` in den Kopf). Braucht Quarto ≥ 1.5.

## Syntax-Spickzettel

```markdown
::: {.block .normal data-title="Definition"}     grauer Standardblock
::: {.block .example data-title="Beispiel"}      Beispielblock
::: {.block .alert data-title="Aufgabe"}         roter Block
::: {.block .info data-title="Hinweis"}          blauer Block

::: {.leitfrage data-title="Die Frage"}          Einstiegsfrage, groß, ohne Kasten
::: {.sec data-title="Heute"}                    Abschnitt mit roter Überschrift
::: {.merke data-title="Fazit"}                  Merksatz mit rotem Randstrich
::: {.cols .vs}                                  Spalten mit Trennlinie
Begriff                                          Definitionsliste = Steckbrief
: Erklärung

::: {.cols}  ::: {.col} … :::  ::: {.col} … :::  :::     zwei Spalten
::: {.col style="flex:60"}                                 ungleiche Breite
::: {.cols .unequal}                                       Blöcke nicht gleich hoch
::: {.popup} … :::                                         Overlay, erscheint und verschwindet
::: {.popup .static} … :::                                 Overlay, dauerhaft
::: {.notes} … :::                                         Sprechernotizen (Taste S)
::: {.incremental} - … :::                                 Liste Punkt für Punkt
[rot]{.hl}   [kleiner]{.small}                             Hervorhebung / Kleindruck
::: {.texfig} ![](figures/bild.svg){.fig width="400"} :::  zentrierte Abbildung
```

Faustregel: ein `.block` pro Folie ist die Regel, zwei die Ausnahme –
Leitfragen, Gegenüberstellungen und Merksätze kommen ohne Kasten aus. Die
kastenlosen Formen gibt es nur in den Folien. Ein Begriff „A)“ in einer
Definitionsliste braucht `A\)`.

`data-title` ist reiner Text. Für Formeln im Blocktitel den Block als HTML schreiben:
`<div class="block normal"><div class="bt">Titel mit \(\log_b a\)</div><div class="bb">` …
`</div></div>` (jeweils in ```` ```{=html} ````).

Alles zum Ausprobieren: `example.qmd` und `example-uebung.qmd` in diesem Repo.

## Aufbau

```
_extensions/dhbw-slides/
    _extension.yml      Formate (Folien, Typst, Notebook), Geometrie, Filter
    dhbw.scss           das komplette Theme
    dhbw.lua            schreibt window.DHBW, bindet KaTeX lokal ein
    dhbw-math.lua       Formeln als TeX-Spans (verhindert Quartos CDN-Loader)
    dhbw-chrome.html    Logo, Fußzeile, Kapitelleiste, KaTeX-Aufruf
    orga.lua            Shortcode {{< orga >}}
    uebung.lua, uebung/ Übungsblätter: .loesung, Blöcke, Logo, Typst-Vorlage
    loesungen.ts        Post-Render: Lösungsfassungen der Übungsblätter
    folien-pdf.ts       Post-Render: Foliensätze als PDF
    logo.png            Quelle des eingebetteten Logos
    katex/              KaTeX 0.16.11 inkl. Schriften
```

**Logo tauschen:** Es steckt als Data-URI in der ersten Zeile von
`dhbw-chrome.html`; neu erzeugen mit
`[Convert]::ToBase64String([IO.File]::ReadAllBytes("logo.png")) | Set-Clipboard`.

**Warum KaTeX von Hand?** Mit `embed-resources: true` würde Quarto einen
CDN-Loader einbauen, die Folien bräuchten dann Internet. `dhbw-math.lua`
schreibt deshalb jede Formel als rohes TeX in einen Span, `dhbw.lua` bindet
KaTeX aus dem Extension-Ordner ein, `dhbw-chrome.html` rendert. Zusätzlich
rendert `dhbw-chrome.html` neu, wenn reveal.js beim Verlassen der Scroll-Ansicht
die Folien austauscht (sonst stünde z. B. in Moodle-iframes rohes TeX da).

## Änderungen

- **1.7.0** – Post-Render-Skript `folien-pdf.ts`: `quarto render` erzeugt zu
  jedem Foliensatz ein PDF (Chrome/Edge headless), Vorschau und Einzelrender
  bleiben schnell. `pdf-separate-fragments: true` als Vorgabe.
- **1.6.1** – Keine graue Schrift mehr auf hellem Grund (`.src`, `figcaption`,
  Untertitel, `.example`-Titel, `.small` in `--ink`).
- **1.6.0** – Formen ohne Kasten: `.leitfrage`, `.sec`, `.merke`, `.cols .vs`,
  Definitionsliste als Steckbrief.
- **1.5.1** – Formeln bleiben nach der Scroll-Ansicht gerendert; kein CDN-Loader
  mehr (`dhbw-math.lua`).
- **1.5.0** – Übungsblätter: `dhbw-slides-typst`, `dhbw-slides-ipynb`,
  `.loesung`, `loesungen.ts`, `dhbw.vorlesung`.
- **1.4.0** – `.popup` (Overlay, automatisch als Fragment).
- **1.3.0** – Spaltenblöcke standardmäßig gleich hoch, `.cols .unequal`.
- **1.2.1** – Logo mit transparentem Hintergrund.
- **1.2.0** – `{{< orga >}}`, Bildraster `.cols.grid`, `.qed`.
