---
id: TASK-255
title: Den handlungsrelevanten Hinweis je Sichtkreis in wb-backend nachziehen
status: To Do
assignee: []
created_date: '2026-09-04 20:39'
updated_date: '2026-09-05 19:10'
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
- [x] #1 child_health_action_notes traegt eine Zeile je Bestand und Sichtkreis; ein zweiter Hinweis desselben Kreises wird abgewiesen
- [ ] #2 Die Hortleitung schreibt den Hinweis fuer care, die Klassenlehrkraft den fuer school — und keine die des anderen
- [x] #3 Die Eltern schreiben ihn nicht und lesen ihn nicht
- [x] #4 Er geht per Cascade mit dem Bestand und damit mit dem Kind — als Gegenprobe
- [x] #5 backend_health_note schreibt auf die neue Tabelle: INSERT, DELETE und UPDATE (note), und SELECT nur auf die zwei Schluesselspalten
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Gemessen am Baum von wb-backend (9be3efa, Branch wertelisten-und-log-filter); die Gegenproben laufen als ./schema-check.sh gegen dessen Datenbank, rc=0 bei allen vierzehn.

Kriterium 1 steht. `child_health_action_notes` traegt `pk_child_health_action_notes (child_health_record_id, health_visibility_scope_id)` — eine Zeile je Bestand und Sichtkreis. Die Gegenprobe „09 — zweiter Hinweis desselben Kreises" in gesundheit-schema-check.sql weist den zweiten ab, „09 — je Instanz ein eigener Hinweis, beide nebeneinander" nimmt die zwei Kreise an.

Kriterium 3 steht in beide Richtungen. Lesen: `action_notes=({} if user.is_guardian else await _action_notes(...))` in app/routers/gesundheit.py, gehalten von `test_neither_the_guardian_nor_the_day_care_sees_the_action_note`. Schreiben: die Route verlangt `is_class_teacher`, und `ck_child_health_action_notes_created_by` weist `guardian:` ab — Gegenprobe „die Eltern schreiben den Hinweis".

Kriterium 4 steht. `fk_child_health_action_notes_record` traegt ON DELETE CASCADE; die Gegenprobe „03 — erst der Bestand, dann das Kind" prueft hinterher, dass keine Zeile ihr Kind ueberlebt.

Kriterium 5 steht, nachdem der Widerspruch in wb-docs aufgeloest ist: `backend_health_note` haelt `INSERT`, `DELETE`, `UPDATE (note)` und `SELECT` allein auf `child_health_record_id` und `health_visibility_scope_id`. Der Rollensatz in api/gesundheit-api.md sagte dagegen „`SELECT`, `INSERT`, `UPDATE` … **kein `DELETE`**“ und war in allen drei Angaben falsch — die Rolle liest den Hinweis gar nicht (das tut `backend_runtime`), ihr `UPDATE` ist auf `note` beschraenkt, und das `DELETE` ist die Form des Leerens: `ck_child_health_action_notes_note` weist den leeren Text ab, also geht beim Leeren die Zeile. Die .md ist nachgezogen, das Kriterium traegt jetzt den gebauten Satz.

Offen bleibt eines:

- **Kriterium 2 haengt an TASK-197 #4.** Den Sichtkreis `school` gibt es als Zeile nicht — der Seed fuehrt weiter sechs Kreise samt `class_lead` und `sports`. Die Route schreibt darum fuer `class_lead`, und app/routers/gesundheit.py traegt die Kruecke ausdruecklich: `_TEACHING_SIGHTS = frozenset({"class_lead", "sports"})` mit dem Kommentar „The two fall together into one sight with TASK-197". Die andere Haelfte fehlt ganz: Es gibt keine Route, ueber die die Hortleitung den Hinweis fuer `care` schreibt — `ChildHealthActionNote(...)` entsteht an genau einer Stelle, und die verlangt die Klassenleitung.

<!-- SECTION:NOTES:END -->
