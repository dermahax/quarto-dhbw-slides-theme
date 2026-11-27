# Änderungen

Versionshistorie des Themes `dhbw-slides`, neueste Version oben.

- **1.20.0** – Die Profil-Datei für `--profile interactive` kommt jetzt von
  selbst ins Vorlesungsprojekt: `folien-pdf.ts` legt beim Rendern
  `_quarto-interactive.yml` neben die `_quarto.yml`, wenn sie dort fehlt
  (eine vorhandene Datei bleibt, wie sie ist). Nach `quarto update` genügt
  also einmal normales Rendern oder `quarto preview`, dann wirkt der Schalter.
  Voraussetzung: `folien-pdf.ts` steht unter `post-render` in der `_quarto.yml`.
- **1.19.0** – Zeichnen per Schalter: `--profile interactive` rendert die
  Folien mit `embed-resources: false` und `chalkboard: true`, ohne dass das im
  Kopf des Decks stehen muss (`quarto render 03-kapitel.qmd --profile interactive`,
  ebenso mit `quarto preview`). Ohne den Schalter bleibt es die eine
  eingebettete HTML-Datei. Dafür einmal pro Vorlesung die Datei
  `_extensions/dermahax/dhbw-slides/profile/_quarto-interactive.yml` neben die
  `_quarto.yml` kopieren (Quarto liest Profile nur aus dem Projektordner, eine
  Extension kann keins mitbringen).
- **1.18.0** – Tabellen Zeile für Zeile: `::: {.incremental}` um eine
  Tabelle macht jede Zeile des Tabellenkörpers zu einem Fragment, die
  Kopfzeile steht sofort da (bisher wirkte `.incremental` nur auf Listen).
  Im PDF bleibt es eine Seite mit der ganzen Tabelle (wie 1.14.0). Umgesetzt
  im Filter `dhbw.lua`, neu rendern genügt.
- **1.17.0** – Neues Aussehen der Blöcke (`.normal`, `.example`, `.alert`,
  `.info`): weiße Karte mit farbigem Strich links (wie Frametitel und
  Merksatz), feinem grauem Rand und weichem Schatten; der Titel steht in der
  Typfarbe ohne graues Band. Rot = normal, Grau = example, Dunkelrot = alert,
  Blau mit Glühbirne = info. Abstände und Schriftgrößen sind unverändert, die
  Blöcke brauchen genau so viel Platz wie vorher. Gilt auch für Alt-Blöcke mit
  `.bt`/`.bb` und für `.block .popup`. Neu rendern genügt.
- **1.16.0** – Folien-PDF auch beim Rendern einer einzelnen Datei:
  `quarto render 03-kapitel.qmd` erzeugt jetzt neben dem HTML auch
  `03-kapitel.pdf`, nicht mehr nur das Rendern des ganzen Projekts. In der
  Vorschau (`quarto preview`, VS Code Strg+Umschalt+K) entsteht weiterhin kein
  PDF, damit das Speichern schnell bleibt; `--profile pdf` erzwingt es dort.
- **1.15.0** – Speaker-Ansicht: Malen auf der Folie (Taste `C` oder
  Stift-Knopf) wird jetzt in Speaker-Fenster und Beamer gleichzeitig ein- und
  ausgeschaltet. Die Farbauswahl erscheint dadurch auch in der Speaker-Ansicht,
  egal in welchem Fenster die Taste ankam. Die Tafel (Taste `B`) war schon
  vorher in beiden Fenstern synchron.
- **1.14.0** – PDF-Export: Folien, deren Fragmente sich nur aufbauen
  (Aufzählungen, Bildfolgen mit `![](…){.fragment}` im `.r-stack`), erscheinen
  als eine Seite im Endzustand statt als eine Seite pro Schritt. Folien, auf
  denen etwas wieder verschwindet (`.fade-out`, `.fade-in-then-out`, `.popup`,
  `.current-visible`, `.semi-fade-out`), behalten eine Seite pro Schritt, damit
  Aufgabe/Lösung nicht übereinanderliegen und Pop-ups nicht fehlen. Neue
  Folienklasse `## Titel {.pdf-eine-seite}` erzwingt auch dort eine Seite mit
  allem sichtbar (z. B. ein Pop-up mit Suchbaum, das sich am Ende schließt).
  Eigene `.css`-Dateien mit leeren Fragmenten vor Bildern sind dafür nicht mehr nötig.
- **1.13.0** – Hilfsklassen, die bisher als eigene `.css`-Datei neben einzelnen
  Decks lagen, sind jetzt im Theme: `::: {.code-gross}` (Code in 38 px),
  `::: {.fuell}` (Inhalt über die Folienhöhe verteilen), `::: {.luftig}`
  (Tabelle mit mehr Zeilenabstand), `::: {.nachschlag}` (kleine graue
  Übersicht), `::: {.unterschrift}` (kleiner zentrierter Text unter einem Bild)
  und `[Text]{.zusatz}` (kleine graue Zusatzzeile). Die `css:`-Zeile im Header
  entfällt dafür.
- **1.12.1** – Fehlerbehebung Speaker-Ansicht: Wurde die Präsentation neu
  geladen (z. B. nach erneutem Rendern), während das Speaker-Fenster offen
  blieb, öffnete ein `.notes-overlay`-Link wieder einen neuen Tab statt des
  Overlays. Das Overlay läuft jetzt im Speaker-Fenster selbst und übersteht
  das Neuladen (auch bei direkt geöffneter HTML-Datei, file://).
- **1.12.0** – Speaker-Ansicht: Ein Link in den Notes mit der Klasse
  `.notes-overlay` öffnet sein Ziel als Überlagerung im Speaker-Fenster statt
  in einem neuen Tab, z. B. eine Schritt-Animation aus `figures/`:
  `[▶ Animation öffnen](figures/kapitel/name.html){.notes-overlay target="_blank"}`.
  Schließen mit dem Knopf, Klick daneben oder Esc. Solange die Überlagerung den
  Fokus hat, steuern die Pfeiltasten die Animation und blättern nicht in den
  Folien. Der Link erscheint in den Notes als roter Knopf. Damit Esc auch bei
  direkt geöffneter HTML-Datei (file://) schließt, meldet die Animation die
  Taste selbst: `window.parent.postMessage(JSON.stringify({namespace: 'dhbw-overlay', type: 'close'}), '*')`.
- **1.11.0** – Neues Standardlayout für Tabellen (Mockup A „Kopfband +
  Streifen“): Jede Markdown-Tabelle ohne eigene Klasse bekommt einen grauen
  Kopf mit rotem Titel wie die Blocktitel, abwechselnd hellgraue Zeilen und
  weiße Fugen zwischen den Spalten, Schrift 34,5 px wie die Blöcke. Neu:
  `[Text]{.unter}` setzt in einer Zelle eine zweite Zeile darunter (im Kopf
  kleiner und normal, z. B. „OPEN als Queue / Stack“). `.cmp` und `.orga`
  bleiben unverändert.
- **1.10.2** – PDF-Export: Jede Schritt-Animation erscheint nur noch auf einer
  Seite statt auf einer Seite pro Schritt. Leere Fragmente (die unsichtbaren
  Schritt-Marken der Animationen) werden im Druck zu normalen Elementen, echte
  Fragmente mit Inhalt bekommen weiter je eine Seite. Taste `E` (Quartos
  `?view=print`) wird auf `?print-pdf` umgeleitet, damit Animationen wie Heap,
  Dijkstra und Greedy auch dort ihren Endzustand zeigen.
- **1.10.1** – Zeichnen in der Speaker-Ansicht: Striche landen in Vorschau und
  Beamer jetzt an derselben Stelle der Folie. Vorher rechnete das
  Chalkboard-Plugin bis zur ersten Fenstergrößenänderung in Bildschirmpixeln,
  bei verschieden großen Fenstern war der Ausschnitt verschoben.
- **1.10.0** – Zeichnen in der Speaker-Ansicht: Chalkboard-Striche (Taste `C`
  und Tafel `B`), Radieren und Löschen in der Vorschau der aktuellen Folie
  werden aufs Hauptfenster gespiegelt und umgekehrt. Neues Speaker-Layout
  „Folie + Notizen“ (große aktuelle Folie, keine Vorschau der nächsten).
  Vollbild-Knopf unten links vor den Chalkboard-Knöpfen. Kapitelpfeile sind
  jetzt standardmäßig aus (`dhbw.crumbs: true` schaltet sie ein), der Name
  steht nicht mehr in der Fußzeile, unten rechts nur noch die Seitenzahl.
- **1.8.7** – Klausur-Modus: keine Warnungen „unknown font family: liberation
  sans / carlito“ mehr beim Rendern unter Windows. Die Vorlage nennt nur noch
  Arial und Calibri.
- **1.8.6** – Klausur-Modus für PDFs (`dhbw-slides-typst`): Ein Block
  `klausur:` im Dokumentkopf setzt das Dokument im Layout der DHBW-Klausurvorlage
  (Deckblatt, Kopfzeile mit Logo und „Seite x von y“, Arial 12 pt, Teilaufgaben
  a), b), …), siehe [Klausuren](_extensions/dhbw-slides/README.md#klausuren). Neu für Klausuren und Übungsblätter:
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
