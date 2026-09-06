---
id: TASK-274
title: >-
  Die Abgangsliste braucht eigene sync_targets-Zeilen statt geteilter
  ASV/M365-Codes
status: To Do
assignee: []
created_date: '2026-09-06 00:46'
labels:
  - wb-backend
  - stammdaten
dependencies: []
ordinal: 287000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Der Prüfbericht STAMM-R6 (`pruefberichte/routen-stammdaten.md`) findet: `_departure_out` liest `sync_tasks` über `or_(child_id == …, family_id == …)` ohne jede Bedingung auf die Ziele des Abgangs — obwohl `withdraw_departure` mit `_DEPARTURE_TARGETS` genau diese Menge kennt. Eine erledigte oder offene "Klasse … nachziehen"-Aufgabe (`set_child_class`, target `asv_bw`/`m365`) oder eine "Name geändert"/"Anschrift geändert"-Aufgabe (`_carry_over`, target `asv_bw`/`optigem`/`m365`) desselben Kindes steht damit als Abgangspunkt in der Ansicht — beim Elternteil sogar, sobald sie ein `confirmed_end_date` trüge (03 Z2: "die Abgangsliste nur die Sicht auf alle Punkte eines Abgangs").

Der Vorschlag des Prüfers — die Query auf `SyncTarget.code.in_(_DEPARTURE_TARGETS)` einschränken — trägt nicht: `_DEPARTURE_TARGETS` (`asv_bw`, `optigem`, `m365`, `in_house`) sind genau die Codes, die `set_child_class` und `_carry_over` für dieselben Kinder ebenfalls benutzen, weil eine `sync_targets`-Zeile eine Aufgabenart trägt und keinen Anlass ("Umzug und Abgang derselben Person werden eine Aufgabe je System, nicht zwei", `sync_targets`-Kommentar in `schema/querschnitt-schema.sql`). Ein Filter auf den Code trennt die drei Anlässe (Abgang, Klassenwechsel, Namens-/Adressänderung) deshalb nicht.

Der Schema-Kommentar nennt die Lösung selbst schon als Muster: "Wo ein Block eine zweite [Art] benennt, bekommt sie ihre eigene Zeile bei demselben System und derselben Rolle" (Beispiel dort: die Änderungsgebühr). Der Abgang braucht damit eigene `sync_targets`-Codes (z. B. `asv_bw_departure`, `optigem_departure`, `m365_departure`) statt der geteilten `asv_bw`/`optigem`/`m365`, oder eine andere DDL-Lösung, die dieselbe Trennung trägt. Das ist eine Migration und kein Routen-Fix (`prompts/api-reparieren.md`: "Braucht ein Fund DDL, ist er kein Routen-Fund mehr").
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Ein neuer sync_targets-Code (oder eine andere DDL-Lösung) trennt eine Abgangsaufgabe von einer Klassenwechsel- oder Namens-/Adressänderungsaufgabe desselben Kindes am selben System
- [ ] #2 _raise_departure_points (app/routers/stammdaten.py) legt die Abgangspunkte unter den neuen Codes an
- [ ] #3 _departure_out filtert auf diese Codes, statt jeden SyncTask des Kindes/der Familie ungeachtet des Anlasses zu zeigen
- [ ] #4 Ein Test: eine offene Klassenwechsel-Aufgabe (set_child_class) desselben Kindes steht nicht auf GET /children/{id}/departure
<!-- AC:END -->
