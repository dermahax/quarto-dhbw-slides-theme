#show: doc => dhbw-uebung(
$if(title)$
  title: [$title$],
$endif$
$if(subtitle)$
  subtitle: [$subtitle$],
$endif$
$if(date)$
  date: [$date$],
$endif$
$if(dhbw.vorlesung)$
  vorlesung: [$dhbw.vorlesung$],
$endif$
$if(dhbw.author)$
  author: [$dhbw.author$],
$elseif(by-author)$
  author: [$for(by-author)$$it.name.literal$$sep$, $endfor$],
$endif$
$if(dhbw-logo)$
  logo: "$dhbw-logo$",
$endif$
$if(loesung)$
  loesung: true,
$endif$
$if(klausur)$
  klausur: (
    modus: true,
$if(klausur.lehrveranstaltung)$
    lehrveranstaltung: [$klausur.lehrveranstaltung$],
$endif$
$if(klausur.kurs)$
    kurs: [$klausur.kurs$],
$endif$
$if(klausur.datum)$
    datum: [$klausur.datum$],
$endif$
$if(klausur.dozent)$
    dozent: [$klausur.dozent$],
$endif$
$if(klausur.dauer)$
    dauer: [$klausur.dauer$],
$endif$
$if(klausur.hilfsmittel)$
    hilfsmittel: [$klausur.hilfsmittel$],
$endif$
$if(klausur.punkte)$
    punkte: [$klausur.punkte$],
$elseif(klausur-summe)$
    punkte: [$klausur-summe$],
$endif$
$if(klausur.studienzentrum)$
    studienzentrum: [$klausur.studienzentrum$],
$endif$
$if(dhbw-logo-klausur)$
    logo: "$dhbw-logo-klausur$",
$endif$
  ),
$endif$
$if(lang)$
  lang: "$lang$",
$endif$
$if(mainfont)$
  font: ("$mainfont$",),
$endif$
$if(fontsize)$
  fontsize: $fontsize$,
$endif$
$if(papersize)$
  paper: "$papersize$",
$endif$
  doc,
)
