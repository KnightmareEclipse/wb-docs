# Prompt: die zwei Fundament-Domänen zur API planen

Ein Durchgang über `stammdaten` und `querschnitt`. Es gilt [`api-planen.md`](api-planen.md)
vollständig — die sechs Angaben je Route, die sieben Fallen, die Gegenprobe in beide Richtungen —
und diese Datei wiederholt nichts davon. Sie trägt drei Dinge, die dort nicht stehen: warum diese
zwei Domänen einen gemeinsamen Lauf bekommen, was zusätzlich zu lesen ist, und die Prüfung, die
diesen Lauf von einem gewöhnlichen unterscheidet.

Kopieren, absenden. Effort `xhigh`, Thinking an. Vorher `git status` sauber.

---

## Warum diese zwei zusammen, und trotzdem nacheinander

Jede andere Fachdomäne lehnt sich an diese beiden: `stammdaten` besitzt Person, Kind, Familie und
Adresse, `querschnitt` die Entitäten Q1–Q5, an denen alle anderen andocken. Wer eine der beiden
allein plant, rät die andere Hälfte — und zwei geratene Hälften treffen sich nicht.

Die Portionierung aus `api-planen.md` bleibt trotzdem: **erst `stammdaten` ganz, dann
`querschnitt` ganz.** Gemeinsam ist der Lauf, nicht der Entwurf. Die Reihenfolge steht fest, weil
`querschnitt` an den Zeilen hängt, die `stammdaten` besitzt, und nicht umgekehrt.

Ergibt der zweite Durchgang, dass der erste falsch lag, **wird die erste Datei geändert** und nicht
mit einem Nachtrag versehen. Eine Datei, die ihren eigenen Widerruf trägt, ist zweimal zu lesen.

## Was du zusätzlich liest

Zu den fünf Punkten aus `api-planen.md` kommen drei:

6. **`grenzkarte.md`** — die entscheidende Datei für `querschnitt`: wem welche Tatsache gehört, was
   Q1 bis Q5 sind, wo die weißen Flecken liegen. Eine Route dieser Domäne, die sich nicht auf eine
   Zeile dort zurückführen lässt, gehört einer anderen.
7. **`api/putzdienst-api.md`** — die einzige Domäne, die schon Routen hat, und sie entstand **vor**
   diesen beiden. Was sie sich selbst gebaut hat, kann dem Fundament gehören.
8. **Der Kopfkommentar jedes übrigen `schema/*.sql`** — nicht die ganze Datei, nur der Kopf. Er sagt,
   was die Domäne von `querschnitt` erwartet. Elf Erwartungen an ein Gelenk, das noch keine Route
   hat, sind die eigentliche Anforderungsliste.

## Die Prüfung, und sie ist die halbe Arbeit

Nicht am Ende, sondern je Domäne, bevor du sie für fertig erklärst. Drei Durchgänge, jeder
mechanisch und keiner aus dem Gedächtnis.

### Gegen das Schema, Spalte für Spalte

Jede Route verspricht etwas: ein Feld zu liefern, eines zu setzen, eine Bedingung zu halten. Für
jedes dieser Versprechen schlägst du die Spalte **nach** — Existenz, Typ, `NOT NULL`, CHECK,
Fremdschlüssel — und nicht nach, was du zu wissen glaubst. Eine Route, die ein Feld optional
anbietet, das die Tabelle als `NOT NULL` führt, ist beim Bau ein Fehler und hier eine Zeile Arbeit.

Fällt dir dabei etwas am Schema auf: eine Zeile ans Ende der Datei, kein Eingriff. Das Schema führt
`wb-backend`.

### Gegen `api/putzdienst-api.md`

Jede Kollision bekommt eine Zeile und genau eine von drei Antworten:

- **bleibt dort** — die Handlung gehört wirklich dem Putzdienst;
- **wandert hierher** — sie gehört dem Fundament, und der Putzdienst hat sie sich nur genommen. Dann
  wird sie dort gestrichen und durch einen Verweis ersetzt, nie doppelt geführt;
- **ist dieselbe Route zweimal** — dann entscheidest du, welchem Block sie gehört, und begründest es.

### Auf Zukunftssicherheit — sieben Fragen

Jede ist eine Prüfung an dem, was du geplant hast, und jede hat eine Antwort, die falsch ist:

1. **Eine neue Fachdomäne kommt dazu — bricht sie eine dieser Routen oder hängt sie sich an?**
   Q1–Q5 sind die Gelenke. Ein Gelenk, das nur seinen heutigen Nutzer kennt, ist keines.
2. **Ein Feld kommt an eine Tabelle — kostet das eine neue Route?** Wenn ja, ist die Route auf
   Felder geschnitten statt auf die Sache, die der Block nennt.
3. **Eine Werteliste wird umbenannt** — genau der Fall, für den `rules.md` Abschnitt 3 die
   Lookup-Tabellen erzwingt. Trägt die Route dann noch, oder macht ein fest verdrahteter Code aus
   einer Zeilenänderung eine Migration?
4. **Eine Rolle kommt dazu oder wird gespalten — welche Routen sind umzuschreiben?** Die Antwort
   soll „keine" sein: Der Ownership-Check ist eine Bedingung über Daten, keine Aufzählung von Rollen.
5. **Die Einsichtsstufe — filtert sie an einer Stelle, oder baut jede Route sie nach?** Nur das
   erste überlebt die nächste Domäne; das zweite ist der Anfang von zwei Fassungen.
6. **Kann ein Vorgang, der heute ein Absenden ist, morgen zwei werden müssen?** Dann ist er heute
   falsch geschnitten — und ihn später zu teilen, zahlt der Mensch am Formular.
7. **Ein Feld verschwindet aus einer Antwort — was passiert?** „Jede Oberfläche bricht" ist keine
   zulässige Antwort. Eine Versionierung auf Vorrat aber auch nicht.

### Was Zukunftssicherheit hier **nicht** heißt

Der Satz, ohne den dieser Abschnitt das Gegenteil bewirkt: **`rules.md` Abschnitt 1 gilt
unverändert.** Das DB-Schema ist die ausgeschriebene Ausnahme von der Ladder — **die API ist es
nicht.** Es entsteht keine Route für eine Domäne, die es noch nicht gibt, kein Feld „für später",
kein Parameter, den heute niemand setzt. Eine Route ohne Zeile in einer Ablauftabelle bleibt
verboten, auch wenn sie zukunftssicher aussieht.

Die sieben Fragen prüfen die **Form** des Geplanten, nie seinen Umfang. Ergibt eine von ihnen, dass
der heutige Schnitt nicht trägt, ist die Antwort **ein anderer Schnitt** — nicht eine Route mehr.

## Was du am Ende lieferst

Was `api-planen.md` verlangt, je Domäne einmal. Dazu je Domäne die drei Prüfungen als drei Listen —
Schema-Kollisionen, `putzdienst`-Kollisionen, Zukunftsbefunde —, jede Zeile mit ihrer Entscheidung.
Eine leere Liste schreibst du als leere Liste hin; „nichts gefunden" ist ein Ergebnis, „nicht
geprüft" wäre eines und darf nicht so aussehen.

Die Dateien `api/stammdaten-api.md` und `api/querschnitt-api.md` legst du erst nach meinem OK an,
wie dort geregelt. Wandert etwas aus `api/putzdienst-api.md` hierher, gehört die Änderung dieser
Datei in dasselbe OK — sie ist keine eigene Runde.

**Kein Code.** Die Routen zu bauen ist der Auftrag danach, und er hat seinen eigenen Durchgang.
