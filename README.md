# quarto-dhbw-slides

Quarto-Format-Extension für reveal.js-Folien im DHBW-Look: Blöcke im
Beamer-Stil, Chevron-Kapitelleiste, Fußzeile mit Seitenzahl, KaTeX offline,
alles in einer einzelnen, ohne Internet lauffähigen HTML-Datei.

Die Extension liegt in `_extensions/dhbw-slides/` und wird von allen
Vorlesungsprojekten (Fortgeschrittene Algorithmen, Theoretische Informatik I, …)
gemeinsam genutzt. Verbesserungen werden hier gemacht und in die Projekte
nachgezogen — nicht umgekehrt.

## Installation in einem Vorlesungsprojekt

Im Projektordner (dort, wo `_quarto.yml` liegt):

```
quarto add <github-user>/quarto-dhbw-slides
```

Das kopiert `_extensions/dhbw-slides/` ins Projekt. Später aktualisieren:

```
quarto update <github-user>/quarto-dhbw-slides
```

Ohne GitHub (oder offline) funktioniert auch ein lokaler Pfad:

```
quarto add ../quarto-dhbw-slides
```

oder schlicht: den Ordner `_extensions/dhbw-slides/` ins Projekt kopieren.
Die Extension wird bewusst **mit** ins Projekt-Repository eingecheckt, damit
jedes Projekt ohne weitere Schritte baubar bleibt.

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

## Syntax-Spickzettel

Jede Folie beginnt mit `##`. Darunter normales Markdown.

```markdown
::: {.block .normal data-title="Definition"}     grauer Standardblock
::: {.block .example data-title="Beispiel"}      Beispielblock
::: {.block .alert data-title="Aufgabe"}         roter Block
::: {.block .info data-title="Hinweis"}          blauer Block

::: {.cols}  ::: {.col} … :::  ::: {.col} … :::  :::     zwei Spalten
::: {.col style="flex:60"}                                 ungleiche Breite
::: {.notes} … :::                                         Sprechernotizen (Taste S)
::: {.incremental} - … :::                                 Liste Punkt für Punkt
. . .                                                      Pause
$x$   $$ x $$                                              Formeln (KaTeX)
[rot]{.hl}   [kleiner]{.small}                             Hervorhebung / Kleindruck
::: {.texfig} ![](figures/bild.svg){.fig width="400"} :::  zentrierte Abbildung
```

Ein Blocktitel steht in `data-title` und ist reiner Text. Braucht der Titel eine
Formel oder Fettdruck, den Block als HTML schreiben:

````markdown
```{=html}
<div class="block normal"><div class="bt">Titel mit \(\log_b a\)</div><div class="bb">
```
… normales Markdown …
```{=html}
</div></div>
```
````

Alle Elemente einmal zum Ausprobieren: `example.qmd` in diesem Repo
(`quarto render example.qmd`).

## Aufbau der Extension

```
_extensions/dhbw-slides/
    _extension.yml      Format-Definition (Geometrie, Theme, Filter)
    dhbw.scss           das komplette Theme
    dhbw.lua            schreibt window.DHBW, bindet KaTeX lokal ein
    dhbw-chrome.html    Logo, Fußzeile, Kapitelleiste, KaTeX-Aufruf
    logo.png            Quelle für das eingebettete Logo
    katex/              KaTeX 0.16.11 inkl. Schriften
```

Das Logo steckt als Data-URI in `dhbw-chrome.html`. Nach einem Austausch von
`logo.png` muss die Data-URI in der ersten Zeile neu erzeugt werden:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("logo.png")) | Set-Clipboard
```

## Warum KaTeX von Hand geladen wird

Mit `embed-resources: true` verwirft Quarto eine lokale KaTeX-Angabe und
injiziert einen CDN-Loader — die Folien bräuchten beim Vorführen Internet.
Deshalb liefert `html-math-method: katex` nur rohes TeX in `<span class="math">`,
`dhbw.lua` bindet KaTeX aus dem Extension-Ordner ein, und `dhbw-chrome.html`
rendert die Spans selbst und entfernt danach die Klasse `math`, damit Quartos
CDN-Renderer nichts mehr findet. Zwei Konsolenfehler des ins Leere laufenden
CDN-Versuchs sind normal und folgenlos.

## Veröffentlichen

Zum ersten Mal:

```
cd quarto-dhbw-slides
git remote add origin git@github.com:<github-user>/quarto-dhbw-slides.git
git push -u origin main
```

Die Versionsnummer in `_extensions/dhbw-slides/_extension.yml` bei Änderungen
anheben; `quarto update` zeigt sie an.
