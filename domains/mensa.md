# Mensa — Fachdomäne

Domäne 6 aus `fachdomaenen.md` Abschnitt 6 (der Mensa-Teil; AGs bleiben offen). Tabellenschema: `domains/mensa-schema.sql`, belegt durch `domains/mensa-schema-check.sql` (Sollstand 4/4). Der heutige Ablauf samt Formularfeldern steht in `prozesse.md` Abschnitt 9.

Die kleinste gebaute Domäne — weil ihre Buchung gar nicht ihr gehört.

## Die Buchung ist eine Betreuungsbuchung

Das RS-Anmeldeformular („Anmeldung zum Mittagessen") ist dieselbe Buchungsform wie der Betreuungsvertrag des Horts: Wochentage ankreuzen, Monatsbeitrag, Schuljahreslaufzeit, Kündigung zum Halbjahr. Sie läuft deshalb über `care_module_bookings`/`care_module_booking_days` (`domains/anmeldung-schema.sql`) mit der Katalogzeile **„Mittagessen"** — eine eigene Essensbuchungstabelle gäbe es nur dem Namen nach.

Für Hortkinder ist das Mittagessen **keine eigene Buchung**: der Betreuungsvertrag berechnet es „für alle Schüler, die länger als 13 Uhr betreut werden". Ob ein Modul das auslöst, trägt `care_modules.includes_lunch` — dieselbe Bauform wie die Hausaufgabenbetreuung (`includes_homework`): eine Eigenschaft des Moduls, gepflegt von der Verwaltung. **„Isst am Wochentag X mit" ist damit ein einziges Prädikat**: aktive Buchung eines `includes_lunch`-Moduls, dessen Buchungstage X enthalten — Hortkind und Mensa-Kind über denselben Weg. Die Küchen-Tagesliste ist eine Abfrage, kein Bestand.

Weil sie **Zeilen zählt**, darf ein Kind je Modul nur eine offene Buchung haben — sonst kocht die Küche eine Portion zu viel. Das sichert ein partieller Unique-Index an `care_module_bookings` (`domains/anmeldung-schema.sql`), nicht die Abfrage.

## Küchenprofil: einmal je Kind

Was der Küche gehört, ist die **Essensvariante**: `meal_profiles` (höchstens eine Zeile je Kind, mit Freitext-Hinweis „keine Nüsse") und `meal_profile_diets` (Varianten als Werteliste — Vegetarisch, Laktosefrei, Glutenfrei; mehrere zugleich sind der Normalfall, eine weitere ist eine Zeile statt einer Migration).

Erhoben wird das Profil über **zwei Formulare** — die „Infos für die Küche" der RS-Mensa-Anmeldung und die Vegetarier-Frage des Betreuungsvertrags —, gespeichert **einmal je Kind**, nicht je Anmeldung: dasselbe Prinzip wie bei den Gesundheitsdaten („sechs Formulare, ein Datenbestand"). Bei Hortkindern, deren Unverträglichkeit nur im Gesundheitsbogen steht, **überträgt eine Person mit vollem Domäne-9-Zugriff** (Sekretariat oder Hort) die essensrelevante Variante ins Profil — dieselbe Übersetzungsleistung, mit der die Klassenlehrkraft den `action_note` formuliert; die Küche selbst liest nie den Gesundheitsbestand.

**Abgrenzung zu Domäne 9, damit es niemand zusammenräumt:** Das Küchenprofil ist die Handlungsanweisung an die Küche (welche Variante kochen), von den Eltern formuliert — keine Diagnose. Die Lebensmittelunverträglichkeit mit Diagnose, Attest und Notfallanweisung bleibt ein `health_traits`-Merkmal mit dem engen Art.-9-Zugriff; die Küche bekommt dorthin **keinen** Zugriff. Dieselbe Zweiteilung wie `action_note` gegen den vollen Satz: der Unterschied ist der Leserkreis, nicht die Länge.

**Zugriff:** eigene Rolle für Küche/Hausdienstverwaltung mit GRANT auf Profil, Varianten und die Tagesliste — umgesetzt wie überall in `wb-backend/db/init-roles.sh`, nicht im Schema.

**Löschung:** `meal_profiles` blockiert die Kindzeile (`ON DELETE RESTRICT`) wie die Gesundheitstabellen — die Essensvariante lässt Rückschlüsse auf Gesundheit zu und verschwindet nicht als Nebenwirkung; der Lösch-Job räumt sie ausdrücklich, die Varianten fallen mit dem Profil.

## Was diese Domäne nicht enthält

- **Keine Zahlung und keine Preise.** Abgerechnet wird vollständig über Optigem (`domains/grenzkarte.md`, Q3); in Weltenbaum entsteht nur die Lastschrift-Erlaubnis als Zustimmung (Q1). Preis-Spalten am Modulkatalog fehlen bewusst, solange die Beitragssatzung/Preisliste nicht vorliegt — ihre Struktur zu raten wäre teurer als sie nachzutragen („Weiße Flecken").
- **Keine Essensausgabe-Erfassung.** Die Berechtigung wird bei der Ausgabe auf Papier geprüft (`prozesse.md` Abschnitt 9).
- **Kein Speiseplan.** Kein benannter Prozess braucht ihn.

## Offene Punkte

- Beitragssatzung/aktuelle Preisliste (Module und Mittagessen) beschaffen — erst dann bekommen die Module Preis-Spalten (`domains/grenzkarte.md`, „Weiße Flecken"; `TODO.md`).
- Eine Kapazitätsgrenze der Küche ist nicht bekannt; gebaut wird sie erst, wenn eine benannt ist.
