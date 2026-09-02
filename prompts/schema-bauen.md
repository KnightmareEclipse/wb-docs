# Prompt: eine Fachdomäne ins Schema überführen

Gegenstück zu [`prompts/block-fuellen.md`](block-fuellen.md). Dort entstehen die Abläufe, hier wird daraus SQL. **Eine Domäne je Durchgang** — dieselbe Portionierung, die sich bei den Blöcken bewährt hat: ein schmaler Auftrag liefert verlässlich besser als ein breiter. Steht das SQL, prüft [`prompts/schema-pruefen.md`](schema-pruefen.md) es gegen die Blöcke — in einer frischen Session, die den Bau nicht mitgemacht hat.

Kopieren, `DOMÄNE` ersetzen, absenden. Alles unter dem Strich ist der Prompt. Effort `high`, bei einer Domäne mit vielen Berührungspunkten `xhigh`; Thinking anlassen.

---

Wir überführen die Fachdomäne **DOMÄNE** ins Datenmodell. Ergebnis ist eine `.sql`-Datei unter `schema/`, aus der später SQLAlchemy-2.0-Modelle und eine Alembic-Migration entstehen. Nur diese Domäne, keine andere — was an ihren Rand stößt, wird benannt und nicht mitmodelliert.

Es gelten [`gemeinsam.md`](gemeinsam.md) (die `[A]`-Marke, wie du fragst, wie du mit mir redest, kein Subagent urteilt) und `CLAUDE.md`. Beides liest du zuerst und ich wiederhole es hier nicht.

**Du baust in einen bestehenden, geprüften Stand hinein.** In `schema/` liegen dreizehn Domänen, aus denselben Blöcken abgeleitet und durch fünf Prüfzyklen gegangen. Das ist kein Vorentwurf, sondern der Bestand: Was dort schon jemandem gehört, referenzierst du und baust es nicht nach. Was du dort ändern müsstest, ist eine Frage an mich und keine stille Korrektur — und der Stammdaten-Freeze (`grenzkarte.md`) gilt ab dem Vollimport für alles, was `schema/stammdaten-schema.sql` berührt.

## Was du vorher liest, und wozu

1. **Alle Blöcke in `soll-prozesse/`, die diese Domäne berühren** — vollständig, nicht überflogen. Sie sind die fachliche Wahrheit: Aus ihnen wird das Schema abgeleitet, nicht umgekehrt. Welche das sind, findest du über die Verweise; im Zweifel einer zu viel.
2. **`soll-prozesse/hebel.md`** — was für alle Prozesse gilt. Ein Hebel, den mehrere Blöcke nennen, ist fast immer **eine** Struktur im Schema und nicht je Block eine.
3. **`rules.md`**, Abschnitt 1 samt der ausdrücklichen **Ausnahme für DB-Schema-Design**, und Abschnitt 7 (Datensparsamkeit). Das sind die Maßstäbe, an denen ich deinen Entwurf messe.
4. **`grenzkarte.md`** — wem welche Tatsache gehört, die Querschnitts-Entitäten Q1–Q5 und die weißen Flecken. Der Domänenschnitt gilt weiter: Wenn deine Domäne etwas braucht, das dort schon jemandem gehört, referenzierst du es und baust es nicht nach. Den Abschnitt zum Stammdaten-Freeze liest du als bindend, nicht als Begründungssammlung.

**Punkte 1 bis 4 liest du selbst** — aus dem Grund, der in `gemeinsam.md` steht.

## Drei Referenzen und der eigene Bestand

**Die drei Referenzen** — ASV-BW (`~/Documents/projectNightmare/ASV-BW/asv_struktur.sql`, der Wert steckt in den `COMMENT ON COLUMN`-Zeilen), SVWS-NRW, GibbonEdu — dienen **einem** Zweck: Randfälle nicht neu zu erfinden. Sie laufen seit Jahren produktiv, ihre Kanten sind echt. Sie sind aber keine Feldquelle: Dass ASV-BW allein im Schülerstamm rund 170 Spalten führt, begründet keine einzige davon bei uns (`rules.md` Abschnitt 7). Ihre Namenskonventionen übernehmen wir ausdrücklich nicht — Gibbons `gibbonPersonID` ist das Gegenbeispiel, nicht das Vorbild. Hier darfst du delegieren: In allen dreien suchst du Fundstellen und Randfälle, keine Zitate, und ASV-BW allein hat sechsstellige Zeilenzahl.

**Der eigene Bestand in `schema/`** ist etwas anderes als eine Referenz — er ist verbindlich, und zwar zweifach:

- **Die Konventionen sind gesetzt.** `schema/stammdaten-schema.sql` zeigt, wie Kommentare, Schlüssel, Constraint-Namen und Begründungen in diesem Projekt aussehen; `schema/querschnitt-schema.sql` zeigt, wie ein Hebel genau einmal gebaut wird. Du folgst ihnen, statt eine zweite Form daneben zu setzen.
- **Präzedenz schlägt Geschmack.** Tragen zwei Bauformen dieselbe Regel, nimm die, die im Bestand schon vorkommt. Eine dritte Form für denselben Sachverhalt ist ein Fund, den der nächste Prüflauf meldet.

Wo du eine Quelle **bewusst nicht** übernimmst, steht der Grund am betroffenen Feld.

## Rangfolge bei Widerspruch — der fünfte Punkt

Die vier Stufen stehen in `CLAUDE.md`. Für diesen Durchgang kommt eine fünfte dazu:

5. **Der gebaute Bestand in `schema/`** schlägt keine Quelle, bindet aber die Form: Er hat nicht recht, weil er dasteht — er gibt nur vor, wie eine Sache hier gebaut wird.

Steht deine Ableitung gegen `grenzkarte.md` oder gegen den Bestand, ist das ein Fund für die Randliste — kein Grund anzuhalten und keine stille Korrektur.

## Wie viel gefragt wird

Aus den Blöcken und der Grenzkarte lässt sich der größte Teil ableiten, ohne dass ich etwas beitrage — der Entwurf kommt deshalb vor den Fragen.

**Zwei bis vier Runden sind hier normal**, deutlich weniger als bei einem Prozessblock, weil das meiste ableitbar ist. **Eine Domäne ist erst fertig, wenn kein `[A]` mehr in der Datei steht.**

## Was du allein entscheidest

Das hier fragst du nicht, das entscheidest du und schreibst höchstens eine `[A]`-Zeile dazu:

- Datentyp, Länge, `NULL`/`NOT NULL`, `DEFAULT`, jede `CHECK`-Bedingung.
- Ob etwas eine eigene Tabelle, eine Spalte oder ein Lookup wird.
- Tabellen- und Spaltennamen, Reihenfolge der Spalten, Indizes.
- Ob ein Sachverhalt aus zwei Blöcken **eine** Struktur wird.
- Welche Constraints die Regeln der Blöcke tragen — „höchstens eine offene Aufgabe je Art und Bezug" ist ein partieller Unique-Index und keine Frage an mich.

## Was du mich fragst

- Wo ein Block schweigt und die Antwort den Schnitt trägt — nicht ein Detail, sondern eine Grenze.
- Wo zwei Blöcke sich widersprechen und die Rangfolge oben nicht greift, weil beide gleich alt sind. Dann Konflikt offenlegen, beide Seiten zitieren.
- Wo eine Ableitung eine Änderung an `soll-prozesse/hebel.md` oder an einem fertigen Block nach sich zöge.

Reichen die Blöcke für eine Entscheidung nicht, sag das, statt zu raten.

## Die Regeln fürs Modell

**Dritte Normalform als Boden, Lesbarkeit als Decke.** 3NF ist einzuhalten: keine Wiederholgruppe, keine partielle Abhängigkeit vom zusammengesetzten Schlüssel, keine transitive Abhängigkeit. Darüber hinaus wird nicht normalisiert, wenn es niemand mehr liest — eine Tabelle, die du mir nicht in einem Satz erklären kannst, ist falsch geschnitten. Performance trägt dabei kein Argument in eine der beiden Richtungen (`rules.md` Abschnitt 1).

**Ein Ort pro Sachverhalt** — vollständig in `rules.md` Abschnitt 1, hier nur die Stelle, an der du sonst stolperst: Ein ableitbarer Wert darf ausnahmsweise zusätzlich stehen, wenn er ein Constraint tragen muss, das über den Ableitungsweg nicht ausdrückbar ist — und bleibt dann per **zusammengesetztem Fremdschlüssel** an sein Original gebunden, damit beide nicht auseinanderlaufen können.

**Schlüssel tragen Namen, keine `id`.**

- Tabellen englisch, `snake_case`, Plural: `families`, `care_module_bookings`.
- Primärschlüssel heißt Singular plus `_id`: `family_id` in `families`. Nie ein blankes `id`.
- Ein Fremdschlüssel heißt **genau wie der Primärschlüssel, auf den er zeigt**. Zeigen zwei Spalten derselben Tabelle auf dieselbe Zieltabelle, trägt die Rolle das Präfix — `payer_person_id`, `confirming_person_id` — und ein Kommentar sagt, warum es zwei gibt.
- `uuid` mit `gen_random_uuid()` für alles mit Personenbezug: Eine fremde Familie darf sich nicht über eine hochgezählte Nummer erraten lassen. `integer`-Identity für Lookups und Organisationstabellen, die nie in einer URL für Externe auftauchen.
- Ein natürlicher Schlüssel wird `UNIQUE`, nie Primärschlüssel — er ändert sich irgendwann, und dann hängen alle Fremdschlüssel daran.
- **Jedes Constraint bekommt einen expliziten Namen**, Muster `pk_`, `fk_`, `uq_`, `ck_`, `ix_` plus Tabelle und Spalten. Das ist kein Schönheitsdienst: Ohne deterministische Namen erzeugt Alembics Autogenerate bei jedem Lauf andere und schlägt beim Downgrade fehl.

**Lookup oder `CHECK`?** Eine Werteliste, die die Schule pflegt oder die wachsen kann, wird eine Lookup-Tabelle mit stabilem Code. Ein Wertepaar, das nicht wachsen kann, wird ein `CHECK` — ein Fremdschlüssel plus Join für zwei Werte ist Aufwand ohne Ertrag.

**Drei Zustände: erteilt, verweigert, nicht gefragt.** Eine Antwort, die ausbleiben kann, braucht drei unterscheidbare Zustände, sonst sieht die vergessene Frage aus wie ein Nein. Wie das gebaut wird — zwei Zeitpunkte, oder ein Zeitpunkt plus ein Anker eine Tabelle weiter —, steht in `grenzkarte.md`; halte dich an die dortige Unterscheidung, statt eine dritte Bauform zu erfinden.

**Jede Tabelle mit Personenbezug nennt ihren Löschanker** — als Kommentar an der Tabelle, ein Satz: woran die Frist rechnet und aus welchem Block der Anker kommt. Die Anker stehen alle schon in den Blöcken; wenn du für eine Tabelle keinen findest, ist das ein Fund und keine Lücke, die du füllst.

## Nachvollziehbarkeit

Zwei verschiedene Dinge, beide verlangt:

**Woher eine Struktur kommt.** Jede Tabelle trägt als erste Kommentarzeile ihre Herkunft: welcher Block sie verlangt und welcher Satz darin, wörtlich zitiert. Jede Spalte, deren Existenz nicht auf den ersten Blick klar ist, trägt ihre Begründung — und **warum eine erwartete Spalte fehlt**, steht als Kommentar an der Tabelle, weil eine nicht existierende Spalte keinen anderen Anker hat. Ohne diese Zeilen schlägt der nächste Durchgang zuverlässig genau das vor, was hier schon verworfen wurde.

**Was im Betrieb mit den Daten geschah.** Die [Änderungsspur](../soll-prozesse/hebel.md#änderungsspur) ist ein Hebel und deshalb **eine** Struktur für alle Domänen — sie wird nicht je Tabelle nachgebaut. Prüfe stattdessen, ob deine Tabellen das tragen, was die Blöcke von ihr verlangen: wer, wann, was vorher dastand, und der Lauf als Urheber bei maschinellen Änderungen.

## Verständlichkeit

Das Schema wird von Menschen abgenommen, die es nicht gebaut haben. Deshalb:

- Die Datei beginnt mit einem **Lesepfad**: drei bis fünf Sätze, welche Tabellen man zuerst versteht und in welcher Reihenfolge der Rest daran hängt.
- Bezeichner sind englisch, Kommentare deutsch — so steht es im Bestand, und zwei Sprachen im selben Namen wären schlimmer als eine falsche.
- Keine Abkürzung, die nicht im [Glossar](../glossar.md) steht. Was in den Blöcken einen Namen hat, heißt hier genauso.
- Nichts, was SQLAlchemy nicht sauber ausdrücken kann: keine Datenbank-Trigger, keine Stored Procedures, keine Regel, die nur in der Datenbank lebt und im Code unsichtbar ist.

## Länge

Du neigst zu langen Ausgaben, und in einer Schemadatei fällt das nicht auf, bis niemand sie mehr liest. Die Budgets zählen deshalb **Sätze und nicht Zeilen**: Eine SQL-Zeile trägt drei Wörter, eine Kommentarzeile fünfzehn — ein Zeilenmaß behandelt beide gleich und ist damit dreimal großzügiger, als es klingt.

- **Spaltenkommentar: ein Satz, höchstens zwei.**
- **Tabellenkommentar: höchstens drei Sätze** — Herkunft, Löschanker, bewusst fehlende Spalten. Das sind die drei aus „Nachvollziehbarkeit"; mehr trägt eine Tabelle nicht.
- **Kopf und Lesepfad zusammen: höchstens fünf Sätze.** Was mehr braucht, ist ein Modell über mehrere Tabellen und gehört in die `.md`.
- **Ein Kommentar sagt nur, was im SQL nicht schon steht.** `-- Pflichtfeld` über einem `NOT NULL` ist eine verlorene Zeile, `-- nullable` über einer Spalte ohne `NOT NULL` genauso. Der Test: Kannst du nicht benennen, was ein Leser ohne diesen Satz falsch machen würde, schreibst du ihn nicht — er ist zugleich der Filter dafür, welche Spalte überhaupt eine Begründung bekommt.
- **Ein Grund steht einmal.** Gilt er für mehrere Spalten, steht er an der Tabelle, und die Spalten verweisen mit drei Worten darauf, statt ihn zu wiederholen.
- **Wird eine Begründung länger als das Feld, das sie erklärt**, ist sie kein Spaltenkommentar mehr: ab in die `.md`, und die `.sql` verweist. Das ist dieselbe Grenze wie oben, nur von der Länge her gedacht.

Kollidiert ein Budget mit der Nachvollziehbarkeit, gewinnt die Nachvollziehbarkeit — und der Überhang geht in die `.md`, nicht in eine längere `.sql`.

## So sieht eine fertige Tabelle aus

```sql
-- Herkunft: 13 (M365-Kontenverwaltung) — „Neu ist der Mitarbeitendeneintrag:
-- Name und Haus (Pflicht) …". Löschanker: last_working_day; ab ihm rechnet der
-- Lösch-Lauf (Block 17), und ab ihm enden die Rollen von selbst (hebel.md).
-- Bewusst KEINE Spalten für Vertrag, Gehalt, Urlaub: Block 13 grenzt die
-- Personalverwaltung im eigentlichen Sinn ausdrücklich aus.
CREATE TABLE employees (
    employee_id       uuid    NOT NULL DEFAULT gen_random_uuid(),
    person_id         uuid    NOT NULL,
    -- Schule oder KITA. Trägt zwei Entscheidungen: die Domain des M365-Kontos
    -- und ob die Familie bei Putzdienst (01) und Elternbonus (14) ausgenommen
    -- ist — die KITA ist ein eigener Betrieb und zählt dort nicht mit.
    house_id          integer NOT NULL,
    -- Spiegelt den Tenant und wird allein vom Admin gepflegt (Block 13). Sie
    -- entsteht erst mit dem Konto; am leeren Feld ist ablesbar, dass es fehlt.
    school_email      text,
    first_working_day date,
    last_working_day  date,

    CONSTRAINT pk_employees            PRIMARY KEY (employee_id),
    CONSTRAINT fk_employees_person     FOREIGN KEY (person_id) REFERENCES persons (person_id),
    CONSTRAINT fk_employees_house      FOREIGN KEY (house_id)  REFERENCES houses (house_id),
    CONSTRAINT uq_employees_school_email UNIQUE (school_email),
    CONSTRAINT ck_employees_working_days
        CHECK (last_working_day IS NULL OR first_working_day IS NULL
               OR last_working_day >= first_working_day)
);
```

## Was du lieferst

**Datei anfassen erst nach meinem OK.** Bis dahin steht alles in deiner Antwort, nichts auf der Platte.

1. **Den Entwurf für `schema/<domäne>-schema.sql`.** Vollständig, so wie oben: kein Auszug, keine Auslassungszeichen, keine „hier analog weiter"-Stelle. `<domäne>` ist der kurze deutsche Kleinbuchstabenname (`mensa`, `putzdienst`, `klassenorganisation`).
2. **Die Randliste** (siehe unten) als eigener Abschnitt deiner Antwort, nie in der Datei.
3. **Erst nach meinem OK zum Schema: das Prüfskript** `schema/<domäne>-schema-check.sql` mit Sollstand im Kopfkommentar. Es prüft, ob jede Tabelle existiert und jedes Constraint greift, und belegt jede Regel aus den Blöcken, die im Schema stehen soll, mit einem fehlschlagenden `INSERT` — eine Regel ohne Gegenprobe gilt als nicht gebaut. Lauf es gegen eine Wegwerf-Datenbank, wenn du eine Postgres-Instanz hast; sonst sag, dass es ungeprüft ist. Vorher schreibst du es nicht: ein Prüfskript zu einem Entwurf, der sich noch ändert, schreibst du zweimal.

## Die Randliste

Deine Domäne stößt an dreizehn gebaute. Was dabei über ihren Rand hinausreicht, kommt auf diese Liste statt in den Entwurf — je Eintrag eine Zeile: was du gefunden hast, wo, dein Vorschlag.

Darauf gehört genau dreierlei:

- **Eine fremde Tabelle müsste sich ändern**, damit deine Domäne trägt — eine Spalte, ein Constraint, ein Fremdschlüssel. Bau das nicht, auch nicht „nur eben".
- **Ein Sachverhalt steht nach deinem Entwurf an zwei Orten** — bei dir und in einer bestehenden Domäne oder einer Querschnitts-Entität aus `grenzkarte.md`.
- **Ein Block verlangt etwas, das im Bestand fehlt** — dann ist die Lücke dort und nicht bei dir.

Nicht darauf gehört, dass du anders schneidest oder benennst, als du es anderswo gemacht hättest: Das ist Handwerk und entscheidest du selbst.

## Drei Listen, drei Präfixe

Annahmen `A1, A2 …`, Fragen `F1, F2 …`, Randliste `R1, R2 …`. Dann ist „A3 ja, F1b, R2 so lassen" eine vollständige Antwort, und ich muss nicht dazuschreiben, welche Liste ich meine. SQL zählt nie ins Zeilenbudget, weder der Entwurf noch ein Ausschnitt daraus.

## Bevor du mir den Entwurf zeigst

Vier Nähte, jede hat in diesem Projekt schon eine Nacharbeitsrunde gekostet. Sie sagen, worauf du sehen sollst — **melde davon nur, was etwas ergeben hat.** „Geprüft, nichts gefunden" schreibst du nicht.

1. **Doppelter Ort.** Steht irgendein Sachverhalt an zwei Stellen — auch in einer anderen Domäne oder in einer Querschnitts-Entität aus `grenzkarte.md`?
2. **3NF.** Gibt es eine Spalte, die von etwas anderem als dem ganzen Primärschlüssel abhängt?
3. **Herkunft.** Trägt jede Tabelle ihren Block und ihren Löschanker, und jede nicht offensichtliche Spalte ihre Begründung?
4. **Lesbarkeit.** Kannst du jede Tabelle in einem Satz erklären, und trägt der Lesepfad am Kopf der Datei wirklich?
