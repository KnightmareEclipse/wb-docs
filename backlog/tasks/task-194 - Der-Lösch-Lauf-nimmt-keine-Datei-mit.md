---
id: TASK-194
title: Der Lösch-Lauf nimmt keine Datei mit
status: To Do
assignee: []
created_date: '2026-09-02 07:55'
updated_date: '2026-09-04 13:14'
labels:
  - wb-backend
  - dsgvo
dependencies: []
references:
  - app/services/retention.py
  - schema/querschnitt-schema.sql
  - schema/querschnitt-schema-check.sql
ordinal: 207000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Gefunden im Nachtlauf 02.09.2026 (TASK-192): app/services/retention.py behandelt documents und child_file_folders gar nicht — weder die Zeile noch die Datei in SharePoint. Damit bleibt jede erzeugte Datei (Vertrag, Mandat, Fotoeinverständnis, Attest) stehen, wenn Kind und Vorgang gehen; grenzkarte.md Q2: „eine verwaiste Datei in SharePoint ist genauso ein DSGVO-Verstoß wie eine verwaiste Zeile". Die Stufenfolge steht als Kommentar in querschnitt-schema.sql und als Selbstprüfung (Tabelle loeschlauf) in querschnitt-schema-check.sql; seit TASK-192 halten sepa_mandates und consents ihre Datei mit NO ACTION fest, der Lauf muss also Mandat und unterschriebene Zustimmung vor der Datei und die Datei vor dem Kind nehmen. Vorher braucht er die Fristen je Aktenkategorie vom Datenschutzbeauftragten (08, fragen.md).

**Nachtrag 04.09.2026, aus einem Prueflauf ueber Block 17:** Zwei Dinge kommen dazu, und beide haengen am Lauf-Geruest statt an der Datei. Erstens die **Transaktionsgrenze**: `app/runs.py` oeffnet eine Transaktion je `Run`; Block 17 verlangt sie je **Anker** ('bleibt der ganze Anker stehen und kommt in der naechsten Nacht wieder dran'). Als gewoehnlicher `Run` gebaut, nimmt ein Graph-Fehler beim zweihundertsten Kind die hundertneunundneunzig davor mit. Zweitens die **Meldung**: Wer je Anker abfaengt, um weiterzukommen, wirft nicht mehr — und `container.md` haengt den `/fail`-Ping genau daran ('Ein Lauf, der wirft, pingt /fail'). Der Lauf muss den Fehlschlag deshalb selbst melden, sonst scheitert er Nacht fuer Nacht am selben Anker, heilt sich scheinbar und niemand erfaehrt es (`rules.md` Abschnitt 3: 'ein stiller Fehlschlag zaehlt als nicht vorhanden').
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Der Lauf entfernt die Datei in SharePoint zuerst und die documents-Zeile danach, in der Stufenfolge des Prüfskripts
- [ ] #2 Mandat und unterschriebene Zustimmung gehen mit ihrer Datei, ein Test hält die Reihenfolge fest
- [ ] #3 Ein Graph-Fehler beim Löschen der Datei lässt die Zeile stehen, statt eine verwaiste Datei zurückzulassen
- [ ] #4 Die Transaktionsgrenze ist der Anker, nicht der Lauf — ein Fehler beim 200. Kind nimmt die 199 davor nicht mit
- [ ] #5 Ein abgefangener Anker wird gemeldet: der Dienst pingt /fail, damit der Fehlschlag nicht still bleibt (rules.md Abschnitt 3)
- [ ] #6 Gegenprobe: ein erzwungener Graph-Fehler bei einem Anker laesst die uebrigen laufen und faerbt den Check rot
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Wartet auf den Pruefbericht zum neuen Querschnitt-Schema (TASK-009, prompts/schema-pruefen.md in frischer Session). Der Lauf haengt jetzt an zwei neuen Tabellen — retention_holds ueberspringt einen Anker, retention_notice_recipients traegt die Ankuendigung —, und was auf einem ungeprueften Schema gebaut wird, wird zweimal gebaut (prompts/parallel-sitzung.md, Haltepunkt). Die Stufenfolge samt Papierkorb steht im Kopf von querschnitt-schema.sql, die Zusage in Block 17 (Dateien).
<!-- SECTION:NOTES:END -->
