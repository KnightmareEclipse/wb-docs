# Klassenorganisation — Fachdomäne

Domäne 13 aus `fachdomaenen.md` Abschnitt 6. Tabellenschema: `domains/klassenorganisation-schema.sql`, belegt durch `domains/klassenorganisation-schema-check.sql` (Sollstand 3/3).

Die Domäne bringt genau **eine** Verknüpfung mit: Elternvertreter:in und Stellvertretung je Klasse (`class_parent_representatives`). Die beiden übrigen Angaben der realen Klassenliste — Klassenlehrer:in und Klassenzimmer — stehen bereits als `classes.class_teacher_id` und `classes.room` in Stammdaten (`domains/grenzkarte.md`, „Elternvertretung").

## Modell

- **Das Amt ist die Zeile:** Primärschlüssel ist Klasse × Amt (Vertretung/Stellvertretung als Boolean — eine strukturelle Zweiteilung, keine umbenennbare Kategorie). Je Klasse gibt es damit höchstens eine Vertretung und eine Stellvertretung; der Wechsel nach der Neuwahl ist ein UPDATE auf derselben Zeile, keine Historie — wie überall.
- **Gewählt wird aus den Erziehungsberechtigten:** der Fremdschlüssel zeigt auf `guardians`, nicht auf `persons`. Dass die Person ein Kind in genau dieser Klasse hat, führt über mehrere Tabellen und liegt deshalb in der Eingabemaske, nicht im Schema — dieselbe dokumentierte Lücke wie bei `contract_responses.person_id`.
- **Dieselbe Person kann nicht beide Ämter derselben Klasse halten** (UNIQUE); in verschiedenen Klassen (Geschwister) bleibt sie wählbar.
- **Kein Amtszeitraum:** ohne Schuljahres-Historie trägt die Tabelle nur den aktuellen Stand — für Verteiler und Ansprechpartnerlisten genügt das (`domains/grenzkarte.md`).

## Offene Punkte

Derzeit keine.
