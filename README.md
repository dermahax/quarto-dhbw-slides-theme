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

## Übungsblätter

Übungsblätter entstehen mit derselben Extension als PDF (Typst, in Quarto
enthalten, kein LaTeX nötig) oder als Jupyter-Notebook für
Programmieraufgaben: kleines DHBW-Logo und Vorlesung in der Kopfzeile,
Aufgaben als `##`-Überschriften.

**Eine Datei je Blatt.** Die Lösung steht direkt unter der Aufgabe:

```markdown
---
title: "Übungsblatt 1: Einführung"
subtitle: "Induktion, Gegenbeispiele, Korrektheit"   # optional
format: dhbw-slides-typst          # PDF;  dhbw-slides-ipynb für ein Notebook
---

# Teil A: Vollständige Induktion

## Aufgabe 1

Beweisen Sie …

::: {.loesung}
**Induktionsanfang** …
:::
```

**Aufgaben- und Lösungsfassung aus einem `quarto render`.** Dafür einmalig in
der `_quarto.yml` des Vorlesungsprojekts:

```yaml
project:
  post-render: _extensions/dermahax/dhbw-slides/loesungen.ts

dhbw:
  vorlesung: "Name der Vorlesung"      # Kopfzeile der Übungsblätter
```

Dann liefert `quarto render Uebungen/ueb-01.qmd`:

| Format              | Aufgaben        | Lösungen                                   |
|---------------------|-----------------|--------------------------------------------|
| `dhbw-slides-typst` | `ueb-01.pdf`    | `ueb-01-loesung.pdf` (blaue Lösungskästen) |
| `dhbw-slides-ipynb` | `ueb-01.ipynb`  | `ueb-01-loesung.ipynb` (Zellen mit Tag `loesung`) |

Ohne das Skript entsteht nur die Aufgabenfassung; zum schnellen Ansehen der
Lösungen geht auch `quarto render ueb-01.qmd -M loesung:true`.

Die Übungsblätter liegen im Vorlesungsprojekt selbst (z. B. `Uebungen/`), nicht
in einem eigenen Unterprojekt mit eigener `_quarto.yml` — sonst findet Quarto die
Extension nicht. Das `format:` im Kopf jeder Datei sorgt dafür, dass sie nicht als
Folien gerendert werden. Bilder aus `figures/` gehen mit `../figures/…`.

Hinweise:

- Im PDF funktionieren auch die Folienblöcke
  (`::: {.block .alert data-title="…"}` usw.).
- Schrift ist Arial (wie die Folien unter Windows); anderes mit `mainfont:`.
- Notebooks werden nicht ausgeführt. Bei Python-Zellen `jupyter: python3` in den
  Kopf schreiben. Das Logo steckt als Data-URI im Notebook, es lässt sich also
  einzeln verschicken.
- Braucht Quarto ≥ 1.5 (Typst ≥ 0.11).

## Syntax-Spickzettel

Jede Folie beginnt mit `##`. Darunter normales Markdown.

```markdown
::: {.block .normal data-title="Definition"}     grauer Standardblock
::: {.block .example data-title="Beispiel"}      Beispielblock
::: {.block .alert data-title="Aufgabe"}         roter Block
::: {.block .info data-title="Hinweis"}          blauer Block

::: {.cols}  ::: {.col} … :::  ::: {.col} … :::  :::     zwei Spalten
::: {.col style="flex:60"}                                 ungleiche Breite
::: {.cols .unequal}                                       Blöcke nicht gleich hoch
::: {.popup} … :::                                        Overlay, erscheint und verschwindet
::: {.popup .static} … :::                                Overlay, dauerhaft sichtbar
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
(`quarto render example.qmd`), für Übungsblätter `example-uebung.qmd`.

## Aufbau der Extension

```
_extensions/dhbw-slides/
    _extension.yml      Format-Definition (Geometrie, Theme, Filter)
    dhbw.scss           das komplette Theme
    dhbw.lua            schreibt window.DHBW, bindet KaTeX lokal ein
    dhbw-math.lua       Formeln als TeX-Spans (verhindert Quartos CDN-Loader)
    orga.lua            Shortcode {{< orga >}} für die Organisatorisches-Folie
    dhbw-chrome.html    Logo, Fußzeile, Kapitelleiste, KaTeX-Aufruf
    uebung.lua          Übungsblätter: .loesung, Blöcke, Logo
    uebung/             Typst-Vorlage der Übungsblätter (Kopf, Titel, Kästen)
    loesungen.ts        Post-Render-Skript: erzeugt die Lösungsfassungen
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
injiziert einen CDN-Loader (der wegen eines Quarto-Fehlers sogar MathJax 2 von
cdn.jsdelivr.net holt) — die Folien bräuchten beim Vorführen Internet. Deshalb:

- `dhbw-math.lua` (läuft nach Quartos Filtern, `at: post-quarto`) schreibt jede
  Formel als rohes TeX in `<span class="math inline|display">`. Weil danach kein
  Formel-Element mehr im Dokument steht, hängt Quarto gar keinen Loader an.
  Gleichungsnummern aus `{#eq-…}` stehen dann schon als `\tag{…}` im TeX.
- `dhbw.lua` bindet KaTeX samt Schriften aus dem Extension-Ordner ein.
- `dhbw-chrome.html` rendert die Spans und alles zwischen `\(…\)` / `\[…\]`.

Die fertige HTML-Datei lädt damit nichts mehr aus dem Netz.

**Scroll-Ansicht.** reveal.js schaltet unter 435 px Fensterbreite automatisch in
die Scroll-Ansicht (sonst Taste R). Beim Einschalten merkt es sich das
Folien-HTML, beim Ausschalten schreibt es diese Kopie zurück. War die Kopie
älter als das KaTeX-Rendern, stünde danach wieder rohes TeX auf den Folien. Das
passiert z. B. in Moodle („Einbetten“): Das iframe ist beim Laden noch schmal
und wird erst danach vergrößert. `dhbw-chrome.html` beobachtet deshalb `.slides`
und rendert neu, sobald reveal.js die Folien austauscht.

## Veröffentlichen

Zum ersten Mal:

```
cd quarto-dhbw-slides-theme
git remote add origin git@github.com:dermahax/quarto-dhbw-slides-theme.git
git push -u origin main
```

Die Versionsnummer in `_extensions/dhbw-slides/_extension.yml` bei Änderungen
anheben; `quarto update` zeigt sie an.

## Änderungen

- **1.5.1** – Formeln bleiben gerendert, wenn reveal.js die Scroll-Ansicht
  verlässt (vorher rohes TeX, u. a. beim Einbetten in Moodle). Kein
  CDN-Loader mehr: neuer Filter `dhbw-math.lua`, die HTML-Datei lädt nichts
  mehr aus dem Netz.
- **1.5.0** – Übungsblätter: neue Formate `dhbw-slides-typst` (PDF) und
  `dhbw-slides-ipynb` (Notebook) mit Logo, `::: {.loesung}` unter jeder Aufgabe
  und Post-Render-Skript `loesungen.ts`, das die Lösungsfassung miterzeugt.
  Neuer Schlüssel `dhbw.vorlesung`. Beispiel: `example-uebung.qmd`.
- **1.4.0** – Neue Klasse `.popup`: schwebendes Overlay über der Folie, absolut
  positioniert (keine Lücke im Fließtext). Allein oder mit `.block` kombinierbar.
  Wird automatisch zum Fragment `.fade-in-then-out`; `.static` schaltet das ab.
- **1.3.0** – Spaltenblöcke sind standardmäßig gleich hoch; `.cols .equal` ist
  damit überflüssig (bleibt aber gültig). Neue Ausnahme `.cols .unequal`.
- **1.2.1** – Logo mit transparentem Hintergrund (nur die Rechtecke), damit es auch
  auf dunklen, vollflächigen Bildfolien sauber aussieht.
- **1.2.0** – Shortcode `{{< orga >}}`, Bildraster `.cols.grid`, `.qed`.
