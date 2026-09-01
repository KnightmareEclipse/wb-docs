---
id: TASK-055
title: Prozess für die DSGVO-Datenauskunft festlegen
status: Done
assignee: []
created_date: '2026-08-27 11:37'
updated_date: '2026-09-01 23:05'
labels:
  - wartet
  - schulleitung
  - dsgvo
milestone: m-1
dependencies: []
references:
  - dsgvo.md
ordinal: 58000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Art. 15/16/20. Heute gibt es keinen: herausgegeben wird allein die digitale Schülerakte aus SharePoint, die den Datenbankbestand nicht enthält. Nach dem Vollimport liegt der Personenbezug in vierzehn Schemata und ist über persons.person_id bzw. children.child_id vollständig einsammelbar.

Der Umfang ist am 01.09.2026 beantwortet: Die Portaldaten gehören in die Auskunft. Weltenbaum wird damit eine weitere Zeile in der Arbeitshilfe des Sekretariats, kein Ersatz für sie — den eigenen Anteil stellt es auf Knopfdruck zusammen, die übrigen Ablagen bleiben Handarbeit nach der Checkliste.

Entschieden am 02.09.2026 vom Betreiber (siehe Abschluss unten): Weltenbaum trägt einen Export-Knopf bei, alles Weitere bleibt organisatorisch. Die Frage steht deshalb nicht mehr auf dem Blatt für den Datenschutzbeauftragten.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Umfang geklärt: was in die Auskunft gehört — Schülerakte allein, oder auch der Datenbankbestand
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Entschieden am 02.09.2026 vom Betreiber: Weltenbaum bekommt einen Export-Knopf, der zu einer Person oder einem Kind den gesamten eigenen Bestand ausgibt — nutzbar allein für eine benannte Rolle. Mehr nicht: kein Antrag im Portal, keine Frist im System, keine Ablösung der Arbeitshilfe des Sekretariats. Die Auskunft selbst läuft weiter organisatorisch nach der bestehenden Checkliste, und unser Auszug wird eine weitere Zeile darin. Der Punkt ist deshalb aus dem Blatt für den Datenschutzbeauftragten gestrichen. Gebaut wird der Knopf in TASK-193.
<!-- SECTION:NOTES:END -->
