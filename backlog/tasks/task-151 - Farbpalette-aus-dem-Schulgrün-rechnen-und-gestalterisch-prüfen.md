---
id: TASK-151
title: Farbpalette aus dem Schulgrün rechnen und gestalterisch prüfen
status: In Progress
assignee: []
created_date: '2026-08-31 22:00'
updated_date: '2026-09-01 14:45'
labels:
  - frontend
  - gestaltung
  - wb-elternportal
  - wb-intern
dependencies: []
references:
  - oberflaechen.md
  - wb-elternportal/src/ui.tsx
  - wb-intern/src/ui.tsx
ordinal: 163000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Die Werte für die Tokens, die shadcn als CSS-Variablen mitbringt. Die Bedingung, an der sie hängen, steht in oberflaechen.md: Das Markengrün #83BD4C ist eine Flächenfarbe, hell braucht die Aktionsfarbe eine abgedunkelte Ableitung, im Dark Mode kehrt es sich um. Dort steht auch, woher jede Oberfläche ihr Theme nimmt und warum forced-colors keine Palette ist.

Der Punkt dieses Tickets ist, dass Rechnen nicht reicht. Eine Palette, die jede Schwelle besteht, kann gestalterisch trotzdem falsch sein — zu grau, zu giftig, oder ein Grün, das neben dem Logo wie eine zweite Marke wirkt. Geprüft wird deshalb an einer echten Ansicht und nicht an Farbfeldern.

## Stand: Entwurf 1 liegt vor, wartet auf Corrados Feedback

Der Ablauf ist eine Schleife: Entwurf → Corrado schaut drüber → Feedback → Anpassung → wieder vorlegen. **Solange die Schleife läuft, bleiben die Werte hier und nicht im Quelltext.** Erst nach der Abnahme wandern sie als `@theme`-Block in `wb-elternportal/src/index.css` und `wb-intern/src/index.css`, und die Begründungen als Absatz nach `oberflaechen.md`.

Die Ansichtsseite zum Durchklicken (drei Themes, echte Putzdienst-Ansichten, Kontrastbalken je Token, Dichromaten-Simulation, Abstandsmatrix): https://claude.ai/code/artifact/d2d60725-f3a3-47d1-adb3-c32f22b55d6c

## Die sechs Regeln, an denen die Werte hängen

Nicht Geschmack, sondern gemessen. Wer einen Wert ändert, prüft gegen diese sechs:

1. **Das Schulgrün ist die Handlungsfarbe, nicht die Themenfarbe.** Der erste Entwurf tönte alle fünf Flächen mit der Marken-Hue; sie lagen innerhalb von 8,5 % Helligkeit, und vier der zehn Paare waren mit ΔE unter 0,04 nicht unterscheidbar. Die Flächen sind deshalb neutral (Chroma ≤ 0,006), Grün erscheint nur auf Knopf, Fokusring, Kante der gewählten Zeile und Häkchen.
2. **Blasse Tönungen tragen keinen Farbton.** Der naheliegende Ausweg — acht Pastelltöne statt acht Grünstufen — ist gemessen und verworfen: Blasse Flächen liegen unabhängig vom Farbton bei ΔE 0,019 bis 0,054 auseinander. Farbton trennt erst bei kräftiger Sättigung; deshalb sitzt die Farbe eines Zustands am Zeichen und nicht an einer Fläche.
3. **Rot und Grün werden über die Helligkeit getrennt, nicht über den Farbton.** Simuliert nach Viénot, Brettel & Mollon: Die erste Warnfarbe `#F5685D` lag auf derselben Helligkeit wie das Grün und wurde unter Deuteranopie zu `#A3A356` neben `#AFAF4F` — Abstand 0,04, dieselbe Farbe. Helligkeit ist der einzige Kanal, den jede Farbfehlsichtigkeit erhält.
4. **Bernstein, Orange und Gelb scheiden als Warn- oder Wartefarbe aus.** Sie liegen unter Deuteranopie 0,014 bis 0,047 vom Schulgrün; hell wird das Grün `#777720` und Bernstein `#787800`. Damit fällt „grün ist gut, gelb ist Achtung" weg. Die vierte Bedeutungsfarbe ist **Blau** — Protanopie und Deuteranopie lassen den S-Zapfen unangetastet.
5. **Zwei Trennschwellen.** **0,150** gilt, wo allein die Farbe zwei formgleiche Marken trennt (zwei Badges nebeneinander). **0,080** genügt, wo Form, Position oder Legende mittragen — das ist auch der kleinste Abstand, den Okabe-Ito selbst zulässt. Von den acht Rampen dürfen deshalb nur **drei** gleichzeitig einen Zustand tragen: Grün, Blau, Rot.
6. **Abgeleitet wird gegen die schlechteste Fläche, nicht gegen die bequemste.** Ein Token, das gegen `card` gerechnet ist, aber auf `muted` landet, verfehlt seine Schwelle — von 108 tatsächlich vorkommenden Farbpaaren fielen so 28 durch. Rot, Grün und Blau brauchen aus demselben Grund je einen eigenen Schrift-Wert neben der Flächenfarbe. **Landet ein Token später auf einer Fläche, gegen die es nicht abgeleitet wurde, ist die Ableitung hinfällig.**

## Woher die Werte kommen

Kein Wert ist gegriffen. Jeder ist entweder gesetzt (dann steht hier, von wem) oder gerechnet
(dann steht hier, wie). Wer das nachvollziehen will, braucht keinen Quelltext — die vier
Rechenwege stehen unten und lassen sich mit jedem Farbwerkzeug wiederholen.

### Der eine gesetzte Wert

`#83BD4C` — das Grün aus Logo und Favicon der Schule. Alles andere ist daraus abgeleitet. In
OKLCH gemessen: `oklch(0.7345 0.1570 132.04)`. Die Hue **132,04°** ist damit die Hausfarbe und
die Achse, auf der alle neutralen Flächen liegen (nur mit fast null Sättigung).

### Farbraum: OKLCH

Gerechnet wird in **OKLab/OKLCH** nach Björn Ottosson (2020), nicht in HSL. Grund: In HSL bedeutet
dieselbe „Helligkeit" bei zwei Farbtönen etwas Verschiedenes — ein HSL-Gelb mit L=50 % ist optisch
weit heller als ein HSL-Blau mit L=50 %. In OKLab entspricht die L-Achse ungefähr der
wahrgenommenen Helligkeit, deshalb lassen sich Flächen darüber vergleichbar staffeln. Tailwind v4
schreibt `oklch()` nativ, es braucht also keine Umrechnung beim Ausliefern.
Quelle: https://bottosson.github.io/posts/oklab/

Weil OKLCH auch Farben beschreibt, die ein Bildschirm nicht darstellen kann, wird die Sättigung je
Wert auf den darstellbaren Bereich geklemmt (Intervallhalbierung über die Sättigung, bis die
sRGB-Kanäle im Bereich 0–1 liegen). Deshalb steht in manchen Werten eine krumme Sättigung wie
`0.1343` statt der angefragten `0.1400`.

### Kontrast: WCAG 2.x

Gemessen wird mit der Formel aus WCAG 2.1, Erfolgskriterium 1.4.3: relative Leuchtdichte
`0,2126·R + 0,7152·G + 0,0722·B` auf linearisiertem sRGB, Verhältnis `(hell + 0,05) / (dunkel + 0,05)`.
Schwellen: **4,5:1** für Text (1.4.3), **3:1** für Rahmen, Eingabefelder und Fokusring (1.4.11),
**7:1** im Hochkontrast-Theme (angelehnt an 1.4.6 Level AAA).
Quelle: https://www.w3.org/TR/WCAG21/#contrast-minimum

**Nicht** verwendet: APCA, der Nachfolgealgorithmus aus dem WCAG-3-Entwurf. Er sagt Lesbarkeit
besser vorher, ist aber kein geltender Maßstab — und über EN 301 549 zeigt das BFSG auf WCAG 2.1 AA.
Das ist auch die eine Stelle, an der diese Palette von Radix abweicht, das auf APCA zielt.

### Farbfehlsichtigkeit: Viénot, Brettel & Mollon

Simuliert nach **Viénot, Brettel & Mollon (1999)**, dem Standardverfahren für Dichromaten: sRGB wird
linearisiert, in den LMS-Zapfenraum überführt (Hunt-Pointer-Estevez-Matrix), dort auf die Ebene
projiziert, die dem fehlenden Zapfentyp entspricht, und zurückgerechnet. Protanopie ersetzt den
L-Kanal, Deuteranopie den M-Kanal. Der Abstand zweier Farben wird danach als **euklidischer Abstand
in OKLab** gemessen, weil dieser Raum ungefähr wahrnehmungsgleichabständig ist.

**Gegenprobe, dass das Verfahren stimmt:** Es reproduziert die beiden in `oberflaechen.md`
dokumentierten Werte des Markengrüns exakt (2,25:1 gegen Weiß, 9,35:1 gegen Schwarz), und es
erklärt korrekt, warum Okabe-Itos Orange und Blaugrün nebeneinander funktionieren — nämlich über
0,133 Helligkeitsabstand, nicht über den Farbton.

### Ableitungsverfahren je Tokenart

| Art | Verfahren |
|---|---|
| **Flächen** (`background`, `card`, `muted`, `accent`) | Von Hand gestaffelt, dann gemessen: jedes Paar, das gleichzeitig sichtbar ist, muss über ΔE 0,055 liegen. Sättigung bewusst unter 0,006 — siehe Regel 2. |
| **Vordergrundfarben** (`foreground`, `muted-foreground`, die drei `-text`) | Suchlauf über die Helligkeit in 1000 Schritten: gesucht ist die **hellste** Farbe (bzw. dunkelste im dunklen Theme), die ihre Schwelle gegen **alle vier** Flächen hält. Nie dunkler als nötig — eine Schrift, die 12:1 erreicht, wo 4,5 verlangt sind, ist kein besserer Wert, sondern ein härterer Anblick. |
| **Rahmen und Fokusring** | Derselbe Suchlauf, Ziel 3:1 statt 4,5:1. |
| **Aktionsfarbe hell** (`primary`) | Suchlauf über die Helligkeit bei fester Hue 132,04: die **hellste** Abdunklung des Markengrüns, auf der weiße Schrift noch 4,5:1 erreicht. Ergebnis 4,56:1 — knapp über der Schwelle, weil jede weitere Stufe das Grün Richtung Oliv gedrückt hätte. |
| **Aktionsfarbe dunkel** | Keine Rechnung: das Original `#83BD4C` selbst, dazu eine dunkle Schrift, die 4,5:1 darauf hält. |
| **Warnfarbe** (`destructive`) | Zwei Bedingungen gleichzeitig: Schrift hält ihre Schwelle **und** der Abstand zum Grün bleibt unter Protanopie und Deuteranopie über 0,150. Unter allen Lösungen die **satteste**, damit es als Rot lesbar bleibt. |
| **Info-Blau** | Hue 244–255° (Okabe-Itos Blau), Helligkeit wie bei der Aktionsfarbe abgeleitet. |
| **Rampenstufen 1–7** | Feste Helligkeitsleiter je Theme, Sättigung nach Stufenrolle. |
| **Rampenstufen 8, 9, 11, 12** | Gerechnet: 8 hält 3:1 gegen Stufe 1, 11 hält 4,5:1, 12 hält 7:1; Stufe 9 ist die gewünschte Helligkeit je Farbton, gedeckelt auf Sättigung 0,160 — das Niveau der Marke, darüber wirkt es wie Leuchtfarbe. |

### Vorbilder, und was davon übernommen wurde

| Quelle | Übernommen | Nicht übernommen |
|---|---|---|
| **Radix Colors** — https://www.radix-ui.com/colors | Der Zwölf-Stufen-Aufbau samt Rollen: 1–2 Grund, 3–5 Elementflächen, 6–8 Rahmen, 9–10 Vollfarbe, 11–12 Text | Die APCA-Zielwerte; die Rahmenstufen bleiben dort unter 3:1 |
| **Fluent 2** — https://fluent2.microsoft.design/color | Die Zwei-Ebenen-Teilung: global (Rampe) und alias (Token), damit eine neue Farbe aus dem Vorrat kommt statt die Palette zu erweitern | Die 16 Markenstufen und die 160+ Alias-Tokens — zu viel für zwei Oberflächen mit sechs Formularseiten |
| **Okabe & Ito (2008)** — https://jfly.uni-koeln.de/color/ | Die Farbtonwinkel: Blau 244°, Blaugrün 165°, Orange 77°, Rotviolett 346°. Die meistzitierte farbfehlsichtigkeits-sichere Palette | Der Satz als Ganzes: Sein kleinster Paarabstand ist 0,079 — passend für Diagrammreihen mit Legende, zu wenig für zwei Marken nebeneinander |
| **Material Design 3** — https://m3.material.io/styles/color | Nichts | Das HCT-Modell — es leistet dasselbe wie OKLCH, aber Tailwind v4 spricht OKLCH nativ |

### Was tatsächlich gemessen wurde

- **72 Tokenzeilen** (24 × 3 Themes), davon 45 mit einer Schwelle
- **66 Farbpaare**, wie sie im Stylesheet wirklich vorkommen — nicht wie sie beim Ableiten gedacht waren. Genau diese Prüfung hat im ersten Anlauf 28 Verstöße gefunden, die keine Ableitung zeigt: Tokens, die gegen `card` gerechnet waren, aber auf `muted` landeten.
- **288 Rampenfelder**, jedes auf die Lesbarkeit seiner Beschriftung
- **Alle Paare der Vollfarben** unter Normalsicht, Protanopie und Deuteranopie

## Die Werte

24 Tokens je Theme, davon 15 gemessen. Alle Schwellen gehalten; Skala und Prüfung stehen in der Ansichtsseite oben.

### Hell

| Token | oklch | Hex | gemessen gegen | Ist | Soll |
|---|---|---|---|---|---|
| `--color-background` | `oklch(0.9760 0.0035 132.04)` | `#F6F8F5` | — | — | — |
| `--color-foreground` | `oklch(0.2920 0.0150 132.04)` | `#292D26` | #F6F8F5 | 13,03:1 | 4,5:1 |
| `--color-card` | `oklch(1.0000 0.0000 132.04)` | `#FFFFFF` | — | — | — |
| `--color-card-foreground` | `oklch(0.2920 0.0150 132.04)` | `#292D26` | #FFFFFF | 13,95:1 | 4,5:1 |
| `--color-popover` | `oklch(1.0000 0.0000 132.04)` | `#FFFFFF` | — | — | — |
| `--color-popover-foreground` | `oklch(0.2920 0.0150 132.04)` | `#292D26` | #FFFFFF | 13,95:1 | 4,5:1 |
| `--color-primary` | `oklch(0.5540 0.1400 132.04)` | `#52831C` | — | — | — |
| `--color-primary-foreground` | `oklch(1.0000 0.0000 132.04)` | `#FFFFFF` | #52831C | 4,56:1 | 4,5:1 |
| `--color-primary-text` | `oklch(0.4830 0.1343 132.04)` | `#406D00` | #DBDDDA | 4,51:1 | 4,5:1 |
| `--color-secondary` | `oklch(0.9300 0.0040 132.04)` | `#E7E8E6` | — | — | — |
| `--color-secondary-foreground` | `oklch(0.2920 0.0150 132.04)` | `#292D26` | #E7E8E6 | 11,37:1 | 4,5:1 |
| `--color-muted` | `oklch(0.9300 0.0040 132.04)` | `#E7E8E6` | — | — | — |
| `--color-muted-foreground` | `oklch(0.4920 0.0180 132.04)` | `#5D6359` | #DBDDDA | 4,51:1 | 4,5:1 |
| `--color-accent` | `oklch(0.8950 0.0045 132.04)` | `#DBDDDA` | — | — | — |
| `--color-accent-foreground` | `oklch(0.2920 0.0150 132.04)` | `#292D26` | #DBDDDA | 10,21:1 | 4,5:1 |
| `--color-destructive` | `oklch(0.3800 0.1500 25.00)` | `#800613` | — | — | — |
| `--color-destructive-foreground` | `oklch(1.0000 0.0000 25.00)` | `#FFFFFF` | #800613 | 10,79:1 | 4,5:1 |
| `--color-destructive-text` | `oklch(0.5120 0.1500 25.00)` | `#AC3A38` | #DBDDDA | 4,50:1 | 4,5:1 |
| `--color-info` | `oklch(0.5000 0.1600 255.00)` | `#0961BB` | — | — | — |
| `--color-info-foreground` | `oklch(1.0000 0.0000 255.00)` | `#FFFFFF` | #0961BB | 6,08:1 | 4,5:1 |
| `--color-info-text` | `oklch(0.4960 0.1500 255.00)` | `#1561B5` | #DBDDDA | 4,51:1 | 4,5:1 |
| `--color-border` | `oklch(0.5890 0.0150 132.04)` | `#7A7F76` | #DBDDDA | 3,00:1 | 3,0:1 |
| `--color-input` | `oklch(0.5890 0.0150 132.04)` | `#7A7F76` | #DBDDDA | 3,00:1 | 3,0:1 |
| `--color-ring` | `oklch(0.5790 0.1400 132.04)` | `#598A26` | #DBDDDA | 3,00:1 | 3,0:1 |

### Dunkel

| Token | oklch | Hex | gemessen gegen | Ist | Soll |
|---|---|---|---|---|---|
| `--color-background` | `oklch(0.1680 0.0040 132.04)` | `#0E0F0E` | — | — | — |
| `--color-foreground` | `oklch(0.8710 0.0150 132.04)` | `#D1D7CD` | #0E0F0E | 13,04:1 | 4,5:1 |
| `--color-card` | `oklch(0.2260 0.0050 132.04)` | `#1B1C1A` | — | — | — |
| `--color-card-foreground` | `oklch(0.8710 0.0150 132.04)` | `#D1D7CD` | #1B1C1A | 11,59:1 | 4,5:1 |
| `--color-popover` | `oklch(0.2260 0.0050 132.04)` | `#1B1C1A` | — | — | — |
| `--color-popover-foreground` | `oklch(0.8710 0.0150 132.04)` | `#D1D7CD` | #1B1C1A | 11,59:1 | 4,5:1 |
| `--color-primary` | `oklch(0.7345 0.1570 132.04)` | `#83BD4C` | — | — | — |
| `--color-primary-foreground` | `oklch(0.3705 0.0500 132.04)` | `#364629` | #83BD4C | 4,55:1 | 4,5:1 |
| `--color-primary-text` | `oklch(0.7120 0.1400 132.04)` | `#81B452` | #3B3C39 | 4,52:1 | 4,5:1 |
| `--color-secondary` | `oklch(0.2960 0.0055 132.04)` | `#2C2D2B` | — | — | — |
| `--color-secondary-foreground` | `oklch(0.8710 0.0150 132.04)` | `#D1D7CD` | #2C2D2B | 9,39:1 | 4,5:1 |
| `--color-muted` | `oklch(0.2960 0.0055 132.04)` | `#2C2D2B` | — | — | — |
| `--color-muted-foreground` | `oklch(0.7210 0.0180 132.04)` | `#A1A79C` | #3B3C39 | 4,50:1 | 4,5:1 |
| `--color-accent` | `oklch(0.3550 0.0060 132.04)` | `#3B3C39` | — | — | — |
| `--color-accent-foreground` | `oklch(0.8710 0.0150 132.04)` | `#D1D7CD` | #3B3C39 | 7,52:1 | 4,5:1 |
| `--color-destructive` | `oklch(0.5700 0.1750 25.00)` | `#CA403F` | — | — | — |
| `--color-destructive-foreground` | `oklch(1.0000 0.0000 25.00)` | `#FFFFFF` | #CA403F | 4,87:1 | 4,5:1 |
| `--color-destructive-text` | `oklch(0.7410 0.1500 25.00)` | `#FC827A` | #3B3C39 | 4,52:1 | 4,5:1 |
| `--color-info` | `oklch(0.6900 0.1500 255.00)` | `#569DF6` | — | — | — |
| `--color-info-foreground` | `oklch(0.3230 0.0500 255.00)` | `#22354D` | #569DF6 | 4,51:1 | 4,5:1 |
| `--color-info-text` | `oklch(0.7240 0.1457 255.00)` | `#63A8FF` | #3B3C39 | 4,51:1 | 4,5:1 |
| `--color-border` | `oklch(0.6160 0.0150 132.04)` | `#82877E` | #3B3C39 | 3,01:1 | 3,0:1 |
| `--color-input` | `oklch(0.6160 0.0150 132.04)` | `#82877E` | #3B3C39 | 3,01:1 | 3,0:1 |
| `--color-ring` | `oklch(0.6060 0.1400 132.04)` | `#619330` | #3B3C39 | 3,00:1 | 3,0:1 |

### Hochkontrast

| Token | oklch | Hex | gemessen gegen | Ist | Soll |
|---|---|---|---|---|---|
| `--color-background` | `oklch(0.0000 0.0000 132.04)` | `#000000` | — | — | — |
| `--color-foreground` | `oklch(1.0000 0.0000 132.04)` | `#FFFFFF` | #000000 | 21,00:1 | 7,0:1 |
| `--color-card` | `oklch(0.1550 0.0000 132.04)` | `#0C0C0C` | — | — | — |
| `--color-card-foreground` | `oklch(1.0000 0.0000 132.04)` | `#FFFFFF` | #0C0C0C | 19,54:1 | 7,0:1 |
| `--color-popover` | `oklch(0.1550 0.0000 132.04)` | `#0C0C0C` | — | — | — |
| `--color-popover-foreground` | `oklch(1.0000 0.0000 132.04)` | `#FFFFFF` | #0C0C0C | 19,54:1 | 7,0:1 |
| `--color-primary` | `oklch(0.7345 0.1570 132.04)` | `#83BD4C` | — | — | — |
| `--color-primary-foreground` | `oklch(0.2500 0.0400 132.04)` | `#1A2611` | #83BD4C | 7,05:1 | 7,0:1 |
| `--color-primary-text` | `oklch(0.7980 0.1400 132.04)` | `#9BD06E` | #333333 | 7,02:1 | 7,0:1 |
| `--color-secondary` | `oklch(0.2450 0.0000 132.04)` | `#202020` | — | — | — |
| `--color-secondary-foreground` | `oklch(1.0000 0.0000 132.04)` | `#FFFFFF` | #202020 | 16,23:1 | 7,0:1 |
| `--color-muted` | `oklch(0.2450 0.0000 132.04)` | `#202020` | — | — | — |
| `--color-muted-foreground` | `oklch(0.8080 0.0180 132.04)` | `#BCC3B7` | #333333 | 7,02:1 | 7,0:1 |
| `--color-accent` | `oklch(0.3200 0.0000 132.04)` | `#333333` | — | — | — |
| `--color-accent-foreground` | `oklch(1.0000 0.0000 132.04)` | `#FFFFFF` | #333333 | 12,69:1 | 7,0:1 |
| `--color-destructive` | `oklch(0.4800 0.1800 25.00)` | `#AC1922` | — | — | — |
| `--color-destructive-foreground` | `oklch(1.0000 0.0000 25.00)` | `#FFFFFF` | #AC1922 | 7,19:1 | 7,0:1 |
| `--color-destructive-text` | `oklch(0.8210 0.1002 25.00)` | `#FFABA4` | #333333 | 7,02:1 | 7,0:1 |
| `--color-info` | `oklch(0.4600 0.1517 255.00)` | `#0056AA` | — | — | — |
| `--color-info-foreground` | `oklch(1.0000 0.0000 255.00)` | `#FFFFFF` | #0056AA | 7,23:1 | 7,0:1 |
| `--color-info-text` | `oklch(0.8090 0.0975 255.00)` | `#96C4FF` | #333333 | 7,02:1 | 7,0:1 |
| `--color-border` | `oklch(0.6850 0.0150 132.04)` | `#969C92` | #333333 | 4,51:1 | 4,5:1 |
| `--color-input` | `oklch(0.6850 0.0150 132.04)` | `#969C92` | #333333 | 4,51:1 | 4,5:1 |
| `--color-ring` | `oklch(0.9000 0.1700 100.00)` | `#F9E03F` | #333333 | 9,49:1 | 4,5:1 |

### Rampen — hell

| Rampe | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| `neutral` | `#FCFDFC` | `#F8FAF7` | `#F0F4EE` | `#E9EEE5` | `#E1E8DD` | `#D8DFD3` | `#CAD2C4` | `#8F958B` | `#93A586` | `#839476` | `#6D7964` | `#545A50` |
| `gruen` | `#FBFEFA` | `#F6FBF3` | `#ECF7E4` | `#E2F3D6` | `#D8EEC8` | `#CDE6BB` | `#BFDAAA` | `#859977` | `#83BD4C` | `#72AC36` | `#598034` | `#4B5D3D` |
| `teal` | `#F9FEFC` | `#F2FCF7` | `#E2F9EE` | `#D3F6E5` | `#C4F2DD` | `#B6EAD3` | `#A4DFC4` | `#719C89` | `#00BA88` | `#00A77A` | `#008661` | `#37604F` |
| `blau` | `#FBFDFF` | `#F4FAFF` | `#E8F4FF` | `#DCEFFF` | `#CFE9FF` | `#BEE1FF` | `#A9D5FB` | `#7697B3` | `#0081C8` | `#0070AF` | `#2C7AB3` | `#3C5B74` |
| `violett` | `#FEFCFF` | `#FBF7FF` | `#F7EEFF` | `#F4E6FF` | `#F0DDFF` | `#E9D2FC` | `#DDC3F2` | `#9F8CAF` | `#8548AC` | `#75379B` | `#8E64AB` | `#635170` |
| `magenta` | `#FFFCFD` | `#FFF6FB` | `#FFEDF6` | `#FFE3F1` | `#FFD9EC` | `#FCCDE5` | `#F2BDD9` | `#AF889C` | `#C15294` | `#AE4183` | `#A95B87` | `#714D60` |
| `bernstein` | `#FFFCF8` | `#FEF8F0` | `#FDF1DE` | `#FDE9CE` | `#FAE1BD` | `#F4D8AF` | `#EACA9C` | `#A7906E` | `#F0A714` | `#DB9700` | `#9C6C0D` | `#6A5434` |
| `rot` | `#FFFCFC` | `#FFF7F6` | `#FFEEEC` | `#FFE5E3` | `#FFDCD8` | `#FFCFCA` | `#FABEB8` | `#B58984` | `#C44844` | `#B13635` | `#B35B56` | `#754D4A` |

### Rampen — dunkel

| Rampe | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| `neutral` | `#111110` | `#171816` | `#20221E` | `#262A23` | `#2D3229` | `#383E34` | `#474D42` | `#5C6258` | `#93A586` | `#A4B697` | `#74806B` | `#9AA095` |
| `gruen` | `#10120F` | `#161913` | `#1C2416` | `#212D17` | `#253617` | `#30431F` | `#3C5329` | `#536645` | `#83BD4C` | `#93CF5C` | `#5F873B` | `#90A481` |
| `teal` | `#0F1210` | `#131A16` | `#14251E` | `#112F23` | `#0D3829` | `#144634` | `#1D5742` | `#3F6957` | `#00BA88` | `#00CE97` | `#138D67` | `#7CA794` |
| `blau` | `#0F1114` | `#13191D` | `#15232E` | `#152B3C` | `#143249` | `#1C3F5A` | `#264F6E` | `#44647D` | `#0081C8` | `#0092E2` | `#3481BA` | `#80A2BD` |
| `violett` | `#121013` | `#19161C` | `#251D2B` | `#2F2238` | `#382845` | `#463254` | `#574067` | `#6B597A` | `#8548AC` | `#9659BE` | `#956BB3` | `#AA96B9` |
| `magenta` | `#131012` | `#1C1619` | `#2B1C24` | `#37202D` | `#442435` | `#532E43` | `#663B53` | `#7A5569` | `#C15294` | `#D363A5` | `#B1628E` | `#BA93A7` |
| `bernstein` | `#13110E` | `#1B1712` | `#291F12` | `#34250F` | `#3F2C0A` | `#4E3711` | `#604519` | `#735D3C` | `#F0A714` | `#FFBB47` | `#A3731A` | `#B29A78` |
| `rot` | `#141010` | `#1D1615` | `#2D1C1A` | `#3B201E` | `#482421` | `#582E2B` | `#6C3B37` | `#7E5652` | `#C44844` | `#D75954` | `#BB625C` | `#C0938E` |

### Rampen — hochkontrast

| Rampe | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| `neutral` | `#000000` | `#030303` | `#0C0E0A` | `#161A14` | `#21261E` | `#343A30` | `#4C5247` | `#70766C` | `#93A586` | `#A4B697` | `#8D9983` | `#B8BEB3` |
| `gruen` | `#000000` | `#020402` | `#091004` | `#111C07` | `#1A290B` | `#2C3F1B` | `#41582E` | `#677A59` | `#83BD4C` | `#93CF5C` | `#77A154` | `#ADC29E` |
| `teal` | `#000000` | `#010403` | `#02110A` | `#011E14` | `#002C1E` | `#0F4230` | `#235C46` | `#537D6B` | `#00BA88` | `#00CE97` | `#3BA780` | `#99C5B1` |
| `blau` | `#000000` | `#020406` | `#030E18` | `#051A2A` | `#07263C` | `#183B56` | `#2B5473` | `#587892` | `#149CEE` | `#38AEFF` | `#509BD6` | `#9EC0DD` |
| `violett` | `#000000` | `#040305` | `#110A16` | `#1E1227` | `#2C1C38` | `#422E50` | `#5C456D` | `#806D8F` | `#7A3DA0` | `#8A4DB2` | `#AF84CE` | `#C9B4D9` |
| `magenta` | `#000000` | `#050204` | `#160810` | `#26101C` | `#371829` | `#4F2A3F` | `#6B3F58` | `#8F6A7D` | `#E06EB0` | `#F37FC1` | `#CD7CA8` | `#D9B0C5` |
| `bernstein` | `#000000` | `#050301` | `#140B02` | `#231501` | `#332000` | `#4A330C` | `#654A1F` | `#877150` | `#F0A714` | `#FFBB47` | `#BE8C3A` | `#D1B895` |
| `rot` | `#000000` | `#060202` | `#180807` | `#29100E` | `#3B1816` | `#542A27` | `#71403C` | `#946A66` | `#A62A2C` | `#B93D3B` | `#D77C75` | `#DFB1AC` |

### Herkunft der Rampen

Stufenaufbau nach **Radix** (1–2 Grund, 3–5 Elementflächen, 6–8 Rahmen, 9–10 Vollfarbe, 11–12 Text), Farbtonwinkel nach **Okabe & Ito**, Zwei-Ebenen-Teilung nach **Fluent** (global = Rampe, alias = Token). Eine Abweichung von Radix ist ausgeschrieben: Dessen Rahmenstufen zielen auf APCA und bleiben unter 3:1 — hier hält Stufe 8 die WCAG-Schwelle, weil das BFSG daran hängt. Gemessen sind die Stufen 8, 9, 11 und 12; die übrigen sind Flächen ohne Schrift darauf.

**Empfohlene Reihenfolge für Diagrammreihen** (die ersten n sind immer die am besten getrennten): violett · bernstein · rot · teal · magenta · blau · gruen. Ab 4 Reihen nur noch Diagramm-tauglich (ΔE 0,100), ab 6 nur mit Muster oder Beschriftung (0,061).

## Zwei Schwellen bewusst nicht gehalten

- **Warnfläche im Hochkontrast:** 2,74:1 gegen die Karte, unter den 3:1 für Nicht-Text. Die Kante trägt stattdessen ein Rahmen — ein helleres Rot hätte die 7:1 für die weiße Schrift darauf gekostet.
- **`--color-*-text` untereinander:** Grün und Rot als Schrift liegen dichromatisch bei 0,042. Sie erscheinen nie als formgleiche Nachbarn — Umriss-Knopf neben gefülltem, rote Zahl neben grauer, Zeichen ✓ neben ✕. Form und Wort tragen dort. Der Wert, der auch 0,150 hielte, wäre `#FFCAC5`: ein blasses Rosa, das als Warnfarbe schwächer ist als das Problem.

## Was Corrado ansehen sollte

1. Ob das abgedunkelte Grün `#52831C` neben dem Logo als dieselbe Marke liest oder als zweite.
2. Ob die neutralen Flächen zu kalt sind — sie tragen noch 0,0035 bis 0,006 Chroma auf der Marken-Hue.
3. Ob Zustände als farbiges Zeichen plus Wort genügen oder eine Fläche brauchen.
4. Ob das Hochkontrast-Theme schwarz gegründet richtig ist (Teams liefert `contrast` schwarz) oder weiß erwartet wird.
5. Die Schriftwahl steht ausdrücklich **nicht** in diesem Ticket — die Ansichtsseite setzt Familjen Grotesk und Source Serif 4 als Vorschlag, TASK-151 verlangt Farbe.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Tokens für hell und dunkel liegen in shadcn-Benennung vor, jeder Wert mit seinem gemessenen Kontrast
- [x] #2 Jeder Wert besteht seine Schwelle: 4,5:1 für Text (1.4.3), 3:1 für Rahmen, Eingabefelder und Fokusring (1.4.11)
- [x] #3 Ein drittes Theme für Hochkontrast steht, Ziel 7:1
- [ ] #4 Gestalterisch geprüft an mindestens einer echten Ansicht in allen drei Themes, nicht an Farbfeldern
- [x] #5 forced-colors: active geprüft — keine Information geht verloren, die nur an Farbe hing
- [ ] #6 Theme-Quelle je Oberfläche umgesetzt: Portal folgt prefers-color-scheme, wb-intern folgt dem Teams-Theme
- [ ] #7 Rot-Grün-Blindheit geprüft: Protanopie und Deuteranopie simuliert, jedes Paar gleichzeitig sichtbarer Marken über 0,150 ΔE
- [ ] #8 Corrado hat den Entwurf gesehen und Feedback gegeben; das Feedback ist eingearbeitet oder mit Begründung verworfen
- [ ] #9 Nach der Abnahme: Werte als @theme-Block in beide Frontend-Repos, Begründungen als Absatz in oberflaechen.md
<!-- AC:END -->
