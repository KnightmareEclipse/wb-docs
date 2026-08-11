# Gesundheitsdaten — Fachdomäne

Domäne 9 aus `fachdomaenen.md` Abschnitt 6. Tabellenschema: `domains/gesundheit-schema.sql`, belegt durch `domains/gesundheit-schema-check.sql` (Sollstand 11/11). Die realen Feldlisten stehen in `prozesse.md` Abschnitt 7.2 (Schulvertrag) und 5.2 (Anmeldetag-Checklisten).

Besondere Kategorien nach Art. 9 DSGVO — der Datenbestand mit dem engsten Zugriffsprofil im System. Heute liegt er in einer Excel-Liste beim Sekretariat.

## Sechs Formulare, ein Datenbestand

Derselbe Merkmalssatz wird an sechs Stellen erhoben: auf allen vier Anmeldetag-Checklisten, im Schulvertrag und noch einmal im Hortvertrag. Der Hortvertrag tut das aus einem realen Grund selbst — für ein **externes Hortkind** gibt es keine Schulanmeldung, die den Satz geliefert hätte (`domains/anmeldung.md`, „Betreuungsmodule"). Deshalb hängen die Merkmale am Kind und nicht am Anmeldevorgang; das Prüfskript zeigt ein Kind ohne Eintrittsdatum mit vollständigem Satz.

Der Satz ist außerdem **größer als der Schulvertrag**: die Checklisten ergänzen Seh-/Hörschwäche und therapeutische Maßnahmen samt Behandlungsgrund und -zeitraum. Gebraucht wird er nicht nur bei der Anmeldung, sondern auch als Sammelaktion mitten im Schuljahr.

## Eine Zeile je Merkmal, nicht dreißig Spalten

Die Papierformulare legen eine breite Tabelle nahe — Allergien ja/nein, Art der Allergien, Medikamente ja/nein, welche, Attest, Erlaubnis, und so fort. Gebaut ist stattdessen **eine Zeile je Merkmal mit der Merkmalsart als Werteliste**. Zwei Gründe, beide praktisch:

- Eine weitere Merkmalsart ist ein Datensatz statt einer Migration.
- Das Spalten-GRANT der engeren DB-Rolle greift auf **einer** Tabelle statt auf dreißig Spalten.

Alle sechs Formulare folgen ohnehin demselben Muster, und genau das sind die Spalten: was liegt vor, was ist zu tun, ggf. Behandlungsgrund und -zeitraum, ggf. Attest, ggf. Erlaubnis zur Verabreichung oder Durchführung.

**Kein UNIQUE je Kind und Art:** mehrere Allergien sind der Normalfall, zwei Therapien nebeneinander ebenso.

Drei Formularfelder sind dabei zu einem zusammengefasst, weil sie dasselbe meinen — Beschreibung der Notfallsituation, nicht auszuführende Tätigkeiten und Verabreichungshinweis sind alle die Antwort auf „was ist zu tun oder zu unterlassen".

## Der zweistufige Zugriff ist die eigentliche Konstruktion

- **Den vollen Satz** sehen Sekretariat, Klassenlehrer:in und Hort.
- **Alle unterrichtenden Personen** sehen ausschließlich einen kurzen handlungsrelevanten Hinweis, den die Klassenlehrkraft formuliert: „keine Sprungübungen", „Notfallmedikament im Sekretariat".

Das sind **zwei Spalten mit unterschiedlichem GRANT auf derselben Tabelle**, kein zweites Berechtigungssystem. Ein Fachlehrer braucht die Handlungsregel, nicht die Diagnose — der volle Satz wäre Über-Offenlegung nach Art. 9. Eine echte Fachlehrer-Berechtigung bräuchte ein Unterrichtszuordnungs-Modell, und das lebt in Untis (dauerhaft out of scope).

**Der Hinweis ist deshalb keine Kurzfassung der Anweisung.** Der Unterschied ist nicht die Länge, sondern der Leserkreis: im Hinweis darf keine Diagnose stehen, und wer ihn formuliert, trifft genau diese Entscheidung. Wer die beiden Spalten später „aufräumt" und zusammenlegt, hebt den Art.-9-Schutz auf, ohne es zu merken.

Die sensibelste einzelne Angabe ist der **Behandlungsgrund** — eine Diagnose. Sie teilt das GRANT des vollen Satzes, wird nirgends ausgewertet und nur angezeigt.

Die GRANTs selbst stehen wie bei den Konfessionsspalten nicht im Schema, sondern in `wb-backend/db/init-roles.sh`. Zwei Bedingungen, ohne die die Konstruktion nicht greift: die Laufzeit-Rolle darf **kein** tabellenweites `GRANT SELECT/UPDATE` auf die Merkmalstabelle bekommen, und der Owner der Tabelle darf nicht die Laufzeit-Rolle sein. Das Prüfskript kann das nicht belegen — es läuft als Superuser; belegt wird die Struktur, die den Schutz möglich macht.

## Masernschutznachweis

Gesetzlich verpflichtend (§20 IfSG), auf allen vier Checklisten geprüft — und **nie als Kopie**. Festgehalten werden nur Vorlagedatum und Vorlageart; „hier gehen viele Wege". Es entsteht also gar kein Dokument, und der Nachweis braucht keinen Verweis nach Q2: **die Zeile ist der Nachweis**.

Eigene Tabelle statt einer Merkmalszeile, weil er kein „was liegt vor" und keine Handlungsanweisung hat. Das Kind ist zugleich Primärschlüssel — ein Kind hat genau einen Nachweis oder keinen, ein zweiter wäre eine Dublette. Damit ist die Alltagsabfrage („liegt er vor?") ein Punkt-Lookup, und genau das verlangt die Anforderung, ihn schnell nachprüfen zu können.

## Was hier nicht steht

- **Einwilligung und Unterschrift** des Gesundheitsdatenblatts sind Q1 und Q2 aus dem Anmelde-Schema. Hier stünden sie ein zweites Mal.
- **Die Zeckenentfernung** ist keine Eigenschaft des Kindes, sondern eine Erlaubnis — eine Zustimmung (Q1) mit eigenem Zweck, widerrufbar wie jede andere.
- **Die Geburtsurkunde** ist kein Gesundheitsdatum und bleibt eine reine Q2-Zeile mit Bezug Kind; hier hätte sie das falsche Zugriffsprofil.
- **Diagnose-Codes** (ICD o. ä.). Niemand fragt danach, und ein Code verleitet zu Auswertungen, für die es keine Rechtsgrundlage gibt.
- **Historie.** Ein beendetes Merkmal trägt ein Behandlungsende, ein entfallenes wird gelöscht.

## Anschluss an die anderen Domänen

Das **Attest** zeigt auf die Q2-Dokumentzeile im Anmelde-Schema, statt einen zweiten Dateiverweis aufzumachen: die Datei liegt in SharePoint, und der Lösch-Job muss sie über genau einen Weg finden. Das Prüfskript zeigt beides — das Attest ist über diesen einen Weg auffindbar, und es lässt sich nicht löschen, solange ein Merkmal darauf zeigt.

**Schulbegleitung** ist ein Unterstützungsbedarf und gehört hierher, nicht in ein Freitextfeld der Bewerbung: sie gilt über das Aufnahmeverfahren hinaus und wird im Schulalltag gebraucht — mit diesem Zugriffsprofil, nicht mit dem der Bewerbung.

## Offene Punkte

- Aufbewahrungs- und Löschfristen stehen aus (`TODO.md`). Gesundheitsdaten dürften die kürzeste Frist im System haben, und sie hängt nicht am selben Anker wie die Stammdaten.
- Wer den handlungsrelevanten Hinweis formulieren darf, ist als Rolle noch nicht benannt — fachlich ist es die Klassenlehrkraft, technisch braucht es dafür ein eigenes `GRANT UPDATE` auf genau diese Spalte.
