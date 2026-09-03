---
id: TASK-161
title: Unterrichtsgruppen als zweite Achse der Sichtbarkeit
status: In Progress
assignee: []
created_date: '2026-09-01 17:19'
updated_date: '2026-09-03 19:40'
labels:
  - schema
  - wb-docs
  - gesundheit
  - wartet
dependencies: []
references:
  - schema/klassenorganisation-schema.sql
  - schema/stammdaten-schema.sql
  - grenzkarte.md
  - pruefberichte/gespraech-geschaeftsfuehrung.md
ordinal: 173000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Der Sichtkreis sagt, welche Angaben jemand sehen darf. Er sagt nicht, von welchen Kindern — und die Sportlehrkraft unterrichtet nicht alle 500. Heute gibt es dafür nur `children.class_id`, also die Stammklasse, und `classes.class_teacher_id`, also genau eine Lehrkraft je Klasse.

Bestätigt am 03.09.2026: Gesundheitsangaben sehen **nur die Lehrkräfte, die dieses Kind unterrichten**. Getragen wird das von zwei Zuordnungen, weil es zwei Formen von Kindermenge gibt:

```
unterrichtet_klasse (employee_id, class_id, school_year)
elective_groups     (elective_group_id, label, elective_module_id,
                     school_branch_id, cohort_start_year, employee_id)
children.elective_group_id  →  elective_groups
```

**Die Wahlmodulgruppe bekommt eine eigene Kennung** — nicht weil sie eine hätte, sondern weil sie eine bekommt, sobald sie sich teilt. Heute gibt es je Modul und Jahrgang genau eine; wächst die Schule, gibt es „Technik 7 · A" und „Technik 7 · B" mit verschiedenen Lehrkräften und je einem Teil des Jahrgangs. Eine Zuordnung über `(Modul, Jahrgang)` könnte die beiden nicht auseinanderhalten, eine über die Klasse zerschnitte eine Gruppe, die es als Ganzes gibt.

**Eine Mitgliederliste entsteht dabei trotzdem nicht.** Das Kind zeigt mit **einem Feld** auf seine Gruppe, so wie es vorher auf das Modul gezeigt hätte — derselbe Pflegeaufwand, dieselbe einmalige Handlung bei der Wahl. Die frühere Ablehnung galt der Verbindungstabelle mit zwei Wahrheiten, nicht der Gruppe als solcher.

Der Gewinn ist ein einfacherer Join: Die Gruppe kennt ihre Lehrkraft, also lautet die Regel „die Gruppe meines Kindes nennt mich" — statt Modul, Kohorte und Klasse des Kindes zusammenzuführen. Die Kohorte steht trotzdem an der Gruppe, damit beim Eintragen die richtigen Gruppen zur Auswahl stehen und eine noch leere Gruppe ein Zuhause hat.

**Die Oberfläche zeigt die Gruppe erst, wenn es zwei gibt** (03.09.2026). Solange je Modul und Kohorte genau eine existiert, wählt man bei der Anmeldung das **Modul** — die Gruppe entsteht dabei von selbst und braucht als einzige Pflichtangabe ihre Lehrkraft, denn an ihr hängt die Sichtbarkeit. Erst wenn jemand eine zweite anlegt, erscheint überhaupt eine Auswahl. Das Modell trägt beides von Anfang an; sichtbar wird die Teilung erst, wenn es sie gibt.

**Das Teilen ist eine bewusste Handlung, kein Automatismus:** Entsteht die zweite Gruppe, muss jemand sagen, welche Kinder hinübergehen — raten kann das System es nicht, und stillschweigend alle in der ersten zu lassen wäre falsch.

**Kein Schuljahr an der Gruppe:** Sie lebt so lange wie die Kohorte, denn das Modul wird einmal gewählt und bis zum Abgang behalten. Wechselt die Lehrkraft, ändert sich die Spalte — wer im Vorjahr unterrichtet hat, führt das Modell bewusst nicht (siehe unten). **Und genau eine Lehrkraft je Gruppe**; zwei wären eine Verbindungstabelle, und dafür liegt kein Fall vor.

**Sichtbarkeit rechnet über beide Zuordnungen zusammen, eine Liste je Zeile.** Wer in der 7a Mathematik unterrichtet und daneben eine Technikgruppe, sieht die ganze 7a und dazu die Kinder seiner Gruppe aus der 7b — bekommt aber „7a" und „Technik 7 · A" als getrennte Listen. Ohne diese Trennung müsste er seine Techniker aus zwei Klassenlisten heraussuchen oder raten.

**Die Klasse ist die Einheit, auch wo sie zu grob ist** — die eine Stelle, an der das Modell mehr zeigt, als die Regel wörtlich verlangt. Deutsch und Mathematik zerfallen in der Grundschule in mehrere Zeilen (Kernfach, Erzählkreis, Plus, Förder/Vertiefung), und der **Förderunterricht geht an eine Teilmenge der Klasse**: Über die Klassenzuordnung sähe die Förderlehrkraft die Angaben aller rund siebenundzwanzig Kinder der 2a, obwohl sie fünf fördert. Drei Wege standen offen:

- **A — die Klasse ist die Einheit.** Keine Liste, die jemand pflegen muss; der weitere Kreis bleibt innerhalb *einer* Klasse, deren Kinder dieselbe Lehrkraft ohnehin täglich vor sich hat; ein Kind, das neu in Förderung kommt, ist sofort sichtbar. Dagegen: zeigt mehr als die Regel wörtlich verlangt, und das ist zu begründen statt abzuleiten. **Fehlerrichtung:** Es sieht jemand ein Kind, das er ohnehin unterrichtet — nicht ein fremdes.
- **B — die Fördergruppe wird geführt.** Trifft die Regel wörtlich, kleinstmöglicher Kreis. Dagegen: genau die Mitgliederliste in ihrer schlechtesten Form, denn wer Förderung bekommt, wechselt unterjährig; zweiter Ort für dieselbe Tatsache; Pflegeaufwand ohne festen Anlass. **Fehlerrichtung:** Eine veraltete Liste blendet ein Kind aus, das gerade gefördert wird — im Zweifel das mit der Allergie.
- **C — Förderunterricht zählt nicht.** Nichts zu bauen. Dagegen: Die Förderlehrkraft ist mit einem Kind allein im Raum und weiß nichts von seinem Notfallmedikament; die Notfalltaste würde vom Netz zum Alltagsweg, und jede Betätigung geht an die Geschäftsführung. **Fehlerrichtung:** Im Ernstfall fehlt die Information genau der Person, die daneben steht.

**Gewählt ist A, wegen der Fehlerrichtung und nicht wegen des Aufwands.** Datenschutz misst sich nicht allein daran, wie eng ein Kreis ist, sondern auch daran, ob die Angabe die Person erreicht, die handeln muss. B kauft fünfundzwanzig Kinder weniger Sichtbarkeit mit dem Risiko, dass die Angabe im entscheidenden Moment fehlt — und mit einer Liste, die niemandem gehört. Die Begründung ist gegenüber dem Datenschutzbeauftragten mitzuliefern, sobald das Freigabemodell ohnehin auf dem Tisch liegt (TASK-205): Der weitere Kreis bleibt innerhalb einer Klasse und ist etwas anderes als der heutige Zustand, in dem jede Fachlehrkraft auf alle rund fünfhundert Kinder sieht.

**Die Entscheidung für A ist umkehrbar, und das gehört zu ihrer Begründung.** Die Gruppe trägt Schulart und Kohorte, ist also nicht realschulspezifisch: Müsste aus A doch B werden, wäre das kein neues Modell, sondern eine Grundschulgruppe „Förder Deutsch · Kohorte 2024" mit ihrer Lehrkraft, und die Förderlehrkraft sähe ihre fünf statt der ganzen Klasse.

**Deshalb eine Zuordnungstabelle statt eines Feldes am Kind** (03.09.2026, nach der Feststellung, dass ein förderbedürftiges Kind in aller Regel in Deutsch *und* Mathematik gefördert wird). Ein Feld trägt genau eine Gruppe; das passt für die Realschule, wo ein Wahlpflichtfach gewählt wird, und es wäre in der Grundschule vom ersten Tag an zu eng, sobald aus A doch B würde. Die Ein-Gruppen-Grenze ist damit kein Randfall, sondern der Normalfall.

```
child_group_memberships (child_id, elective_group_id)
```

**Für die Pflege ändert das nichts**, und darauf kam der Einwand gegen eine Mitgliederliste ursprünglich an: Man wählt bei der Anmeldung eine Gruppe, ob das Ergebnis eine Spalte oder eine Zeile ist, merkt niemand. Was die Tabelle dafür trägt: heute genau eine Gruppe je Kind, morgen zwei, ohne Umstellung — und alles, was die Grundschule sonst noch quer zur Klasse führt, Chor und dergleichen, ohne dass dafür ein zweiter Mechanismus entsteht. Das ist der Fall, für den `CLAUDE.md` die Schema-Ausnahme ausschreibt: Eine Lücke kostet dort einen Abnahmezyklus, ein Mechanismus nur Code.

**Die Alternative samt Preis, damit sie nicht neu erfunden wird:** ein Feld `children.elective_group_id` wäre eine Spalte weniger und derselbe Join. Der Preis ist, dass ein Wechsel auf B — die eigene Fördergruppe statt der ganzen Klasse — dann keine Wahl mehr ist, sondern eine Umstellung von Spalte auf Tabelle samt Policy und Oberfläche, mitten in einer laufenden Domäne.

**Für die Wahlmodulgruppe gilt dieses Argument ausdrücklich nicht** — dort deckt nichts den weiteren Kreis, weil die übrigen Kinder der Lehrkraft nie begegnen. Deshalb die eigene Gruppe statt einer Zuordnung über das Modul.

**Ein Fach wird dabei nicht gebraucht.** Für die Frage „wer darf welches Kind sehen" trägt allein das Paar Lehrkraft ↔ Kindermenge; die Fächerlisten aus dem Papier bleiben Dokumentation und werden keine Werteliste.

**Bewusst keine Gruppe mit Mitgliederliste** (03.09.2026). Sie verhält sich wie eine Klasse — feste Kinder, eine Lehrkraft, über Jahre stabil —, aber sie hat in der Wirklichkeit **keine eigene Kennung**: Niemand nennt sie beim Namen, niemand führt eine Liste. Erfänden wir eine, pflegten wir zwei Orte für dieselbe Tatsache, und die Mitgliederliste liefe gegen das Kind auseinander. Ebenso keine `classes`-Zeile: An ihr hängt, was für ein Wahlmodul falsch wäre — die Kohorten-Kennung, an der M365-Gruppe und Mailverteiler hängen, die Elternvertretung je Klasse und die Klassenleitung als Pflichtangabe.

**Das Fach kommt hier durch die Hintertür zurück, und das ist richtig so:** Die drei Wahlmodule sind eine Werteliste mit drei Zeilen, weil sie hier die Sichtbarkeit tragen. Die siebzehn Fächer der Realschule und die dreizehn der Grundschule werden es deshalb nicht — sie tragen nichts.

**Die Ladereihenfolge entscheidet, wo was liegt.** `children` steht in `stammdaten`, und das lädt zuerst — eine Spalte am Kind kann also nicht auf eine Tabelle zeigen, die erst in `klassenorganisation` entsteht. Daraus folgt der Schnitt: Die **Werteliste der Wahlmodule gehört zu `stammdaten`**, neben die übrigen Wertelisten dort, und mit ihr die Lehrkraft am Modul (`employees` steht ohnehin dort). Die **Zuordnung Lehrkraft ↔ Klasse je Schuljahr gehört zu `klassenorganisation`** — sie zeigt nur auf `classes` und `employees` und bricht die Reihenfolge nicht.

**Die Gruppe ist es, die den Kreis eng hält.** Hinge die Lehrkraft am Modul, sähe sie alle Technik-Kinder der Schule — bei drei Modulen über vier Jahrgänge achtzig statt der fünfzehn, die sie unterrichtet, und die anderen begegnen ihr nie. Das Argument, mit dem die Klasse als Einheit begründet ist, trägt dort ausdrücklich **nicht**: Es gilt nur, wo die weiteren Kinder dieselben sind, die dieselbe Lehrkraft ohnehin täglich vor sich hat.

**Die Pflege muss den Umweg unmöglich machen.** Wer die Zuordnung von Hand pflegt, greift sonst zum naheliegenden Werkzeug und trägt die Wahlmodul-Lehrkraft als Unterrichtende der Herkunftsklassen ein — womit sie wieder ganze Klassen sähe. Die Oberfläche bietet ihr deshalb keine Klassenzeile an, und das Prüfskript hält fest: Eine Lehrkraft, die nur ein Wahlmodul unterrichtet, hat keine Klassenzuordnung.

**Und die vier Quellen werden abgefragt, nicht neu gespeichert.** Für AG bzw. Akademie-Angebot und für die Begleitung einer Veranstaltung gibt es die Kindermenge schon — die Anmeldung dort ist sie. Eine übergeordnete Tabelle „Kindermenge" wäre eine zweite Wahrheit neben ihnen. Neu entstehen deshalb nur die zwei oben.

**Kein Verlauf, wer wann unterrichtet hat.** Die Sichtbarkeit fragt nach dem Jetzt; ein Lehrerwechsel überschreibt. Wer die Geschichte will, liest die Änderungsspur.

**Woher der Zuschnitt stammt** (Teams-Chat und Deputatsverteilung 2026/27, ausgewertet am 03.09.2026) — hier festgehalten, weil das Arbeitspapier verschwindet und die Herkunft sonst nirgends stünde:

- **Realschule, Pflichtbereich (17 Fächer):** Religionslehre/Ethik, Deutsch, Englisch, Mathematik, Geschichte, Geographie, Gemeinschaftskunde, WBS, Physik, Chemie, Biologie, Musik, BK, Sport, Schwimmen, Reflexion BO, Medienbildung/Informatik. **Wahlpflichtbereich (3):** Technik, AES, Französisch — die drei klassenübergreifenden.
- **Grundschule (13 Fächer):** Religionslehre, Deutsch, Deutsch Erzählkreis, Deutsch +, D (Förder/Vertiefung), Heimat- und Sachunterricht, Englisch, Mathematik, M (Förder/Vertiefung), Bildende Kunst/Text.Werk, Text.Werk, Musik, Sport. Deutsch und Mathematik zerfallen also in mehrere Zeilen — deshalb der Fall des Förderunterrichts oben.
- **Grundschulklassen (7):** 1a, 1b, 2a, 2b, 3a, 3b, 4 — die vierte Stufe ist einzügig. Je Klasse eine Klassenleitung; wer es ist, kommt aus dem Bestand und nicht aus diesem Ticket.
- **Fachlehrkraft ist, wer in einer Klasse unterrichtet, ohne ihre Klassenleitung zu sein** — außer in Religion: Die liegt konzeptionell immer bei der Klassenleitung, in beiden Schularten, und ist damit das einzige Fach, das nie eine Fachlehrkraft-Sicht erzeugt. Die Deputatsverteilung bestätigt es, und sie zeigt zugleich den Gegenfall: Selbst ein Kernfach wie Deutsch geht in einer Klasse an eine Fachlehrkraft, während eine andere Person die Klasse führt.

**Keine dieser Fächerlisten wird gebaut.** Sie stehen hier als Beleg dafür, woher der Zuschnitt kommt — gebraucht werden von ihnen nur die drei Wahlmodule.

Woher die Zuordnung kommt, ist entschieden: **von Hand in Weltenbaum**, nicht aus ASV und nicht aus dem Deputatsplan — gepflegt von der Schulleitung je Schulart, nachgezogen zum Schuljahreswechsel (Annahme, siehe unten).
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Zwei Zuordnungen: Klasse je Schuljahr, und die Wahlmodulgruppe mit eigener Kennung
- [x] #2 Das Kind zeigt mit einem Feld auf seine Gruppe — keine Verbindungstabelle, keine Mitgliederliste
- [x] #3 Zwei Gruppen desselben Moduls im selben Jahrgang sind darstellbar, mit verschiedenen Lehrkräften — als Gegenprobe
- [x] #4 Die Gruppe trägt ihre Kohorte, damit beim Eintragen die richtigen zur Auswahl stehen und eine leere Gruppe ein Zuhause hat
- [x] #5 Genau eine Lehrkraft je Gruppe; kein Schuljahr an der Gruppe, sie lebt so lange wie die Kohorte
- [x] #6 Eine Zuordnung Lehrkraft ↔ Klasse ohne Schuljahr wird abgewiesen
- [x] #7 Die Werteliste trägt genau die drei Wahlmodule; die übrigen Fächer entstehen nicht
- [x] #8 Listen entstehen je Zuordnung, nicht je Lehrkraft: Klassenliste und Gruppenliste sind zwei
- [x] #9 children.class_id bleibt die Stammklasse, die Gruppe steht daneben
- [x] #10 Für Akademie und Veranstaltungsbegleitung entsteht keine zweite Kindermenge — die Anmeldung dort ist sie
- [x] #11 Fehlt die Zuordnung, sieht die Lehrkraft nichts statt zu viel — das Prüfskript zeigt es
- [ ] #12 Bestätigt, wer die Verteilung pflegt — Annahme ist die Schulleitung je Schulart, sie ist ungeprüft
- [x] #13 Solange je Modul und Kohorte eine Gruppe existiert, wählt die Oberfläche das Modul und legt die Gruppe selbst an; die Auswahl erscheint erst bei der zweiten
- [x] #14 Das Aufteilen in zwei Gruppen ist eine benannte Handlung mit dem Schritt 'wer kommt wohin'
- [x] #15 Die Wahl von A ist im Schema begründet: Wer in einer Klasse unterrichtet, sieht diese Klasse — auch die Kinder, die er nicht selbst fördert
- [x] #16 Die Zuordnung Kind ↔ Gruppe steht als Tabelle, nicht als Feld — heute eine Zeile je Kind, ohne Umstellung auch zwei
- [x] #17 Das Prüfskript zeigt beides: ein Kind in einer Gruppe und ein Kind in zweien
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Gebaut in schema/klassenorganisation-schema.sql: elective_modules, elective_groups,
child_group_memberships, class_teaching_assignments, Prüfskript grün gegen die
vollständige Datenbank. Die Werteliste steht dort und nicht in stammdaten — der
Ladereihenfolge-Grund entfiel mit der Zuordnungstabelle, [A!] im Dateikopf.
Kriterium 13 und 14 (Oberfläche) stehen als Ablauf in soll-prozesse/15.

Offen ist allein Kriterium 12: Wer die Verteilung pflegt, ist eine [?]-Marke im
Prüfskript-Kopf der Domäne und ungeprüft. Dazu der Prüflauf nach
prompts/schema-pruefen.md in einer frischen Session.

Nachgezogen: grenzkarte.md nennt die zweite Achse jetzt mit ihren Pfaden statt als
offene Stelle, api/klassenorganisation-api.md sagt, dass die vier neuen Tabellen
bewusst noch keine Route haben.
<!-- SECTION:NOTES:END -->
