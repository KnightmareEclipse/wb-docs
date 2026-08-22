# Prompt: das Schema auf Normalform prüfen

Ein Durchgang über alle vierzehn Dateien in `schema/`, mit **genau einer** Frage: Steht jedes
Nicht-Schlüsselfeld voll und unmittelbar an seinem Schlüssel? Das ist nicht
[`prompts/schema-pruefen.md`](schema-pruefen.md) — der prüft das Schema gegen die Blöcke, dieser
prüft es gegen sich selbst. Wer beide Fragen in einem Lauf stellt, beantwortet keine.

**Der Prüfer baut nicht.** Er meldet, und ich entscheide; erst nach meinem OK wird etwas geändert.

Effort `xhigh`, Thinking an. Vorher `git status` sauber: Der Lauf legt genau eine Datei an,
`pruefberichte/normalform.md`, und ändert sonst nichts. Alles unter dem Strich ist der Prompt.

---

Es gelten [`gemeinsam.md`](gemeinsam.md) (wie du mit mir redest, kein Subagent urteilt) und
`CLAUDE.md`. Beides liest du zuerst und ich wiederhole es hier nicht.

Geprüft wird `schema/*.sql`. Du änderst nichts — auch nicht „nur eben das eine Feld".

## Was gesucht wird, und in dieser Reihenfolge

1. **1NF** — ein Feld, das mehr als einen Wert trägt: eine Komma- oder Semikolonliste, ein
   Freitext, aus dem regelmäßig etwas herausgelesen wird, ein `text`, in dem ein Datum und ein Grund
   in einem Satz stehen. Der letzte Fall ist hier ausdrücklich **erlaubt**, wo ein Block ihn so
   verlangt („ein Enddatum und einen Grund in einem Satz", Block 09) — dann ist der Satz die Angabe
   und nicht ihre Verpackung. Ein Fund ist er, wo etwas daraus **ausgewertet** wird.
2. **2NF** — bei jedem zusammengesetzten Schlüssel: hängt jedes Nicht-Schlüsselfeld an **beiden**
   Teilen? Ein Feld, das schon aus dem halben Schlüssel folgt, gehört eine Tabelle höher.
3. **3NF** — die eigentliche Frage: Folgt ein Nicht-Schlüsselfeld aus einem anderen
   Nicht-Schlüsselfeld statt aus dem Schlüssel? Das ist die transitive Abhängigkeit, und sie ist
   hier die einzige Klasse, die im Betrieb wirklich weh tut: zwei Orte für eine Tatsache, die
   auseinanderlaufen können.
4. **BCNF nur, wo es beißt.** Eine Abweichung, die nur bei überlappenden Kandidatenschlüsseln
   auftritt und keinen realen Fall erzeugt, ist keine Meldung wert. Kommt sie vor, steht sie in der
   zweiten Liste unten, nicht bei den Funden.

## Die Ausnahme, die dieses Schema bewusst führt

Zwei Muster sehen wie ein 3NF-Verstoß aus und sind hier **entschieden**. Sie werden nicht gemeldet:

- **Das mitgeführte Kennzeichen samt zusammengesetztem Fremdschlüssel.** `applications.is_final`
  steht auch an `application_statuses`, `consents.requires_child` auch an `consent_purposes`,
  `health_traits` trägt vier Flags seiner Merkmalsart. Das ist Redundanz, und sie ist genau deshalb
  da: Ein `CHECK` sieht nur seine eigene Zeile, Trigger gibt es in diesem Schema nirgends, also muss
  der Wert **in** der Zeile stehen, damit eine Regel auf ihn verzweigen kann. Auseinanderlaufen kann
  er nicht, weil der Fremdschlüssel beide Spalten zusammenhält (`rules.md` Abschnitt 1).
- **Die festgehaltene Tatsache statt der abgeleiteten.** `outbound_emails.recipient_email` ist
  bewusst nicht `persons.email`, `consents.delivery_address` bewusst nicht ableitbar, ein gezahlter
  Betrag bewusst der von damals. Das ist keine Abhängigkeit, sondern ein Zeitpunkt: Der Wert **war**
  so, und die Quelle darf sich seither geändert haben.

**Daraus folgt das schärfste Kriterium dieses Laufs**, und es ist das, wonach du wirklich suchst:

> Eine mitgeführte Spalte **ohne** den Fremdschlüssel, der sie festhält, ist ein Fund — auch wenn
> heute niemand sie ändert. Eine festgehaltene Tatsache **ohne** den Satz am Feld, der sagt, dass
> sie festgehalten ist, ebenfalls: dann ist nicht unterscheidbar, ob sie Absicht war oder eine
> vergessene Ableitung.

Und die Gegenrichtung, weil sie hier billiger ist als anderswo: **Eine Abweichung, die alles
erleichtert, ist erlaubt — aber nicht stumm.** Steht der Preis nicht am Feld, ist das ein Fund, auch
wenn die Abweichung richtig ist. Der Kommentar am Artefakt trägt, was gilt (`CLAUDE.md`).

## Wie du läufst

Aufruf, `ON_ERROR_STOP=1` und Ladereihenfolge stehen in `CLAUDE.md`. Lies nicht nur, sondern frag
den Katalog — er ist hier die verlässlichere Quelle als vierzehn Dateien im Gedächtnis:

1. **Alle `schema/*.sql` in eine Wegwerf-Datenbank.**
2. **Die Kandidatenschlüssel je Tabelle** aus `pg_constraint` (`p` und `u`) ziehen. Ohne sie ist
   „hängt am Schlüssel" nicht zu beantworten, und eine Tabelle ohne einen zweiten Kandidaten ist
   nicht dieselbe Frage wie eine mit dreien.
3. **Die zusammengesetzten Fremdschlüssel** ziehen — das ist die Liste der bewusst mitgeführten
   Spalten. Was dort auftaucht, ist entschieden.
4. **Die Spaltennamen, die in mehr als einer Tabelle vorkommen**, ziehen und einzeln ansehen. Das
   ist der mechanische Weg zur Redundanz; die meisten Treffer sind zwei Sachverhalte mit demselben
   Namen, die wenigen anderen sind der Ertrag dieses Laufs.
5. **Danach erst lesend**, je Domäne, gegen die Kommentare.

Geht der Ladelauf nicht, sag es einmal am Anfang und prüf trotzdem lesend durch.

## Der Lauf überlebt seinen eigenen Kontext

Vierzehn Schemadateien sind mehr, als in ein Fenster passt. Deshalb liegt **kein Fund in deinem
Gedächtnis**: Eine Domäne wird abgeschlossen, bevor die nächste anfängt, Funde gehen sofort in
`pruefberichte/normalform.md` unter eine eigene Überschrift, und wo du stehst, sagt die Datei und
nicht deine Erinnerung. Fang nach einer Zusammenfassung bei der ersten Domäne an, die dort noch
keine Überschrift hat. Den Schlussbericht erzeugst du aus der Datei.

Die vier Katalogabfragen oben laufen **einmal am Anfang**, und ihr Ergebnis schreibst du in den Kopf
der Datei — dann steht es dir auch nach der dritten Zusammenfassung noch zur Verfügung.

## Was ein Fund tragen muss

```
[N1] 3NF · anmeldung · applications.target_school_year
Folgt aus `admission_day_id` (der Anmeldetag trägt dasselbe Zielschuljahr);
kein zusammengesetzter Fremdschlüssel hält beide zusammen, ein Verschieben des
Tages lässt sie auseinanderlaufen.
Vorschlag: das Jahr in den Fremdschlüssel aufnehmen.
Berührt Stammdaten: nein.
```

- **Die verletzte Normalform** und die **funktionale Abhängigkeit im Klartext** — „X folgt aus Y",
  nicht „ist redundant".
- **Der reale Fall**, in dem die zwei Orte auseinanderlaufen. Findest du keinen, ist es kein Fund,
  sondern eine Zeile in der zweiten Liste. Konstruierte Randfälle zählen nicht (`CLAUDE.md`).
- **Ein Vorschlag**, ein Satz, nicht gebaut.
- **Berührt Stammdaten: ja/nein.** Ab dem Vollimport ist eine Änderung dort eine Migration auf
  echten Personendaten (`grenzkarte.md`, Freeze) — das entscheidet über die Dringlichkeit und nicht
  über die Richtigkeit.
- **Eine Nummer**, `[N1]`, `[N2]`, … durchlaufend über den ganzen Bericht, auch nach dem Sortieren
  nach Gewicht. Sie ist der Griff, an dem ich den Fund anfasse.

**Erst sammeln, dann sortieren.** Was dir auffällt, kommt in die Datei; aussortiert wird am Ende in
einem eigenen Durchgang. Der Bericht hat deshalb **zwei Listen** — die zweite macht sichtbar, was du
angesehen und entkräftet hast:

```
Angesehen, nicht als Fund gewertet
querschnitt · `consents.requires_child` steht auch an `consent_purposes` —
        `fk_consents_purpose` hält beide zusammen, entschieden in rules.md 1.
stammdaten · `countries.nationality_name` folgt nicht aus `name`: „Deutschland"
        gäbe „deutschländisch", die Bezeichnung ist eine eigene Tatsache.
```

## Was du nicht tust

- **Nichts ändern außer `pruefberichte/normalform.md`.** Keine `.sql`, kein Prüfskript, kein
  Modell in `wb-backend`, kein Commit. Das Schema führt inzwischen `wb-backend` (`CLAUDE.md`); eine
  Strukturänderung beginnt dort als Migration und nicht hier als Korrektur.
- **Keinen `pruefberichte/NN.md` lesen** und auch nicht `pruefberichte/aktuell.md`, falls sie
  dasteht. Ein Fund, den du unabhängig wiederfindest, wiegt schwer — das merkst du aber nur, wenn du
  ihn nicht vorher gelesen hast.
- **Die Blöcke nicht gegenprüfen.** Ob eine Spalte fachlich richtig ist, fragt
  [`schema-pruefen.md`](schema-pruefen.md). Hier zählt allein, ob sie an der richtigen Tabelle
  hängt. Lies einen Block nur, wo du die Bedeutung zweier gleichnamiger Spalten sonst nicht
  auseinanderhältst.
- **Den Marken `[A]`, `[A!]` und `[?]` nicht widersprechen.** Sie sind bewusst offen.
- **Nicht anhalten und nicht fragen.** Wo dir etwas fehlt, um zu urteilen, wird das eine Zeile im
  Bericht — ich sitze nicht daneben.

## Zwischenmeldungen und Schluss

Je abgeschlossener Domäne eine Zeile: Name, Zahl der Funde. Am Ende ist der Bericht die Datei plus
höchstens zehn Zeilen Prosa drumherum; die beiden Listen zählen nicht mit. Dazu eine Zeile, welche
Domänen ohne Fund durchgekommen sind, und **eine Aussage zum Ganzen**: Ist das Schema in 3NF, bis
auf die benannten Ausnahmen — ja oder nein, und wenn nein, welche Funde dem im Weg stehen.
