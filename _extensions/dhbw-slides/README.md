# DHBW Slides — Quarto-Format-Extension

reveal.js-Folien im DHBW-Look: Blöcke im Beamer-Stil, Chevron-Kapitelleiste,
Fußzeile mit Seitenzahl, KaTeX offline, alles in einer einzelnen HTML-Datei.
Dazu Übungsblätter im selben Stil als PDF (`dhbw-slides-typst`) oder
Jupyter-Notebook (`dhbw-slides-ipynb`), Aufgaben und Lösungen in einer Datei.

## In ein neues Vorlesungsprojekt übernehmen

Den Ordner `_extensions/dhbw-slides/` in das neue Projekt kopieren. Dann im
`_quarto.yml` des Projekts:

```yaml
project:
  title: "Name der Vorlesung"

lang: de

format:
  dhbw-slides-revealjs: default

dhbw:
  author: "M. Bergau"
  chapters: ["Einf.", "Asympt.", "Analyse", "D&C", "Graphen"]
```

Die einzelnen `.qmd`-Dateien brauchen im Kopf nur noch ihren Titel.

## Konfiguration

| Schlüssel        | Bedeutung                                                        |
|------------------|------------------------------------------------------------------|
| `dhbw.author`    | Name in der Fußzeile. Fällt auf `author` zurück.                  |
| `dhbw.chapters`  | Beschriftungen der Chevrons, in Reihenfolge.                      |
| `dhbw.chapter`   | Nummer des aktiven Kapitels (1-basiert). Optional.                |
| `dhbw.vorlesung` | Name der Vorlesung in der Kopfzeile der Übungsblätter.            |

Ohne `dhbw.chapter` wird die Nummer aus dem Dateinamen abgeleitet:
`05-graphen.qmd` markiert das fünfte Chevron. Deshalb die Kapiteldateien
durchnummeriert benennen.

## Eigene Klassen

| Klasse                        | Wirkung                                                     |
|-------------------------------|-------------------------------------------------------------|
| `.block` + `.normal/.example/.alert` mit `data-title` | Beamer-artiger Block         |
| `.cols` / `.col`              | Spalten nebeneinander                                        |
| `.cols .unequal`              | Spaltenblöcke nur so hoch wie ihr Inhalt (Standard ist gleich hoch) |
| `.stack`                      | Kinder liegen übereinander — Fragmente ersetzen einander     |
| `.popup`                      | schwebendes Overlay (absolut, keine Lücke im Text); erscheint und verschwindet automatisch als Fragment, `.static` = immer sichtbar |
| `.texfig`                     | zentrierte Abbildung, zusammen mit `![](…){.fig}`            |
| `.hl`                         | Inline-Hervorhebung in DHBW-Rot                              |
| `.small`                      | kleinerer Fließtext                                          |

## Übungsblätter

Eine `.qmd` je Blatt, die Lösung steht als `::: {.loesung}` direkt unter der
Aufgabe:

```markdown
---
title: "Übungsblatt 1: Einführung"
format: dhbw-slides-typst          # PDF;  dhbw-slides-ipynb für ein Notebook
---

## Aufgabe 1

Beweisen Sie …

::: {.loesung}
Induktionsanfang …
:::
```

Mit dem Post-Render-Skript in der `_quarto.yml` des Projekts erzeugt ein
`quarto render` beide Fassungen (`ueb-01.pdf` und `ueb-01-loesung.pdf` bzw.
`.ipynb`):

```yaml
project:
  post-render: _extensions/dermahax/dhbw-slides/loesungen.ts
```

Ohne das Skript entsteht nur die Aufgabenfassung; `-M loesung:true` zeigt die
Lösungen direkt an. Im PDF funktionieren auch die Folienblöcke
(`::: {.block .alert data-title="…"}`). Notebooks werden nicht ausgeführt; bei
Python-Zellen `jupyter: python3` in den Kopf schreiben.

## Aufbau

```
_extensions/dhbw-slides/
    _extension.yml      Format-Definition (Geometrie, Theme, Filter)
    dhbw.scss           das komplette Theme
    dhbw.lua            schreibt window.DHBW, bindet KaTeX lokal ein
    dhbw-math.lua       Formeln als TeX-Spans (verhindert Quartos CDN-Loader)
    dhbw-chrome.html    Logo, Fußzeile, Kapitelleiste, KaTeX-Aufruf
    uebung.lua          Übungsblätter: .loesung, Blöcke, Logo
    uebung/             Typst-Vorlage der Übungsblätter
    loesungen.ts        Post-Render-Skript: erzeugt die Lösungsfassungen
    logo.png            Quelle für das eingebettete Logo
    katex/              KaTeX 0.16 inkl. Schriften
```

Das Logo steckt als Data-URI in `dhbw-chrome.html`. Nach einem Austausch von
`logo.png` muss die Data-URI in der ersten Zeile neu erzeugt werden:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("logo.png")) | Set-Clipboard
```

## Später zentral pflegen

Den Ordner `_extensions/dhbw-slides/` als eigenes Git-Repository anlegen, dann
installieren andere Projekte per `quarto add <user>/<repo>` und ziehen
Verbesserungen mit `quarto update <user>/<repo>` nach.
