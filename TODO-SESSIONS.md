# TODO — Offene Punkte für Entwicklungs-Sessions

Fachliche/technische Punkte, die eine Session in diesem Repo oder in `wb-backend` abarbeiten kann — im Unterschied zu `TODO.md`, das reale Konten/Zugänge und organisatorische Vorbereitungen sammelt. Sortiert nach Dringlichkeit.

## Vor dem ersten Import echter Daten

### Import-Prozedur: Nachschlagen statt blind einfügen

Der Vollimport läuft **einmal in eine leere Datenbank**; ein Korrekturlauf heißt „verwerfen und neu laden", und damit ist Idempotenz (`rules.md` Abschnitt 3) erfüllt, ohne dass das Schema etwas dafür tun muss. Ein wiederkehrender maschineller Abgleich existiert in keine Richtung: nach ASV-BW gehen nur Neuanlagen per CSV, die Bankverbindung wandert einmal von Hand nach Optigem, Änderungen laufen in beiden Systemen manuell (`fachdomaenen.md` Abschnitt 4). Deshalb bewusst **kein** Quellsystem-Schlüssel an `children`/`persons`.

Was bleibt, ist eine Anforderung an die Import-Prozedur selbst, nicht ans Schema: `addresses` hat bewusst kein UNIQUE (der „nur für diese Person"-Split legt wertgleiche Zweitzeilen an), der Import muss deshalb vor jedem Insert über den vorhandenen Suchindex `(postal_code, street, house_number)` nachschlagen und eine bestehende Zeile wiederverwenden. Sonst bekommt jede Familie so viele Adresszeilen wie Mitglieder — genau der Zustand, den das gemeinsame Adressmodell verhindern soll.

Dublettenerkennung beim Import: Nachname + Geburtsdatum beim Kind, Vor- + Nachname bei Erziehungsberechtigten. Die E-Mail trägt dort nicht mehr (`domains/stammdaten.md`, „Geteilte Mailbox").

## Für `wb-backend`

### Übertragung nach SQLAlchemy/Alembic: was Modelle nicht können

Tabellen, Spalten, PK/FK/UNIQUE, CHECKs, partielle Indizes und der Ausschluss-Constraint lassen sich als Modell ausdrücken. **Drei Dinge nicht:** die plpgsql-Funktion `set_row_audit()`, die 16 Trigger, die sie anhängen, und die Spalten-GRANTs. Die gehören als `op.execute()` in die Initial-Migration.

Das ist kein Tipparbeits-, sondern ein Sicherheitsproblem: Alembics `--autogenerate` **sieht diese drei gar nicht**. Es meldet nicht, dass sie fehlen, und würde sie bei einem späteren Regenerieren stillschweigend aus der Migration lassen. Damit fiele genau das weg, worauf das Schema am stärksten baut — Audit-Trail und Art.-9-Schutz — ohne eine einzige Fehlermeldung.

Die Doppelung ist dafür überprüfbar statt riskant: `domains/stammdaten-schema-check.sql` und `domains/putzdienst-schema-check.sql` laufen gegen **jede** Datenbank, auch gegen die von Alembic gebaute. Kommen dort 53/53 bzw. 16/16 heraus, ist die Übertragung nachweislich treu. Das gehört als fester Schritt hinter die Initial-Migration, nicht als einmalige Sichtprüfung.

Danach führt `wb-backend` das Schema; die `.sql` in diesem Repo bleibt der Entwurf samt Begründungen und ist nicht mehr die Quelle der Wahrheit.

### Constraint-Namen: `naming_convention` vor dem ersten Modell setzen

`MetaData(naming_convention=...)` in SQLAlchemy vergibt jedem Constraint einen deterministischen Namen aus einer Vorlage. Ohne sie benennt Alembic autogenerierte Constraints unvorhersehbar, und eine spätere Migration kann sie nicht sicher per `ALTER TABLE ... DROP CONSTRAINT` greifen — genau der Fall „im laufenden Betrieb anfassen". Muss stehen, **bevor** das erste Modell entsteht, sonst tragen die früh erzeugten Constraints andere Namen als alle späteren.

Im Entwurfsschema sind bereits die mehrspaltigen CHECKs, der Ausschluss-Constraint und die partiellen Unique-Indizes explizit benannt (`domains/stammdaten-schema.sql`); die Konvention muss diese Namen übernehmen, nicht überschreiben.


### Art.-9-Spalten-GRANT: Rollenwahl und ORM-Verhalten

- Sobald `backend_runtime` auf `children` kein `SELECT` auf `denomination_id`/`congregation` mehr hat, scheitert jedes Vollobjekt-Laden dieser Tabelle: SQLAlchemy selektiert per Default alle gemappten Spalten, `session.get(Child, id)` läuft in „permission denied for column". Lösung ist klein (`deferred()` auf dem Spaltenpaar oder zwei Mappings), muss aber vor dem ersten Modell dastehen — sonst wird sie unter Zeitdruck durch ein tabellenweites GRANT „gelöst" und der Mechanismus ist weg.
- Zweite, engere Rolle heißt: zweiter Pool oder `SET LOCAL ROLE` in derselben Transaktion, in der ohnehin `SET LOCAL app.actor` gesetzt wird. Letzteres ist der billigere Weg.
- `app.actor` muss ab jetzt ein Präfix tragen (`entra:`/`guardian:`/`system:`) — der Trigger weist alles andere ab. Betrifft den Schreibpfad für interne Nutzer: dort stand bisher die nackte Entra-Object-ID.
