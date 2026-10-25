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

## Klausuren

Ein Block `klausur:` im Kopf eines `dhbw-slides-typst`-Dokuments schaltet auf
das Layout der DHBW-Klausurvorlage (Studienzentrum IT-Management/Informatik)
um: Kopfzeile mit Logo und „Seite x von y“, Deckblatt mit Lehrveranstaltung,
Kurs, Datum, Dozent/in, Matrikel-Nummer, Hilfsmitteln, Dauer, Punktzahl und den
Standardhinweisen, danach die Aufgaben in Arial 12 pt mit Teilaufgaben a), b), …

```markdown
---
title: "Klausur"                     # oder "Probeklausur"; gesperrt gesetzt
format: dhbw-slides-typst
klausur:
  lehrveranstaltung: "Einführung in die Informationstechnik"  # Rückfall: dhbw.vorlesung
  kurs: "WWI25A"
  datum: "15.12.2026"                # Rückfall: date
  dozent: "M. Bergau"                # Rückfall: dhbw.author
  dauer: "60 Minuten"
  hilfsmittel: "keine"               # Vorgabe: keine
  # punkte: 50                       # sonst Summe der punkte=-Angaben
---

## Aufgabe 1: Zahlensysteme {punkte=6}

a. Wandeln Sie $1101_2$ in das Dezimalsystem um. [2]{.punkte}
b. … [4]{.punkte}

::: {.loesung}
…
:::
```

`{punkte=6}` an der Überschrift ergibt „Aufgabe 1 (6 Punkte): Zahlensysteme“,
`[2]{.punkte}` ergibt „(2 Punkte)“ (beides funktioniert auch auf Übungsblättern).
Leere Felder (`kurs: ""`) bleiben auf dem Deckblatt zum Ausfüllen frei. Die
Lösungsfassung (`loesungen.ts`) trägt unter dem Titel „Musterlösung“; die
Seitenzahl im ersten Hinweis zählt automatisch mit. Beispiel:
`example-klausur.qmd`.

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
    uebung.lua, uebung/ Übungsblätter und Klausuren: .loesung, Blöcke, Punkte,
                        Logo, Typst-Vorlage (dhbw-uebung, Klausur-Modus)
    loesungen.ts        Post-Render: Lösungsfassungen der Übungsblätter
    folien-pdf.ts       Post-Render: Foliensätze als PDF
    logo.png            Quelle des eingebetteten Logos
    logo-klausur.png    Logo mit Schriftzug für die Kopfzeile der Klausuren
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

- **1.8.6** – Klausur-Modus für PDFs (`dhbw-slides-typst`): Ein Block
  `klausur:` im Dokumentkopf setzt das Dokument im Layout der DHBW-Klausurvorlage
  (Deckblatt, Kopfzeile mit Logo und „Seite x von y“, Arial 12 pt, Teilaufgaben
  a), b), …), siehe [Klausuren](#klausuren). Neu für Klausuren und Übungsblätter:
  Punkte mit `{punkte=6}` an der Aufgabenüberschrift und `[2]{.punkte}` im
  Text; die Gesamtpunktzahl auf dem Deckblatt wird daraus summiert.
- **1.8.4** – Tabellen in Sprechernotizen sind in der Speaker-Ansicht (Taste S)
  übersichtlich: Zellabstand, Linien, fette hinterlegte Kopfzeile, abwechselnd
  getönte Zeilen. Vorher klebten die Spalten aneinander, weil das Speaker-Fenster
  das Theme-CSS nicht hat; jede Notiz mit Tabelle trägt ihr Tabellen-CSS jetzt
  selbst mit. Ausrichtung aus dem Markdown (`|--:|`) bleibt erhalten.
- **1.8.3** – Formeln in Sprechernotizen (`::: {.notes}`) erscheinen in der
  Speaker-Ansicht (Taste S) nur noch einmal. Vorher stand jede Formel doppelt da
  (gerendert und als flacher Text), weil das Speaker-Fenster das KaTeX-CSS nicht
  hat. Notizen werden jetzt als reines MathML gerendert, das der Browser selbst
  setzt; `$…$` in Notizen ist damit wieder unbedenklich.
- **1.8.2** – Notebooks (`dhbw-slides-ipynb`): Teilaufgaben a., b., c. behalten
  ihre Buchstaben (Jupyter-Markdown kennt keine Buchstaben-Listen; Pandoc machte
  daraus 1., 2., 3., und Lösungslisten ab b. begannen wieder bei 1.).
  PDF-Übungsblätter: deutsche Anführungszeichen „…“ erscheinen richtig (vorher
  „…„, weil Pandoc das schließende Zeichen als gerades " nach Typst schrieb).
- **1.8.1** – Hintergrundbilder und -videos liegen im selben 16:9-Rahmen wie der
  Folieninhalt: Auf Breitbildschirmen zeigt `background-size="cover"` denselben
  Ausschnitt wie auf dem Beamer, Overlays sitzen an derselben Stelle im Bild.
  Die Ränder daneben sind auf Bildfolien schwarz. PDF-Export und Scroll-Ansicht
  unverändert.
- **1.8.0** – Größere Schrift für den Beamer: Blöcke, `.sec`, `.merke`,
  Steckbrief (Definitionsliste) und die Tabellen `.cmp`/`.orga` 34,5 px
  (vorher 31,5 bzw. 33 px), `.leitfrage` 40,5 px (vorher 36 px). Zentral
  einstellbar über `$dhbw-box-font-size` und `$dhbw-leitfrage-font-size`.
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
