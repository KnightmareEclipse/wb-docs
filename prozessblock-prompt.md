# Prompt: den nächsten Prozessblock füllen

Kopieren, `NN` und `NAME` durch den nächsten offenen Prozess aus `soll-prozesse/README.md` ersetzen, absenden. Alles unter dem Strich ist der Prompt.

---

Wir füllen den Block **NN. NAME**. Er bekommt eine eigene Datei `soll-prozesse/NN-name.md` und ist noch leer. Nur dieser Prozess, kein anderer.

## Was du vorher liest

1. **`soll-prozesse/hebel.md`** — vollständig. Das sind die gemeinsamen Hebel und die Standardantworten. Alles, was dort steht, gilt auch hier: nicht wiederholen, sondern verlinken, und nur Abweichungen ausschreiben.
2. **`soll-prozesse/anleitung.md`** — die Schreibregeln, die fünf Fragen, die Vorlage.
3. Den passenden Abschnitt in **`prozesse.md`** — wie es heute läuft, samt real erhobener Felder und bekannter Bruchstellen.
4. **Einen** fertigen Block als Ton- und Flughöhenbeispiel. Einen, nicht alle.
5. **Alle Vormerkungen, die deinen Block nennen:** `grep -n "Vorgemerkt" soll-prozesse/*.md`, dann die Treffer lesen. Sie stehen am Ende des Blocks, aus dem sie stammen, weil dort ihr Zusammenhang steht — gefunden werden sie über die Suche, nicht über die Lesereihenfolge.

## Reihenfolge: erst der Entwurf, dann die Fragen

**Frag mich nichts, bevor du geschrieben hast.** Aus `prozesse.md` und `hebel.md` lässt sich der größte Teil des Blocks füllen, ohne dass ich etwas beitrage. Also: den vollständigen Block entwerfen, jede offene Entscheidung darin als Annahme markieren, mir den Entwurf zeigen — und **erst danach** die Fragen stellen, die der Entwurf nicht selbst beantworten konnte.

Ich korrigiere lieber an einem konkreten Text als abstrakte Fragen zu beantworten. Entwirfst du in die falsche Richtung, werfen wir den Absatz weg; das ist billiger als eine Fragerunde.

### Das Annahmeformat

Jede Annahme steht **an genau der Stelle, an die sie gehört**, in dieser Form:

> `[A]` Die Frist beträgt 14 Tage. — Alternative: 30 Tage, dann meldet sich kaum jemand nach; Preis: das Sekretariat pflegt länger eine offene Liste.

Regeln dazu:

- Immer `` `[A]` `` in Backticks, damit ich alle mit einer Textsuche nach `[A]` finde und keine übersehe.
- Aussage, dann Alternative, dann Preis — in dieser Reihenfolge, ein Satz je Teil.
- Am Ende deiner Nachricht listest du die Annahmen nummeriert auf, damit ich sie ohne Scrollen beantworten kann.
- **Ein Block bekommt seinen Haken erst, wenn kein `[A]` mehr darin steht.** Bestätigte Annahmen verlieren die Marke und werden normaler Text, gekippte werden ersetzt. `[?]`-Marken bleiben dagegen stehen — die sind für die Leute in der Schule, nicht für mich.

## Wie du fragst

- **Fünf bis zehn Runden sind normal und erwünscht**, höchstens vier Fragen je Runde, nach Gewicht sortiert. Lieber einmal mehr gefragt als eine Annahme getroffen, die den ganzen Ablauf trägt.
- **Nummeriere die Fragen, buchstabiere die Optionen.** „1b, 2a, 3: eigener Vorschlag" ist eine vollständige Antwort. Stichworte genügen immer; frag mich nie nach ganzen Sätzen und lies eine knappe Antwort nicht als Desinteresse.
- Zu jeder Option **ihr Preis**, nicht nur die Empfehlung.
- Was ich nicht beantworten kann, wird eine **`[?]`-Marke mit Adressat**. Nichts ausdenken.
- **Keine konstruierten Randfälle.** Statt „was, wenn genau dieser seltene Fall eintritt" die generelle Regel suchen, die ihn mit abdeckt. Wer durchs Raster fällt, hat eben Glück.
- **Kein Netz gegen Vergessen.** Bleibt ein Vorgang liegen, weil ein Mensch ihn nicht einträgt, ist das kein Befund.
- Kollidieren zwei meiner Antworten, sag es sofort und leg den Konflikt offen.
- Entscheide ich gegen deine Empfehlung: Konsequenz genau einmal nennen, in den Block schreiben, weiterarbeiten.

## Bevor du mir den Entwurf zeigst: die vier Nahtfragen

Sie sagen, worauf du sehen sollst — nicht, dass du nochmal sehen sollst. Jede hat in diesem Projekt schon eine Nacharbeitsrunde gekostet:

1. **Hebel.** Nutzt der Block einen Hebel anders, als er in `hebel.md` steht? Dann gehört die Änderung nach `hebel.md`, nicht in den Block. Braucht er einen neuen? Nur wenn ihn mehr als ein Prozess braucht.
2. **Herkunft.** Entsteht hier etwas, das andere Blöcke nur lesen? Dann sagt dieser Block es, und der andere verweist hierher.
3. **Neuer Zustand.** Erzeugt der Block einen Zustand, den es vorher nicht gab? Geh die fertigen Blöcke durch: greift dort eine Pflicht, eine Frist oder eine Mail für diesen Zustand ins Leere?
4. **Doppelung.** Steht jetzt ein Satz zweimal? Entscheide, welchem Block er gehört, kürze den anderen auf den Verweis.

## Schreiben

- **Handlungen, keine Tabellen- oder Feldnamen.** Aus diesen Dateien wird das Schema abgeleitet, nicht umgekehrt.
- **Keinen Begriff doppelt belegen.** Was anderswo einen Namen hat, heißt hier genauso.
- **Verweise als Link**, nie als bloße Nummer: `[Nachzieh-Aufgabe](hebel.md#nachzieh-aufgabe-und-wochenmail)`, `[03](03-irregulaerer-abgang.md)`.
- **Kein leeres Feld.** „Keine Frist", „keine Mail", „kein Sonderfall" ist eine Antwort, ein leeres Feld nicht.
- Flughöhe 30–60 Zeilen. Wird es deutlich länger, sind es zwei Prozesse.
- **Datei anfassen erst nach meinem OK.** Der Entwurf steht bis dahin in deiner Antwort.

## Wie du mit mir redest

- **Ergebnis zuerst.** Der erste Satz sagt, was rausgekommen ist; die Begründung steht dahinter, für den Fall, dass ich sie brauche.
- **Höchstens ungefähr fünfzehn Zeilen je Antwort** — der Blockentwurf selbst und die Fundliste des Durchgangs sind davon ausgenommen.
- Begründe nur, wo eine Entscheidung daran hängt. Keine Zusammenfassung dessen, was ich gerade gelesen habe.
- Korrigier eine frühere Aussage nur, wenn der Fehler meine Entscheidung ändert. Sonst still richtigstellen und weiter.

## Der Durchgang danach

Einmal, nach meinem OK zum Block — nicht dreimal. Die vielen Runden liegen vorne bei den Fragen, nicht hinten beim Nachbessern.

- Je Fund **ein Satz Problem, ein Satz Vorschlag**. Keine Fundliste ohne Lösung.
- Berührt ein Fund einen fertigen Block oder `hebel.md`, sag es und zieh es nach meinem OK nach.
- **Nichts vormerken für leere Blöcke** — mit einer Ausnahme: ein Kasten am Blockende, in dem steht, was der anschließende Block zwingend klären muss.
- Danach den Haken in `soll-prozesse/README.md` setzen — vorher prüfen, dass kein `[A]` mehr im Block steht.
