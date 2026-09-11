# DHBW Slides — Quarto-Format-Extension

reveal.js-Folien im DHBW-Look: Blöcke im Beamer-Stil, Chevron-Kapitelleiste,
Fußzeile mit Seitenzahl, KaTeX offline, alles in einer einzelnen HTML-Datei.

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
| `.texfig`                     | zentrierte Abbildung, zusammen mit `![](…){.fig}`            |
| `.hl`                         | Inline-Hervorhebung in DHBW-Rot                              |
| `.small`                      | kleinerer Fließtext                                          |

## Aufbau

```
_extensions/dhbw-slides/
    _extension.yml      Format-Definition (Geometrie, Theme, Filter)
    dhbw.scss           das komplette Theme
    dhbw.lua            schreibt window.DHBW, bindet KaTeX lokal ein
    dhbw-chrome.html    Logo, Fußzeile, Kapitelleiste, KaTeX-Aufruf
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
