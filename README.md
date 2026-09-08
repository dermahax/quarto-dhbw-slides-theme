# quarto-dhbw-slides-theme

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
quarto add dermahax/quarto-dhbw-slides-theme
```

Quarto lädt das ZIP des Default-Branches (kein Git-Login, das Repo muss
öffentlich sein), fragt einmal „Do you trust the authors?“ und legt die
Extension unter `_extensions/dermahax/dhbw-slides/` ab. Prüfen mit

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

### Eine von Hand kopierte Extension ablösen

Liegt im Projekt schon eine Kopie ohne Owner-Ordner (`_extensions/dhbw-slides/`),
zuerst diese entfernen – sonst liegen zwei Extensions mit demselben Namen
nebeneinander und Quarto meldet ein mehrdeutiges Format:

```
quarto remove dhbw-slides
quarto add dermahax/quarto-dhbw-slides-theme
quarto render 01-…qmd                  # Probe
```

An `_quarto.yml` ändert sich nichts: `format: dhbw-slides-revealjs` und der
Block `dhbw:` bleiben gleich, Quarto findet das Format auch im Owner-Unterordner.

### Aktualisieren

Nach einer Änderung hier im Repo (Version in `_extensions/dhbw-slides/_extension.yml`
anheben, committen, pushen) in jedem Projekt:

```
quarto update dermahax/quarto-dhbw-slides-theme
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

## Organisatorisches-Folie

Der Shortcode `{{< orga >}}` baut aus einem Datenblock in der `_quarto.yml`
eine Steckbrief-Folie (rote Labels links, Werte rechts). Die Daten stehen
unter `dhbw.orga`, jedes Feld ist optional; Markdown in den Werten ist erlaubt:

```yaml
dhbw:
  orga:
    inhalt:
      - "Algebraische Strukturen: Mengen, Relationen, Abbildungen"
      - "Aussagen- und Prädikatenlogik"
    zeitraum: "01.10.2026 – 20.12.2026"
    pruefung: "**Klausur** (Modul T4INF1002, 5 ECTS)"
    links:
      - { text: "Folien und Übungen", url: "https://github.com/…" }
      - { text: "Moodle-Kurs", url: "https://moodle.…" }
    kontakt: "Vorname Name · vorname.name@dhbw-loerrach.de"
    extra:                                   # weitere Zeilen, optional
      - { label: "Übungen", value: "freitags, 14:00 Uhr" }
```

Dazu eine Datei `00-orga.qmd` (die 0 lässt in der Chevron-Leiste kein Kapitel
aktiv):

```markdown
---
title: "Organisatorisches"
subtitle: "Name der Vorlesung"
---

## Organisatorisches

{{< orga >}}
```

Weitere Orga-Folien (Ablaufplan, Übungsbetrieb …) danach ganz normal mit `##`.

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
    orga.lua            Shortcode {{< orga >}} für die Organisatorisches-Folie
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
cd quarto-dhbw-slides-theme
git remote add origin git@github.com:dermahax/quarto-dhbw-slides-theme.git
git push -u origin main
```

Die Versionsnummer in `_extensions/dhbw-slides/_extension.yml` bei Änderungen
anheben; `quarto update` zeigt sie an.
