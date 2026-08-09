# TODO — Offene Punkte für Entwicklungs-Sessions

Fachliche/technische Punkte, die eine Session in diesem Repo oder in `wb-backend` abarbeiten kann — im Unterschied zu `TODO.md`, das reale Konten/Zugänge und organisatorische Vorbereitungen sammelt. Sortiert nach Dringlichkeit.

## Vor dem ersten Import echter Daten

### Import-Prozedur: Nachschlagen statt blind einfügen

Der Vollimport läuft **einmal in eine leere Datenbank**; ein Korrekturlauf heißt „verwerfen und neu laden", und damit ist Idempotenz (`rules.md` Abschnitt 3) erfüllt, ohne dass das Schema etwas dafür tun muss. Ein wiederkehrender maschineller Abgleich existiert in keine Richtung: nach ASV-BW gehen nur Neuanlagen per CSV, die Bankverbindung wandert einmal von Hand nach Optigem, Änderungen laufen in beiden Systemen manuell (`fachdomaenen.md` Abschnitt 4). Deshalb bewusst **kein** Quellsystem-Schlüssel an `children`/`persons`.

Was bleibt, ist eine Anforderung an die Import-Prozedur selbst, nicht ans Schema: `addresses` hat bewusst kein UNIQUE (der „nur für diese Person"-Split legt wertgleiche Zweitzeilen an), der Import muss deshalb vor jedem Insert über den vorhandenen Suchindex `(postal_code, street, house_number)` nachschlagen und eine bestehende Zeile wiederverwenden. Sonst bekommt jede Familie so viele Adresszeilen wie Mitglieder — genau der Zustand, den das gemeinsame Adressmodell verhindern soll.

Dublettenerkennung beim Import: Nachname + Geburtsdatum beim Kind, Vor- + Nachname bei Erziehungsberechtigten. Die E-Mail trägt dort nicht mehr (`domains/stammdaten.md`, „Geteilte Mailbox").

## Für `wb-backend`

### Art.-9-Spalten-GRANT: Rollenwahl und ORM-Verhalten

- Sobald `backend_runtime` auf `children`/`guardians` kein `SELECT` auf `denomination_id`/`congregation` mehr hat, scheitert jedes Vollobjekt-Laden dieser beiden Tabellen: SQLAlchemy selektiert per Default alle gemappten Spalten, `session.get(Child, id)` läuft in „permission denied for column". Lösung ist klein (`deferred()` auf den beiden Spaltenpaaren oder zwei Mappings), muss aber vor dem ersten Modell dastehen — sonst wird sie unter Zeitdruck durch ein tabellenweites GRANT „gelöst" und der Mechanismus ist weg.
- Zweite, engere Rolle heißt: zweiter Pool oder `SET LOCAL ROLE` in derselben Transaktion, in der ohnehin `SET LOCAL app.actor` gesetzt wird. Letzteres ist der billigere Weg.
- `app.actor` muss ab jetzt ein Präfix tragen (`entra:`/`guardian:`/`system:`) — der Trigger weist alles andere ab. Betrifft den Schreibpfad für interne Nutzer: dort stand bisher die nackte Entra-Object-ID.
