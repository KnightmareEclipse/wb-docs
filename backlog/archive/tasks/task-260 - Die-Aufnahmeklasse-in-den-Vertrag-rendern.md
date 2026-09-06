---
id: TASK-260
title: Die Aufnahmeklasse in den Vertrag rendern
status: To Do
assignee: []
created_date: '2026-09-04 23:46'
labels:
  - backend
  - anmeldung
milestone: m-5
dependencies: []
ordinal: 273000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Der reale Schulvertrag traegt auf Seite 3 den Satz "ab dem ⟨VertragsBeginn⟩ in die ⟨Klasse⟩ aufgenommen" — zwei Inhaltssteuerelemente (`VertragsBeginn`, `Klasse`) unter den 82 der Vorlage (Betreiber, 05.09.2026).

**Der Renderkontext fuellt die Klasse nicht.** `build_contract_document` (`wb-backend/app/services/anmeldung.py`) uebergibt `start_date`, aber keine Stufe — im erzeugten Vertrag bleibt die Stelle leer.

**Die Quelle ist da und es ist die richtige:** `applications.target_grade_level`. Der Schulvertrag haengt an einer Bewerbung (`contracts.application_id` ist fuer ihn Pflicht), und die Bewerbung traegt die Zielstufe — auch beim Quereinsteiger, fuer den es kein Anmeldefenster gibt.

**Was ausdruecklich NICHT die Quelle ist: `children.grade_level`.** Das ist die Stufe von heute, und der Jahreslauf rueckt sie jedes Jahr hoch (04). Ein Vertrag, der beim zweiten Rendern "in die 3. Klasse aufgenommen" saegt, obwohl das Kind in die 1. kam, waere falsch — dieselbe Falle, die `dokumente.md` unter "Was einmal erzeugt ist, wird nicht neu erzeugt" beschreibt. Die Aufnahmeklasse ist historisch fest und gehoert zur Bewerbung, nicht zum Kind.

**Und die Quelle haelt laenger als die Bewerbung selbst.** Der naheliegende Einwand — "loeschen wir die Bewerberdaten nicht?" — traegt hier nicht: Die sechs Monate ab Endstatus treffen die Bewerbung **ohne** Vertrag. Wo einer entstanden ist, haelt `fk_contracts_application` sie fest, bis der Vertrag selbst faellt (fuenf Jahre nach dem Austritt). Der Loesch-Lauf raeumt deshalb erst den Vertrag und dann die Bewerbung, und das Pruefskript weist die umgekehrte Reihenfolge ausdruecklich ab: `anmeldung-schema-check.sql`, "17 — Bewerbung geloescht, waehrend ihr Vertrag sie noch festhaelt". Der Schema-Kommentar an `applications` sagt das jetzt auch — vorher stand dort nur die Frist, und wer sie allein las, kam genau auf diesen Einwand.

**Fuer die Redline zaehlt dasselbe** (TASK-259): Beide Fassungen werden mit den Daten dieser Familie gerendert, und "diese Daten" heisst fuer die Klasse die Aufnahmestufe aus der Bewerbung. Sonst zeigte der Vergleich eine Aenderung, wo sich nur das Schuljahr gedreht hat.

Zwei weitere Kontextwerte gehoeren fuer die Redline korrigiert, weil sie dort etwas anderes bedeuten als in der Urkunde: `released_on` steht heute auf `today()` — in einer Redline muss es das Freigabedatum des Vertrags sein —, und die Unterschriftsbilder gehoeren gar nicht hinein, sonst saehe der Entwurf aus wie eine Urkunde.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Der Platzhalter Klasse wird aus applications.target_grade_level gefuellt, nicht aus children.grade_level
- [ ] #2 Gegenprobe: ein Vertrag, der Jahre nach dem Abschluss erneut gerendert wird, nennt weiterhin die Aufnahmestufe
- [ ] #5 Die Bewerbung ist zu diesem Zeitpunkt noch da — belegt durch die vorhandene Gegenprobe, dass sie vor ihrem Vertrag nicht geloescht werden kann
- [ ] #3 In der Redline traegt released_on das Freigabedatum des Vertrags und nicht den heutigen Tag
- [ ] #4 In der Redline stehen keine Unterschriftsbilder
<!-- AC:END -->
