---
id: TASK-233
title: Die Abschlussnotiz von TASK-111 und der Bibliothekscode app_documents
status: Done
assignee: []
created_date: '2026-09-04 00:20'
updated_date: '2026-09-04 00:32'
labels:
  - wb-docs
milestone: m-5
dependencies: []
ordinal: 245000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
**Der Widerspruch in der Doku ist mit `5024721` aufgelöst**, und zwar in die andere Richtung als angenommen: `oberflaechen.md`, `schema/querschnitt-schema.sql` und `grenzkarte.md` sagen jetzt übereinstimmend, dass es **drei** Bibliotheken gibt und dass an Schülerakte und Belege **kein Mensch direkt** kommt — Direktzugriff hat allein der Hort auf seine Hortakte. Der Satz über den Vollzugriff für Sekretariat und Geschäftsführung ist gestrichen.

**Zwei Reste bleiben.**

**Erstens: TASK-111 stimmt weiterhin nicht.** Sein Abnahmekriterium #2 und die Abschlussnotiz sagen „in der Bibliothek, in der Menschen nur lesen". Nach dem neuen Stand lesen Menschen dort gar nicht — sie kommen über Weltenbaum. Die Notiz ist also weiter falsch, nur in die andere Richtung. Sie gehört auf den heutigen Stand gebracht oder als überholt gekennzeichnet.

**Zweitens, und das ist der größere Fund:** `wb-backend` legt die erzeugten Dokumente in eine Bibliothek mit dem Code **`app_documents`** (`GENERATED_LIBRARY` in `app/services/anmeldung.py`, benutzt an vier Stellen). Die Doku kennt seit `5024721` drei Bibliotheken — Schülerakte, Hortakte, Belege — und sagt, die erzeugten Unterlagen lägen **in der Schülerakte**. Eine vierte namens `app_documents` gibt es dort nicht.

**Nachgeprüft am 04.09.2026: `app_documents` *ist* die Schülerakte.** Dieselbe Konstante `GENERATED_LIBRARY` trägt die erzeugten Urkunden **und** die Ordner je Kind (`child_file_folders`, `app/services/anmeldung.py`) — es ist eine Bibliothek, keine vierte. Der Name stammt aus dem Zwei-Bibliotheken-Modell, in dem es eine Ablage „was die App erzeugt" neben der des Sekretariats gab; seit `5024721` gibt es die nicht mehr, und der Code benennt jetzt den Erzeuger statt die Sache. Dasselbe gilt für die Fehlermeldung „The generated-documents library carries no drive id".

Umbenennen kostet heute nichts: `sharepoint_libraries` wird **bewusst nicht geseedet** — die Zeilen legt ein Mensch beim Aufsetzen an (`value_list_seed`-Revision). Es gibt also noch keinen Bestand, der an dem Code hängt. Die Umbenennung ist als Abnahmekriterium an TASK-181 gewandert, wo die Bibliotheken ohnehin bearbeitet werden.

**Was TASK-181 offen behält, nicht dieses Ticket:** Das Backend kennt zwei Bibliothekscodes (`app_documents`, `expense_claims`), die Doku seit `5024721` drei. Die **Hortakte** fehlt im Code — sie ist AC #1 dort.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 oberflaechen.md und querschnitt-schema.sql sagen dasselbe ueber den Zugriff auf die Bibliothek
- [x] #2 Die Abschlussnotiz von TASK-111 stimmt mit dem Ergebnis ueberein oder ist als ueberholt gekennzeichnet
- [x] #3 Geklaert, ob app_documents der Code der Schuelerakte ist — und wenn ja, ob der Name bleibt
<!-- AC:END -->
