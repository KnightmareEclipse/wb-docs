---
id: TASK-247
title: Jedes unterschriebene Dokument traegt eine Pruefsumme — heute zwei von vier
status: Done
assignee: []
created_date: '2026-09-04 16:58'
updated_date: '2026-09-05 00:35'
labels:
  - schema
  - dokumente
  - wb-backend
dependencies: []
ordinal: 260000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Geschaeftsfuehrung, 04.09.2026: **Alle Dokumente, unter denen unterschrieben wird, muessen eine Pruefsumme haben.**

`dokumente.md` behauptet das fuer die Klasse `signed` bereits — die Zeile nennt Schulvertrag, Betreuungsvertrag, SEPA-Mandat und Fotoeinverstaendnis und sagt: 'Urkunde je Vorgang, Pruefsumme, Unterschriftszeilen'. Das Schema haelt es nicht: Eine Pruefsumme steht allein an `contracts.document_checksum` und `contract_amendments.document_checksum` (anmeldung-schema.sql). Es fehlen die drei anderen Vorgaenge, unter denen `signatures` eine Unterschrift fuehrt:

- **SEPA-Mandat** — `sepa_mandates.document_id` (stammdaten-schema.sql), keine Pruefsumme daneben.
- **Fotoeinverstaendnis** — `consents.document_id` (querschnitt-schema.sql), keine.
- **Modulanlage des Betreuungsvertrags** — `signatures.care_module_agreement_id`; die Tabelle traegt heute ueberhaupt kein `document_id`, obwohl `dokumente.md` den Betreuungsvertrag unter `signed` fuehrt. Erst pruefen, ob dort eine Datei entsteht, bevor eine Pruefsumme dafuer gebaut wird.

**Die naheliegende Bauform ist eine Spalte an `documents`** statt einer je Vorgangstabelle: Die Pruefsumme gehoert zur Datei und nicht zum Vorgang, und heute stuende sie an vier Stellen in vier Tabellen (rules.md Abschnitt 1). Dagegen spricht, dass sie dann auch an einem hochgeladenen Scan haenge, unter dem niemand unterschrieben hat — das ist zu entscheiden und nicht vorwegzunehmen. `contracts.document_checksum` bindet zusaetzlich den freigegebenen Vertragstext und hat damit einen zweiten Zweck; ob der mitwandert, gehoert zur selben Entscheidung.

**Was daran haengt:** Der Nachweis der Fotoerlaubnis ueberdauert alles andere (TASK-244) — er wird beim Loeschen des Kindes in eine eigene Bibliothek kopiert und liegt dort unbegrenzt. Genau bei ihm ist heute weder am Original noch an der Kopie eine Pruefsumme, und deshalb steht in `photo_consent_records` bewusst keine: Eine, die erst an der Kopie entstuende, belegte nichts gegen ein Original, das im selben Zug geloescht wird. Sobald das Original eine traegt, nimmt die Kopie sie mit — das ist der Punkt, an dem dieses Ticket auf TASK-246 trifft.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Entschieden, ob die Pruefsumme an documents steht oder je Vorgangstabelle — mit dem Preis der verworfenen Form
- [x] #2 SEPA-Mandat und Fotoeinverstaendnis tragen sie; die Gegenprobe: eine Datei ohne Pruefsumme kommt nicht durch
- [x] #3 Geprueft, ob die Modulanlage ueberhaupt eine Datei erzeugt — falls ja, traegt sie sie ebenfalls, falls nein, ist dokumente.md richtigzustellen
- [x] #4 photo_consent_records nimmt die Pruefsumme des Originals mit in die Kopie (TASK-246)
- [x] #5 dokumente.md und das Schema sagen dasselbe
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Entschieden: **je Vorgangstabelle, nicht an `documents`.** Der Grund ist die Gegenprobe. An `documents` liesse sich 'eine unterschriebene Datei ohne Pruefsumme kommt nicht durch' gar nicht ausdruecken — die Zeile weiss nicht, ob unter ihrer Datei jemand unterschrieben hat; entweder traegt dann jeder hochgeladene Scan eine, was kein Ablageweg heute einloest, oder die Spalte ist nullable und der CHECK ist keiner. Am Vorgang steht die Paarung dagegen als `(document_id IS NULL) = (document_checksum IS NULL)`. Der Preis, benannt: dieselbe Mechanik steht in fuenf Tabellen, und ein sechster unterschriebener Vorgang kostet eine sechste Spalte statt keiner. Praezedenz gab den Ausschlag — `contracts` und `contract_amendments` bauen es schon so.

Neu: `sepa_mandates.document_checksum`, `consents.document_checksum`, `care_module_agreements.document_id` samt `document_checksum` (TASK-241), `photo_consent_records.document_checksum`. Alle mit derselben Paarung und demselben Format `sha256:<64 Hexstellen>`.

Kriterium 3 geprueft: Die Modulanlage erzeugt eine Datei — '09: dieselbe Mail nach jeder freigegebenen Anpassung mit der neuen Modulanlage; damit hat jeder Vertragspartner seine Ausfertigung'. Sie traegt beides.

Kriterium 4: Der Kommentar an `photo_consent_records`, der die fehlende Pruefsumme noch begruendete, ist ersetzt — sie wandert jetzt mit der Kopie, weil das Original eine traegt. Der Lauf, der kopiert, steht in wb-backend (TASK-246).

Acht Gegenproben in querschnitt- und anmeldung-schema-check.sql, jede gegen den benannten Constraint verifiziert. dokumente.md und grenzkarte.md sagen jetzt dasselbe wie das Schema: jedes Dokument, unter dem unterschrieben wird, traegt eine Pruefsumme. wb-backend zieht nach: TASK-267.
<!-- SECTION:NOTES:END -->
