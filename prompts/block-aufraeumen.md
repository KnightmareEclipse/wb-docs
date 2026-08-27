# Prompt: einen Soll-Block aufräumen

Kopieren, `NN-name` durch den Block ersetzen, absenden. Ein Block je Durchgang. Effort `high`;
Thinking anlassen. Alles unter dem Strich ist der Prompt.

---

Wir räumen **`soll-prozesse/NN-name.md`** auf. Nur diesen, keinen anderen.

Es gelten `prompts/gemeinsam.md` und `CLAUDE.md`; beides liest du zuerst und ich wiederhole es hier
nicht.

## Der Auftrag

Du **brichst den Block um, du schreibst ihn nicht neu.** Sein Inhalt ist abgestimmt und durch fünf
Prüfzyklen gegangen — seine Struktur nicht: Die dreizehn Abschnitte stehen als fette Absatzmarken
statt als Überschriften, und ein Absatz trägt bis zu 5779 Zeichen. Beides kostet einen Menschen die
Übersicht und dich die Sicherheit, weil du Struktur rekonstruieren musst, statt sie abzulesen.

**Wortgleich ist das Abnahmekriterium.** Der Block sagt hinterher dasselbe mit denselben Wörtern, in
sichtbarer Gliederung.

## Die vier Umformungen

1. **Fette Abschnittsmarke → Überschrift.** Aus `**Auslöser** — Text` wird `## Auslöser`, der Text
   dahinter beginnt als Absatz. Die Reihenfolge der Abschnitte bleibt, wie sie ist.
2. **Aufzählung im Fließtext → Liste.** Wo ein Satz mehrere gleichrangige Fälle mit Semikolon oder
   Klammern aneinanderreiht, wird jeder Fall ein Listenpunkt. Sein Wortlaut wandert mit.
3. **Gleichförmige Daten → Tabelle.** Module, Fristen, Staffeln, Beträge — was dieselben Spalten
   trägt, gehört in eine Tabelle.
4. **Begründung, die den Ablauf verdeckt → `> [!note]- Titel`.** Ein zugeklappter Callout; der Titel
   sagt die Frage, der Rumpf trägt den Wortlaut unverändert. Sparsam: was den Ablauf trägt, bleibt
   offen stehen.
5. **Die Schreibanweisung unter der Ablauf-Tabelle fällt weg** — der Absatz, der mit „Die letzte
   Spalte ist die wichtigste" beginnt. Sie steuert das Schreiben eines Blocks und steht dafür in
   `soll-prozesse/anleitung.md`; im ausgefüllten Block ist sie eine Kopie. Das sind 26 Wörter, die
   in der Wortprobe erscheinen und in die Meldung gehören.

## Der Ablauf

1. **Den Block ganz lesen.** Eine Zeile am Stück, nie beschnitten: `awk 'NR==20' datei.md` oder
   `sed -n '20p' datei.md | fold -w 118 -s`. Eine Tabellenzelle geht bis 1163 Zeichen — was du mit
   `substr`, `cut` oder `head -c` liest, hat einen Rest, den du hinterher erfindest.
   *Fertig, wenn:* jede Zeile des Blocks einmal ganz auf dem Schirm stand.
2. **Umbrechen** nach den vier Umformungen oben.
   *Fertig, wenn:* keine fette Abschnittsmarke mehr am Zeilenanfang steht.
3. **Die Wortprobe laufen lassen** (unten).
   *Fertig, wenn:* die Differenzliste steht und du zu jedem Eintrag darauf sagen kannst, warum.
4. **Melden:** die Kennzahlen (Überschriften, längster Absatz, Listenpunkte, Tabellen, Callouts —
   vorher/nachher) und die Differenzliste, vollständig.

## Was in eine Tabellenzelle gehört

Nur, was der Block sagt. **Eine leere Zelle heißt „steht hier nicht"** und ist die richtige Antwort,
wo der Text schweigt. Eine Tabelle verlangt nach vollen Spalten, und genau darin liegt ihre Gefahr:
Aus „Frühbetreuung" wird sonst „Frühbetreuung, vor Schulbeginn" — plausibel, hergeleitet, falsch.
Steht die Angabe in `prozesse.md`, gehört sie trotzdem nicht hierher: der Soll-Block trägt das Soll.

## Die Wortprobe

```python
import re, collections, sys
def worte(p):
    t = open(p, encoding='utf-8').read()
    t = re.sub(r'^#+ ', '', t, flags=re.M)          # Überschriftenmarken
    t = re.sub(r'^\s*[-*]\s+', '', t, flags=re.M)   # Listenpunkte
    t = re.sub(r'^>\s?', '', t, flags=re.M)         # Callout-Marken
    t = re.sub(r'\[!\w+\]-?', '', t)                # Callout-Typ
    return collections.Counter(w.lower() for w in
        re.findall(r'[\wÄÖÜäöüß0-9€%]+', t.replace('*','').replace('|',' ')))
a, n = worte(sys.argv[1]), worte(sys.argv[2])       # alt, neu
print('verloren:', sum((a-n).values()), dict((a-n).most_common(20)))
print('dazu:    ', sum((n-a).values()), dict((n-a).most_common(20)))
```

Aufruf gegen die Fassung aus `git show HEAD:soll-prozesse/NN-name.md` und die neue.

**Zwei Sorten Differenz sind erlaubt, beide gehören in die Meldung:**

- **Verbindungswörter dürfen fallen.** Aus „Dazu die Betreuungsliste" wird im Listenpunkt „Die
  Betreuungsliste" — das „Dazu" verband einen Fließtext, den es nicht mehr gibt.
- **Callout-Titel und Zwischenüberschriften kommen dazu.** Sie beschriften, was darunter steht, und
  sind die einzigen Wörter, die du selbst schreiben darfst.

Jede andere Differenz ist ein Fund: Du hast etwas rekonstruiert statt gelesen. Dann holst du die
Stelle aus dem Original zurück, im Wortlaut.

## Was unberührt bleibt

- Die **Ablauf-Tabelle** samt ihren Zellen — sie ist bereits Struktur.
- Die **`[?]`-Marken** und die **Vormerkung** am Blockende.
- Die **Reihenfolge** der Abschnitte und die **Verweise** — jeder Anker `hebel.md#…` bleibt, wie er
  ist, und keiner kommt dazu.
- Der **Ton**. Ein Satz, der dir zu lang vorkommt, bleibt zu lang.
