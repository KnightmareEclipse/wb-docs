Prompt für die nächste Session — Tabellen-Datenmodell Putzdienst

---

Das Stammdaten-Schema steht und ist gegen vier reale Schulverwaltungs-Datenmodelle gegengelesen (ASV-BW, SVWS-NRW, GibbonEdu, eigenes Vorprojekt in `~/Documents/projectNightmare`). Diese Session baut die Putzdienst-eigenen Tabellen darauf auf.

## Vorher lesen

- `domains/stammdaten.md` + `domains/stammdaten-schema.sql` — die Grundlage, auf die alles Folgende referenziert
- `domains/putzdienst.md` — Prozess, Nebenbedingungen, Zyklus-Konfiguration, v1-Scope
- `fachdomaenen.md` Abschnitt 6/7 — Gesamtkontext
- `rules.md`, besonders Abschnitt 1 (Lean by Design inkl. der Ausnahme für DB-Schema-Design) und Abschnitt 3 (Lookup-Tabellen statt ENUM/CHECK, organisatorische Werte als DB-Daten)
- `idea/04-identitaet-zugriff.md`, `idea/03-container-anwendung.md`, `idea/06-dsgvo-organisatorisch.md`
- `project-parts.md` Abschnitt 3/4, `wb-backend/CLAUDE.md` (Schwester-Repo, falls von hier aus erreichbar)

## Aufgabe

Die Putzdienst-eigenen Tabellen — mindestens Zyklus-Konfiguration, Putztermin, Buchung/Zuordnung, Freikauf/Zahlungsstatus. Details und Nebenbedingungen stehen vollständig in `domains/putzdienst.md` (Restplatz-Zuordnung über OR-Tools, zweistufige Kapazität ohne feste Kapazitäts-Spalte, Quereinsteiger-Proration über die Termin-Liste, Freikauf zahlungswegneutral).

Bereits entschieden, gilt auch hier, nicht neu diskutieren:

- Lookup-Tabellen statt ENUM/CHECK für Putztermin-Typ, Zahlungsstatus, Buchungsquelle (`rules.md` Abschnitt 3) — Ausnahme bleibt ein strukturelles, nicht umbenennbares Flag, falls eine Ausprägung Pflichtfelder derselben Zeile bestimmt.
- Audit-Spalten (`created_by`/`created_at`/`updated_by`/`updated_at`) auf jeder Tabelle mit veränderlichem Inhalt, gefüllt über denselben `set_row_audit`-Trigger wie im Stammdaten-Schema.
- Keine feste Kapazitäts-Spalte am Termin — Kapazität wird berechnet, nicht gespeichert.
- Pflicht und Buchung hängen an der Familie, nicht am Kind.

Ergebnis in `domains/putzdienst-schema.sql`, Prüfskript analog `domains/stammdaten-schema-check.sql` (Postgres-Container, keine Testframeworks).

## Offen aus der Stammdaten-Arbeit, hier im Blick behalten

- Vis365-Feldliste geprüft, Schema deckt sie ab (`domains/stammdaten.md`, „Offene Punkte") — erledigt, blockierte Putzdienst ohnehin nicht.
- Konfession/Kirchengemeinde liegen als Spalten auf `persons`, geschützt per Spalten-GRANT (`denomination_id`/`congregation`) — Rollentrennung dafür ist Implementierungsarbeit in `wb-backend/db/init-roles.sh`, keine Schema-Frage mehr. **Wichtig für die Rollen-Umsetzung:** Spalten-GRANTs greifen nicht gegen den Tabelleneigentümer — `backend_runtime` darf `persons` also nicht besitzen, sonst wirkungslos.
- Gemeinsame Schema-Durchsicht mit dem zweiten Admin nach dessen Urlaubsrückkehr Ende August 2026.
- Zahlungsverantwortliche/Bankverbindung umgesetzt (`payers`/`child_payers`, `domains/stammdaten.md` „Zahlungsverantwortliche") — Anteil/Betrag je Zahler:in (Bezuschussung, künftige Gutscheine) bleibt bewusst offen, noch zu klären.
- Klassen-Kennung als Kohorte (`RS25a`-Schema) umgesetzt (`classes`), inkl. Schema-Review-Fix B (`children.provisional_grade_level_id`/`class_id` schließen sich aus statt gekoppelter Kopie) — gegen Postgres verifiziert.
- Schema-Review (vormals `SCHEMA-REVIEW-STAMMDATEN.md`) abgearbeitet: Audit-Trigger-Bug (Leerstring-Actor) gefixt, fehlende Indizes ergänzt, Check-Skript-Lücken geschlossen, `child_contacts.priority`. Datei entfernt, Ergebnis in Schema-Kommentaren und `domains/stammdaten.md` übernommen.
- Performance-Stresstest (1000–2000× reale Datenmenge, auf der Prod-VPS, inkl. paralleler Last per `pgbench`) abgeschlossen: Ergebnisse in `domains/stammdaten-schema-benchmark.md`, reproduzierbares Skript-Set in `domains/stammdaten-benchmark/`. Dabei zwei echte Funde behoben: fehlender Index auf `persons.email` (Folge der UNIQUE-Entfernung, jetzt gefixt) und **offener Punkt für `wb-backend/docker-compose.yml`: `shm_size` explizit setzen**, Dockers Standard (64 MB) reicht für Postgres' parallele Worker unter gleichzeitiger Last nicht.
- Geteilte Eltern-Mailadresse gelöst: `persons.email` bewusst nicht mehr UNIQUE, OTP-Mehrfachtreffer = Haushalts-Session (Vereinigung der Familien), akzeptiertes Risiko. Schulvertrag-Einzelzustimmung (beide Erziehungsberechtigte separat) braucht dafür eine eigene Zustimmungserfassung in der künftigen Anmeldeprozess-Fachdomäne, nicht die Login-Identität — vermerkt in `domains/stammdaten.md` und `idea/04-identitaet-zugriff.md`.
- Voranmeldung/Bewerber-Frage bewusst zurückgestellt (nicht entschieden) — der Anmeldeprozess wird bei dessen Fachdomäne vermutlich ohnehin überarbeitet.

## Arbeitsweise

Erst diskutieren, dann entscheiden — kein fertiges Schema ungefragt hinknallen. Wo eine echte Entscheidung ansteht (Feldtypen, Constraint in Postgres vs. Anwendungsebene, Nullable-Verhalten, Normalisierung), Rückfrage statt stillschweigender Annahme — mit der Ausnahme, dass beim Schema selbst eher zu vollständig als zu minimal geplant wird (`rules.md` Abschnitt 1). Antworten auf Deutsch, kurz/klar/präzise wie der bestehende Dokumentationsstil (`CLAUDE.md`).
