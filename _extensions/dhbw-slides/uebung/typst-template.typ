// ===== DHBW-Übungsblatt (Format dhbw-slides-typst) =====
// Kopfzeile mit Vorlesung und kleinem Logo, schlichte Überschriften,
// Lösungen als blaue Kästen unter den Aufgaben.

#let dhbw-red      = rgb("#E0001A")
#let dhbw-darkred  = rgb("#961620")
#let dhbw-gray     = rgb("#58636C")
#let dhbw-lightgray = rgb("#7F8A96")
#let dhbw-darkblue = rgb("#12507f")

// Lösungen erscheinen, wenn das Dokument mit loesung: true gerendert wird
// oder die .typ-Datei mit  --input loesung=true  kompiliert wird
// (das macht das Post-Render-Skript loesungen.lua).
#let dhbw-loesung-an = sys.inputs.at("loesung", default: "false") == "true"

#let dhbw-loesung(zeigen: false, body) = {
  if zeigen or dhbw-loesung-an {
    block(
      width: 100%,
      breakable: true,
      above: 0.9em,
      below: 1.2em,
      fill: rgb("#eff4fa"),
      stroke: (left: 2.5pt + dhbw-darkblue),
      inset: (left: 11pt, right: 10pt, y: 8pt),
      radius: (right: 3pt),
    )[
      // "Lösung" nie allein am Seitenende (sticky gibt es ab Typst 0.12)
      #let kopf = text(weight: "bold", fill: dhbw-darkblue)[Lösung]
      #if sys.version >= version(0, 12, 0) {
        block(sticky: true, below: 0.8em, kopf)
      } else {
        block(below: 0.8em, kopf)
      }
      #body
    ]
  }
}

// Blöcke wie auf den Folien: ::: {.block .alert data-title="…"}
#let dhbw-block(art: "normal", titel: none, body) = {
  let (kopf, rumpf, farbe) = if art == "alert" {
    (rgb("#f9d1d6"), rgb("#fdeff1"), dhbw-darkred)
  } else if art == "info" {
    (rgb("#cfe0f2"), rgb("#eff4fa"), dhbw-darkblue)
  } else if art == "example" {
    (rgb("#dfe2e5"), rgb("#f2f3f5"), dhbw-gray)
  } else {
    (rgb("#dadde0"), rgb("#f2f2f3"), dhbw-red)
  }
  block(width: 100%, breakable: true, above: 0.9em, below: 1.1em,
        radius: 4pt, clip: true, fill: rumpf, stroke: 0.4pt + luma(215))[
    #if titel != none {
      block(width: 100%, fill: kopf, inset: (x: 10pt, y: 6pt), below: 0pt,
            text(weight: "bold", fill: farbe, titel))
    }
    #block(width: 100%, inset: (x: 10pt, y: 8pt), above: 0pt, body)
  ]
}


// ===== Klausur-Modus (klausur: im Dokumentkopf) =====
// Layout der DHBW-Klausurvorlage (Studienzentrum IT-Management/Informatik):
// Kopfzeile mit Logo, Studienzentrum und „Seite x von y“, Deckblatt mit
// Lehrveranstaltung, Kurs, Datum, Dozent/in, Matrikel-Nummer und Hinweisen,
// danach die Aufgaben in Arial 12 pt.
#let dhbw-klausur-layout(
  title: none,
  vorlesung: none,
  author: none,
  date: none,
  logo: none,
  lang: "de",
  paper: "a4",
  k: (:),
  doc,
) = {
  let font = ("Arial", "Liberation Sans")
  let kopf-font = ("Calibri", "Carlito", "Arial", "Liberation Sans")
  set document(title: title) if title != none
  set text(lang: lang, font: font, size: 12pt)
  set par(justify: false, leading: 0.65em)

  set page(
    paper: paper,
    margin: (left: 2.5cm, right: 2.5cm, top: 3cm, bottom: 2.2cm),
    header-ascent: 18%,
    header: {
      grid(
        columns: (auto, 1fr, auto),
        column-gutter: 2pt,
        align: (left + bottom, left + bottom, right + bottom),
        {
          let l = k.at("logo", default: logo)
          if l != none { move(dx: -13pt, dy: 4pt, image(l, height: 1.57cm)) }
        },
        move(dx: -13pt, dy: -5pt, text(font: kopf-font, size: 16pt, fill: luma(128),
          k.at("studienzentrum", default: [Studienzentrum IT-Management/ Informatik]))),
        move(dy: -6pt, text(font: kopf-font, size: 11pt, context [Seite #counter(page).display() von #counter(page).final().first()])),
      )
      v(-2pt)
      line(length: 100%, stroke: 0.5pt + black)
    },
  )

  // ---- Überschriften: schwarz, fett, 12 pt wie „Aufgabe 1 (6 Punkte): …“
  set heading(numbering: none)
  show heading: it => {
    let inhalt = text(size: 12pt, weight: "bold", it.body)
    if sys.version >= version(0, 12, 0) {
      block(above: 1.6em, below: 0.55em, sticky: true, inhalt)
    } else {
      block(above: 1.6em, below: 0.55em, inhalt)
    }
  }

  // ---- Listen, Code, Tabellen
  set list(marker: [-], indent: 1.5em, body-indent: 1.1em)
  set enum(indent: 0.6em, body-indent: 0.6em)
  show raw: set text(font: ("Consolas", "DejaVu Sans Mono"), size: 0.9em)
  show raw.where(block: true): set block(width: 100%, fill: luma(245),
    inset: (x: 10pt, y: 8pt), radius: 3pt, breakable: false)
  set table(stroke: 0.5pt + luma(170), inset: 5pt)

  // ---- Deckblatt
  let titel = if title == none { "Klausur" } else { title }
  v(1.1cm)
  // gesperrt wie „K L A U S U R“: Sperrung = Breite eines Leerzeichens
  align(center, text(size: 18pt, weight: "bold", tracking: 0.278em, upper(titel)))
  if dhbw-loesung-an {
    v(-0.3em)
    align(center, text(size: 14pt, weight: "bold", fill: rgb("#12507f"), [Musterlösung]))
  }
  v(-0.1cm)
  pad(left: 2.5cm, grid(
    columns: (auto, 1fr),
    column-gutter: 0.6em,
    row-gutter: 0.7cm,
    ..(
      ([Lehrveranstaltung:], k.at("lehrveranstaltung", default: vorlesung)),
      ([Kurs:], k.at("kurs", default: none)),
      ([Datum:], k.at("datum", default: date)),
      ([Dozent/in:], k.at("dozent", default: author)),
    ).map(((l, w)) => (
      text(size: 16pt, weight: "bold", l),
      text(size: 16pt, if w != none { w }),
    )).flatten()
  ))
  v(1.2cm)
  text(size: 14pt, weight: "bold")[Matrikel-Nummer:]
  v(0.85cm)
  // Zeilenabstand wie in der Vorlage (26 pt von Zeile zu Zeile)
  stack(spacing: 18pt,
    [Erlaubte Hilfsmittel: #k.at("hilfsmittel", default: [keine])],
    [Dauer: #k.at("dauer", default: none)],
    [max. zu erreichende Punktzahl: #k.at("punkte", default: none)],
    text(weight: "bold")[Hinweise:],
  )
  v(0.5em)
  list(
    context [Überprüfen Sie bitte zunächst, ob Sie alle #counter(page).final().first() Seiten (inkl. dieses Deckblattes) vorliegen haben.],
    [Schreiben Sie auf jedes Lösungsblatt Ihre Matrikelnummer. Bitte schreiben Sie *nicht Ihren Namen*, sondern nur Ihre Matrikelnummer auf die Klausur!],
    [Schreiben Sie nur mit einem dokumentenechten Stift (kein Bleistift, kein Rotstift!).],
    [Lassen Sie bitte auf der rechten Seite 3 cm Rand.],
  )
  pagebreak()

  doc
}

#let dhbw-uebung(
  title: none,
  subtitle: none,
  date: none,
  vorlesung: none,
  author: none,
  logo: none,
  loesung: false,
  lang: "de",
  font: ("Arial",),
  fontsize: 10.5pt,
  paper: "a4",
  klausur: none,
  doc,
) = {
  if klausur != none {
    return dhbw-klausur-layout(title: title, vorlesung: vorlesung,
      author: author, date: date, logo: logo, lang: lang, paper: paper,
      k: klausur, doc)
  }
  set document(title: title) if title != none
  set text(lang: lang, font: font, size: fontsize)
  set par(justify: false, leading: 0.62em)

  set page(
    paper: paper,
    margin: (left: 2.2cm, right: 2.2cm, top: 2.7cm, bottom: 2.1cm),
    header-ascent: 35%,
    header: {
      grid(
        columns: (1fr, auto),
        align: (left + bottom, right + bottom),
        text(size: 9pt, fill: dhbw-gray, vorlesung),
        if logo != none { image(logo, height: 4.8mm) },
      )
      v(-4pt)
      line(length: 100%, stroke: 0.5pt + luma(200))
    },
    footer: if author != none { text(size: 8.5pt, fill: dhbw-gray, author) },
  )

  // ---- Überschriften: # Teil … rot, ## Aufgabe … grau
  set heading(numbering: none)
  show heading.where(level: 1): it => block(above: 1.35em, below: 0.65em,
    text(size: 13pt, weight: "bold", fill: dhbw-red, it.body))
  show heading.where(level: 2): it => block(above: 1.25em, below: 0.6em,
    text(size: 12pt, weight: "bold", fill: dhbw-gray, it.body))
  show heading.where(level: 3): it => block(above: 1.1em, below: 0.55em,
    text(size: 10.5pt, weight: "bold", it.body))

  // ---- Listen, Code, Tabellen
  set list(marker: text(fill: dhbw-red, sym.bullet), indent: 0.3em)
  set enum(indent: 0.3em)
  show raw: set text(font: ("Consolas", "DejaVu Sans Mono"), size: 0.95em)
  show raw.where(block: true): set block(width: 100%, fill: luma(245),
    inset: (x: 10pt, y: 8pt), radius: 3pt, breakable: false)
  set table(stroke: 0.5pt + luma(170), inset: 5pt)
  show link: set text(fill: dhbw-red)

  // ---- Titel
  if title != none {
    block(below: 1.2em, width: 100%)[
      #text(size: 18pt, weight: "bold", fill: dhbw-gray, title)
      #if subtitle != none {
        v(-0.35em)
        text(size: 12pt, fill: dhbw-lightgray, subtitle)
      }
      #if date != none {
        v(0.2em)
        text(size: 9.5pt, fill: dhbw-gray, date)
      }
    ]
  }

  doc
}
