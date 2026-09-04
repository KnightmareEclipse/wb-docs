---
id: TASK-255
title: Den handlungsrelevanten Hinweis je Sichtkreis in wb-backend nachziehen
status: To Do
assignee: []
created_date: '2026-09-04 20:39'
labels:
  - schema
  - gesundheit
milestone: m-5
dependencies: []
ordinal: 268000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Aus dem Gespraech mit der Geschaeftsfuehrung am 04.09.2026: Der Hort braucht den handlungsrelevanten Hinweis ebenfalls — er hakt seine Tagesliste auf Papier ab, und darauf steht direkt hinter dem Namen eine Marke, wo es etwas zu beachten gibt (soll-prozesse/09-hortvertrag.md).

**Die frueheren Saetze sind damit ueberholt:** api/gesundheit-api.md sagte "Nicht an den Hort — er unterrichtet nicht". Der Grund traegt fuer den Betreuungsalltag nicht: Der Hort hat das Kind stundenlang und oft draussen, ohne Lehrkraft daneben. Zugleich behaupteten soll-prozesse/09-hortvertrag.md und TASK-216 schon vorher, die Liste zeige "den Hinweis am Kind im Sichtkreis des Horts" — beide Stellen widersprachen einander.

**Gebaut ist in wb-docs:** `child_health_records.action_note` ist entfallen, an seine Stelle tritt `child_health_action_notes` — eine Zeile je Bestand **und Sichtkreis**. Ein einziges Feld haette zwei Verfasser mit verschiedenem Alltag (Klassenlehrkraft fuer den Unterricht, Hortleitung fuer die Betreuung), die einander lautlos ueberschrieben; und ein externes Hortkind hat gar keine Klassenlehrkraft, die schriebe. Dieselbe Bauform tragen die Freigaben schon: "Schule und Hort sind zwei Instanzen desselben Bestands" (grenzkarte.md).

**Die Marke folgt aus dem Hinweis** und braucht kein eigenes Feld: steht einer da, steht sie da. Ein Haekchen "alltagsrelevant" an der Merkmalsart kommt ausdruecklich nicht in Frage — es gab es als `is_everyday_relevant` und wurde gestrichen (schema/gesundheit-schema.sql).

**Wo nichts vorliegt, steht keine Marke** — und das ist kein Zurueckhalten: Die Gesundheitsangaben sind freiwillig, niemand fordert sie ein, und worueber die Eltern nichts sagen, darueber weiss der Hort nichts. Das traegt sich selbst: Geschrieben wird ueber eine Route, die nur zeigt, was der Kreis sehen darf.

Zu tun in wb-backend: die Ursprungsrevision umschreiben (keine Migrationskette, solange nichts produktiv laeuft), `backend_health_note` auf die neue Tabelle umhaengen, den Router und die Tests nachziehen. Neu bewertet ist der Bestand bereits: folgenabschaetzung.md R11.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 child_health_action_notes traegt eine Zeile je Bestand und Sichtkreis; ein zweiter Hinweis desselben Kreises wird abgewiesen
- [ ] #2 Die Hortleitung schreibt den Hinweis fuer care, die Klassenlehrkraft den fuer school — und keine die des anderen
- [ ] #3 Die Eltern schreiben ihn nicht und lesen ihn nicht
- [ ] #4 Er geht per Cascade mit dem Bestand und damit mit dem Kind — als Gegenprobe
- [ ] #5 backend_health_note schreibt auf die neue Tabelle, kein DELETE
<!-- AC:END -->
