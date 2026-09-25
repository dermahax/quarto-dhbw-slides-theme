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
