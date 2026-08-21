# Prompt: den nächsten Prozessblock füllen

Kopieren, `NN` und `NAME` durch den nächsten offenen Prozess aus `soll-prozesse/README.md` ersetzen, absenden. Effort `high`; Thinking anlassen. Alles unter dem Strich ist der Prompt.

---

Wir füllen den Block **NN. NAME**. Er bekommt eine eigene Datei `soll-prozesse/NN-name.md` und ist noch leer. Nur dieser Prozess, kein anderer.

Es gelten `prompts/gemeinsam.md` (die `[A]`-Marke, wie du fragst, wie du mit mir redest) und `CLAUDE.md`. Beides liest du zuerst und ich wiederhole es hier nicht.

## Was du vorher liest

1. **`soll-prozesse/hebel.md`** — vollständig. Das sind die gemeinsamen Hebel und die Standardantworten. Alles, was dort steht, gilt auch hier: nicht wiederholen, sondern verlinken, und nur Abweichungen ausschreiben.
2. **`soll-prozesse/anleitung.md`** — die Schreibregeln, die fünf Fragen, die Vorlage.
3. Den passenden Abschnitt in **`prozesse.md`** — wie es heute läuft, samt real erhobener Felder und bekannter Bruchstellen.
4. **Einen** fertigen Block als Ton- und Flughöhenbeispiel. Einen, nicht alle.
5. **Alle Vormerkungen, die deinen Block nennen:** `grep -n "Vorgemerkt" soll-prozesse/*.md`, dann die Treffer lesen. Sie stehen am Ende des Blocks, aus dem sie stammen, weil dort ihr Zusammenhang steht — gefunden werden sie über die Suche, nicht über die Lesereihenfolge.

## Wie viel gefragt wird

Aus `prozesse.md` und `hebel.md` lässt sich der größte Teil des Blocks füllen, ohne dass ich etwas beitrage — der Entwurf kommt deshalb vor den Fragen.

**Fünf bis zehn Runden sind hier normal und erwünscht**, deutlich mehr als beim Schema: Ein Block trägt Entscheidungen, die kein Dokument hergibt. Lieber einmal mehr gefragt als eine Annahme getroffen, die den ganzen Ablauf trägt.

**Ein Block bekommt seinen Haken erst, wenn kein `[A]` mehr darin steht.**

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

## Der Durchgang danach

Einmal, nach meinem OK zum Block — nicht dreimal. Die vielen Runden liegen vorne bei den Fragen, nicht hinten beim Nachbessern.

- Je Fund **ein Satz Problem, ein Satz Vorschlag**. Keine Fundliste ohne Lösung.
- Berührt ein Fund einen fertigen Block oder `hebel.md`, sag es und zieh es nach meinem OK nach.
- **Nichts vormerken für leere Blöcke** — mit einer Ausnahme: ein Kasten am Blockende, in dem steht, was der anschließende Block zwingend klären muss.
- Danach den Haken in `soll-prozesse/README.md` setzen — vorher prüfen, dass kein `[A]` mehr im Block steht.
