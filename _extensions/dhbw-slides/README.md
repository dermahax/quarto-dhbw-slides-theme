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
anheben, Eintrag in `CHANGELOG.md` (oberste Ebene des Repos), committen, pushen.

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
| `dhbw.author`    | Dozent, z. B. Rückfall für den Klausurkopf (nicht mehr in der Fußzeile) |
| `dhbw.chapters`  | Beschriftungen der Chevrons, in Reihenfolge               |
| `dhbw.crumbs`    | `true` blendet die Kapitelpfeile ein (Vorgabe: aus)        |
| `dhbw.chapter`   | aktives Kapitel (1-basiert), optional                     |
| `dhbw.vorlesung` | Vorlesungsname in der Kopfzeile der Übungsblätter         |
| `dhbw.orga`      | Daten für die Organisatorisches-Folie (siehe unten)       |
| `subtitle`       | Untertitel auf der Titelfolie                             |

## Zeichnen und Speaker-Ansicht

Mit `chalkboard: true` (braucht `embed-resources: false`) lässt sich auf den
Folien zeichnen: Taste `C` malt auf die Folie, `B` öffnet die Tafel. Das Theme
ergänzt dazu:

- **Zeichnen in der Speaker-Ansicht** (Taste `S`): Was in der Vorschau der
  aktuellen Folie gezeichnet, radiert oder gelöscht wird, erscheint sofort auch
  im Hauptfenster auf dem Beamer, und umgekehrt. Öffnet man die Speaker-Ansicht
  später, bekommt sie die bisherigen Zeichnungen mit. Klappt auch mit `file://`.
- **Layout „Folie + Notizen“** in der Layout-Auswahl oben rechts der
  Speaker-Ansicht: aktuelle Folie groß links, Uhr und Notizen rechts, ohne
  Vorschau der nächsten Folie. reveal.js merkt sich die Wahl.
- **Vollbild-Knopf** unten links, vor den Chalkboard-Knöpfen (auch ohne
  Chalkboard), für Tablet und Stift ohne Tastatur.

Am einfachsten per Schalter statt im Kopf des Decks: `--profile interactive`
anhängen (siehe „Bauen“). Der Schalter braucht die Datei `_quarto-interactive.yml`
neben der `_quarto.yml`; `folien-pdf.ts` legt sie beim ersten Rendern von selbst
an (Vorlage: `_extensions/dermahax/dhbw-slides/profile/`). Ohne `folien-pdf.ts`
im Projekt die Vorlage einmal von Hand kopieren. Die Datei enthält genau:

```yaml
format:
  dhbw-slides-revealjs:
    embed-resources: false
    chalkboard: true
```

Ohne den Schalter bleibt die Ausgabe eine einzelne, eingebettete HTML-Datei.

## Bauen

| Befehl                                          | Folien-HTML | Folien-PDF |
|-------------------------------------------------|-------------|------------|
| `quarto render`                                 | ✓           | ✓          |
| `quarto render 03-kapitel.qmd`                  | ✓           | ✓          |
| `quarto preview …` / VS Code Strg+Umschalt+K    | ✓           | –          |
| `quarto preview … --profile pdf`                | ✓           | ✓          |
| `… --profile interactive` (render oder preview) | ✓ mit Zeichnen | wie ohne |

**Folien-PDF** (`folien-pdf.ts`): druckt jede `NN-kapitel.html` mit gleichnamiger
`.qmd` per Chrome oder Edge (headless) nach `NN-kapitel.pdf`. Eine Folie, deren
Fragmente sich nur aufbauen (Aufzählung, Bilder im `.r-stack`), wird eine Seite
im Endzustand. Verschwindet auf der Folie etwas wieder (`.fade-out`,
`.fade-in-then-out`, `.popup`, `.current-visible`), gibt es eine Seite pro
Fragment-Schritt; die Folienklasse `{.pdf-eine-seite}` zwingt auch solche
Folien auf eine Seite (alles sichtbar). Browser wird
automatisch gesucht, sonst Pfad in `DHBW_PDF_BROWSER`. Ein im Viewer geöffnetes
PDF wird mit Warnung übersprungen. Interaktive Inhalte (iframes, Widgets)
erscheinen im PDF nur im Anfangszustand. Schritt-Animationen (Heap, Dijkstra,
Labyrinth, …) bekommen genau eine Seite: Leere Fragmente, mit denen sie ihre
Schritte steuern, zählen im Druck nicht. Dasselbe gilt für Taste `E` im Browser
(Quarto öffnet dann `?view=print`, das Theme leitet auf `?print-pdf` um).

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
::: {.block .normal data-title="Definition"}     Standardblock, roter Strich
::: {.block .example data-title="Beispiel"}      Beispielblock, grauer Strich
::: {.block .alert data-title="Aufgabe"}         Aufgabe/Warnung, dunkelroter Titel
::: {.block .info data-title="Hinweis"}          blauer Strich, Glühbirne

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
::: {.incremental} | … | :::                               Tabelle Zeile für Zeile (Kopf sofort)
[rot]{.hl}   [kleiner]{.small}                             Hervorhebung / Kleindruck
| **BFS** [flachstes Ziel]{.unter} |                      Tabelle: zweite Zeile in der Zelle
: {.cmp}  (Zeile unter der Tabelle)                      Tabelle schlicht mit Linien statt Kopfband
::: {.texfig} ![](figures/bild.svg){.fig width="400"} :::  zentrierte Abbildung
::: {.unterschrift} … :::                                  kleiner zentrierter Text unter Bild
[Typ]{.zusatz}                                             kleine graue Zusatzzeile
::: {.code-gross} Codeblock :::                            Code in Vorlesungsgröße
::: {.fuell} … :::                                         Inhalt über Folienhöhe verteilen
::: {.luftig} | … | :::                                    Tabelle mit mehr Zeilenabstand
::: {.nachschlag} … :::                                    kleine graue Übersicht unten
## Titel {.pdf-eine-seite}                                Folie im PDF auf eine Seite (alles sichtbar)
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
    dhbw-chrome.html    Logo, Fußzeile, Kapitelleiste, KaTeX-Aufruf,
                        Vollbild-Knopf, Zeichnen in der Speaker-Ansicht
    orga.lua            Shortcode {{< orga >}}
    uebung.lua, uebung/ Übungsblätter und Klausuren: .loesung, Blöcke, Punkte,
                        Logo, Typst-Vorlage (dhbw-uebung, Klausur-Modus)
    loesungen.ts        Post-Render: Lösungsfassungen der Übungsblätter
    folien-pdf.ts       Post-Render: Foliensätze als PDF, legt _quarto-interactive.yml an
    profile/            _quarto-interactive.yml zum Kopieren (Zeichnen per Schalter)
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

Siehe [CHANGELOG.md](https://github.com/dermahax/quarto-dhbw-slides-theme/blob/main/CHANGELOG.md).
