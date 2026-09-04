---
id: TASK-233
title: Die Abschlussnotiz von TASK-111 und der Bibliothekscode app_documents
status: To Do
assignee: []
created_date: '2026-09-04 00:20'
updated_date: '2026-09-04 00:29'
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

Entweder ist `app_documents` der Code der Schülerakte, dann ist der Name irreführend und gehört umbenannt; oder das Backend legt tatsächlich woanders ab als die Doku beschreibt, dann ist es eine Abweichung. Beides ist zu klären, bevor jemand die Bibliotheken beim Aufsetzen anlegt.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 oberflaechen.md und querschnitt-schema.sql sagen dasselbe ueber den Zugriff auf die Bibliothek
- [ ] #2 Die Abschlussnotiz von TASK-111 stimmt mit dem Ergebnis ueberein oder ist als ueberholt gekennzeichnet
- [ ] #3 Geklaert, ob app_documents der Code der Schuelerakte ist — und wenn ja, ob der Name bleibt
<!-- AC:END -->
