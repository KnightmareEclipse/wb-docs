# Gemeinsam — was für jeden Prompt hier gilt

Was hier steht, gilt für **alle** Prompts in diesem Ordner. Jede Regel steht genau einmal — an
dieser Stelle. Ein Prompt nennt sie beim Namen und schreibt nur aus, was bei ihm anders ist.

`CLAUDE.md` wird in jeder Session automatisch geladen und trägt, was für das ganze Repo gilt: die
Rangfolge bei Widerspruch, die `.sql`/`.md`-Grenze, „eine Regel ohne Gegenprobe gilt als nicht
gebaut", der Podman-Aufruf samt `ON_ERROR_STOP=1` und Ladereihenfolge, keine konstruierten
Randfälle, kein Netz gegen menschliches Vergessen. **Das wird hier nicht wiederholt** — es steht
schon im Kontext, wenn du das hier liest.

## Die `[A]`-Marke

Jede offene Entscheidung steht **an genau der Stelle, an die sie gehört**, in dieser Form — in einer
`.md` als Zeile, in einer `.sql` als Kommentar:

> `[A]` Die Frist beträgt 14 Tage. — Alternative: 30 Tage, dann meldet sich kaum jemand nach; Preis:
> das Sekretariat pflegt länger eine offene Liste.

- Immer `[A]`, damit ich alle mit einer Textsuche finde und keine übersehe.
- **Aussage, dann Alternative, dann Preis** — in dieser Reihenfolge, ein Satz je Teil.
- Am Ende deiner Nachricht listest du sie als `A1, A2 …` auf, damit ich sie ohne Scrollen
  beantworten kann.
- **Annahme und Frage sind nicht dasselbe.** Ein `[A]` ist entschieden und trägt weiter, wenn ich
  schweige; eine Frage hält an. Kannst du unter deiner Annahme weiterbauen, ist es ein `[A]`.
- **Fertig heißt: kein `[A]` mehr in der Datei.** Bestätigte Annahmen verlieren die Marke und werden
  normaler Text, gekippte werden ersetzt.
- **`[?]`-Marken bleiben stehen** — die sind für die Leute in der Schule, nicht für mich, und tragen
  immer ihren Adressaten. Was ich nicht beantworten kann, wird eine solche Marke. Nichts ausdenken.
- **`[A!]` ist dieselbe Marke für einen Schnitt statt eines Feldes** — eine Annahme, an der die
  Grenze einer Datei oder einer Domäne hängt. Sie **verliert ihre Marke auch dann nicht, wenn ich sie
  bestätige**: Ihr Wert ist, dass jeder Prüflauf den Schnitt wieder sieht, und `schema-pruefen.md`
  lässt sich deshalb jede einzeln melden. Bestätigt heißt hier „die Entscheidung steht", nicht „die
  Marke geht weg".

## Wie du fragst

- **Erst der Entwurf, dann die Fragen.** Frag mich nichts, bevor du geschrieben hast: Ich korrigiere
  lieber an einem konkreten Text, als abstrakte Fragen zu beantworten. Entwirfst du in die falsche
  Richtung, werfen wir den Absatz weg; das ist billiger als eine Fragerunde.
- **Höchstens vier Fragen je Runde**, nach Gewicht sortiert, als `F1, F2 …` mit Buchstaben an den
  Optionen. „1b, 2a, 3: eigener Vorschlag" ist dann eine vollständige Antwort. Stichworte genügen
  immer; lies eine knappe Antwort nicht als Desinteresse.
- **Zu jeder Option ihr Preis**, nicht nur die Empfehlung.
- Kollidieren zwei meiner Antworten, sag es sofort und leg den Konflikt offen.
- Entscheide ich gegen deine Empfehlung: Konsequenz genau einmal nennen, an ihre Stelle schreiben,
  weiterarbeiten.

## Wie du mit mir redest

- **Ergebnis zuerst.** Der erste Satz sagt, was rausgekommen ist; die Begründung steht dahinter, für
  den Fall, dass ich sie brauche.
- **Höchstens ungefähr fünfzehn Zeilen Prosa je Antwort**, wo der Prompt es nicht enger setzt. Nicht
  mitgezählt werden der Entwurf selbst, SQL und die nummerierten Listen — die tragen aber **je
  Eintrag genau eine Zeile**, sie sind zum Abhaken, nicht zum Lesen.
- **Kürze nie eine Liste, um ein Budget zu halten.** Ein unterschlagener Fund oder eine
  unterschlagene Annahme kostet mich mehr als zehn Zeilen.
- Begründe nur, wo eine Entscheidung daran hängt. **Keine Zusammenfassung dessen, was ich gerade
  gelesen habe, und keine dessen, was du gerade geschrieben hast** — die Datei steht ja da.
- **Je abgeschlossenem Schritt eine Zeile.** Kein Vorlesen dessen, was du gerade liest, keine
  Ankündigung jedes Schritts, keine Zwischenzusammenfassung. Ich lese den Lauf nicht mit.
- Korrigier eine frühere Aussage nur, wenn der Fehler meine Entscheidung ändert. Sonst still
  richtigstellen und weiter.
- **Kein Schlussabsatz, der das Ergebnis würdigt, keine „nächsten Schritte"**, solange ich nicht
  danach frage. Der nächste Schritt ist, dass ich lese.

## Kein Subagent urteilt

Suchen darf er — eine Fundstelle in einer Datei, ein Spaltenname über alle Dateien. **Nicht
entscheiden, nicht bauen, und nicht nachprüfen, was du selbst geurteilt hast.** Der Grund ist immer
derselbe: Ein zusammengefasster Bericht hat den Satz nicht mehr, gegen den das Zitat gehalten wird,
und das Zitat ist hinterher nicht zu rekonstruieren.
