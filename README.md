# quarto-dhbw-slides

Quarto-Format-Extension für reveal.js-Folien im DHBW-Look: Blöcke im
Beamer-Stil, Chevron-Kapitelleiste, Fußzeile mit Seitenzahl, KaTeX offline,
alles in einer einzelnen, ohne Internet lauffähigen HTML-Datei.

Die Extension liegt in `_extensions/dhbw-slides/` und wird von allen
Vorlesungsprojekten (Fortgeschrittene Algorithmen, Theoretische Informatik I, …)
gemeinsam genutzt. Verbesserungen werden hier gemacht und in die Projekte
nachgezogen — nicht umgekehrt.

## Installation in einem Vorlesungsprojekt

Quarto kennt keinen Package-Manager: eine Extension ist ein Ordner unter
`_extensions/` im Projekt, und `quarto add` ist nur ein Kopierbefehl, der
diesen Ordner aus dem Repo holt. Alle Befehle im Projektordner ausführen
(dort, wo `_quarto.yml` liegt).

### Neu installieren

```
quarto add <github-user>/quarto-dhbw-slides-theme
```

Quarto lädt das ZIP des Default-Branches (kein Git-Login, das Repo muss
öffentlich sein), fragt einmal „Do you trust the authors?“ und legt die
Extension unter `_extensions/<github-user>/dhbw-slides/` ab. Prüfen mit

```
quarto list extensions
```

Ist das Repo privat oder du bist offline, geht ein lokaler Klon als Quelle:

```
quarto add ../quarto-dhbw-slides-theme        # Pfad zum Klon
```

Zur Not tut es auch Kopieren von Hand: den Ordner `_extensions/dhbw-slides/`
aus diesem Repo nach `_extensions/` im Projekt legen. Dann fehlt allerdings
die Quellangabe für `quarto update`.

### Aktualisieren

Nach einer Änderung hier im Repo (Version in `_extensions/dhbw-slides/_extension.yml`
anheben, committen, pushen) in jedem Projekt:

```
quarto update <github-user>/quarto-dhbw-slides
```

Das überschreibt die Projektkopie mit dem aktuellen Stand. Änderungen direkt
in einer Projektkopie gehen dabei verloren – Theme-Änderungen deshalb immer
hier im Repo machen.

Die Extension wird bewusst **mit** ins Projekt-Repository eingecheckt, damit
jedes Projekt ohne weitere Schritte und ohne Netz baubar bleibt.

## Ein neues Projekt aufsetzen

`_quarto.yml`:

```yaml
project:
  title: "Name der Vorlesung"

lang: de

format:
  dhbw-slides-revealjs: default

dhbw:
  author: "M. Bergau"
  chapters: ["Mengen", "Relationen", "Abbildungen"]
```

Die einzelnen Kapiteldateien `01-mengen.qmd`, `02-relationen.qmd`, … brauchen im
Kopf nur noch ihren Titel:

```markdown
---
title: "Mengen"
---

## Erste Folie
```

Das aktive Chevron ergibt sich aus der führenden Nummer im Dateinamen
(`02-relationen.qmd` → zweites Chevron). Deshalb die Kapiteldateien
durchnummeriert benennen; `dhbw.chapter` im YAML-Kopf überschreibt die Nummer.

Bauen mit `quarto render` (alle) oder `quarto render 01-mengen.qmd`; beim
Schreiben ist `quarto preview 01-mengen.qmd` angenehmer.

## Konfiguration

| Schlüssel        | Bedeutung                                                   |
|------------------|-------------------------------------------------------------|
| `dhbw.author`    | Name in der Fußzeile. Fällt auf `author` zurück.             |
| `dhbw.chapters`  | Beschriftungen der Chevrons, in Reihenfolge.                 |
| `dhbw.chapter`   | Nummer des aktiven Kapitels (1-basiert). Optional.           |
| `subtitle`       | Untertitel auf der Titelfolie (z. B. Name der Vorlesung).    |


Die Versionsnummer in `_extensions/dhbw-slides/_extension.yml` bei Änderungen
anheben; `quarto update` zeigt sie an.
