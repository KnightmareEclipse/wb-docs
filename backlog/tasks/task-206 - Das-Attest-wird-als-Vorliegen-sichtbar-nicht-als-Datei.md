---
id: TASK-206
title: 'Das Attest wird als Vorliegen sichtbar, nicht als Datei'
status: To Do
assignee: []
created_date: '2026-09-03 11:36'
updated_date: '2026-09-03 18:20'
labels:
  - schema
  - gesundheit
  - dsgvo
milestone: m-5
dependencies: []
references:
  - schema/gesundheit-schema.sql
  - schema/gesundheit-schema-check.sql
  - api/gesundheit-api.md
ordinal: 219000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Antwort des Datenschutzbeauftragten vom 02.09.2026, wörtlich: "Mitarbeiter sieht alles; es muss ersichtlich sein, dass Attest vorliegt, Attest selber muss nicht zwingend einsehbar sein => Sek. muss prüfen, ob Elternangaben und Angaben auf dem Attest übereinstimmen – ggf. Rücksprache Eltern."

Damit ist ein dritter Zustand nötig, den `health_field_visibility` heute nicht kennt: Zeile da heißt Wert sichtbar, Zeile fehlt heißt, das Feld existiert für diesen Sichtkreis gar nicht. "Liegt vor, aber nicht einsehbar" ist keines von beidem. Und seit der groben Sichtregel desselben Tages ist das nicht mehr der Sonderfall Notfall, sondern der Alltag jeder Lehrkraft und jeder Hortkraft. Der Anspruch steht bereits als Kommentar an `health_emergency_accesses` (schema/gesundheit-schema.sql) — der Mechanismus dazu fehlt.

Vorschlag: eine Spalte `presence_only boolean NOT NULL DEFAULT false` an `health_field_visibility`. Der Sichtkreis bekommt das Feld, die Sicht liefert statt der `document_id` nur, ob eine hinterlegt ist. Das trägt jedes Feld der Wertart `document` und nicht nur das Attest, und es bleibt bei einer Zeile je Sichtkreis und Feld.

Bewusst nicht allein in der Route: RLS filtert Zeilen und keine Spalten, die Sicht muss den Wert also leeren. Läge die Regel nur im Anwendungscode, sähe kein Prüfskript sie.

`full` (Sekretariat, Schulleitung, Eltern) behält das Attest im Klartext — sonst könnte das Sekretariat den Abgleich nicht führen, den derselbe Satz verlangt.

Die Prüfung selbst braucht keine Struktur: "das Sekretariat wird dann die Angaben anpassen im Text, falls das Attest etwas anderes sagt" (Betreiber, 03.09.2026). Das ist eine gewöhnliche Korrektur an `health_trait_values` — kein Prüfzustand, keine zweite Fassung, keine Spalte. Die Spur entsteht von selbst in `change_log`.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 presence_only steht an health_field_visibility, mit Begründung als Spaltenkommentar
- [ ] #2 Ein Sichtkreis mit presence_only liefert nie eine document_id — Gegenprobe im Prüfskript
- [ ] #3 Derselbe Sichtkreis liefert sehr wohl, DASS ein Attest vorliegt — zweite Gegenprobe
- [ ] #4 full behält das Attest im Klartext, damit das Sekretariat abgleichen kann
- [ ] #5 Kein Prüfzustand an health_traits: die Korrektur des Sekretariats ist ein gewöhnlicher Schreibvorgang
- [ ] #6 Sollstand im Kopf des Prüfskripts nachgezogen, alle Prüfskripte grün gegen die vollständige Datenbank
<!-- AC:END -->
