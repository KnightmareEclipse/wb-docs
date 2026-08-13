# Gesundheitsdaten — Fachdomäne

Domäne 9 aus `fachdomaenen.md` Abschnitt 6. Tabellenschema: `domains/gesundheit-schema.sql`, belegt durch `domains/gesundheit-schema-check.sql` (Sollstand 11/11). Die realen Feldlisten stehen in `prozesse.md` Abschnitt 7.2 (Schulvertrag) und 5.2 (Anmeldetag-Checklisten).

Besondere Kategorien nach Art. 9 DSGVO — der Datenbestand mit dem engsten Zugriffsprofil im System. Heute liegt er in einer Excel-Liste beim Sekretariat.

## Heute sechs Formulare, künftig eine Erhebung je Kind

Auf Papier wird derselbe Merkmalssatz an sechs Stellen erhoben: auf allen vier Anmeldetag-Checklisten, im Schulvertrag und noch einmal im Hortvertrag. **In Weltenbaum wird er genau einmal je Kind eingesammelt, nicht je Vertrag** — ein Grundschul- oder Realschulvertrag sticht den Hortvertrag aus, und nur ein **externes Hortkind** liefert den Satz über den Hortvertrag, weil es keine Schulanmeldung gibt, die ihn geliefert hätte (`domains/anmeldung.md`, „Betreuungsmodule").

Genau deshalb hängen die Merkmale am **Kind** und nicht am Anmeldevorgang; das Prüfskript zeigt ein Kind ohne Eintrittsdatum mit vollständigem Satz. Folge, die man mitentscheidet: der Hort bekommt den Satz, den die Schule erhebt — er fragt nicht eigene Merkmale nach.

**Ausgefüllt wird der Bogen von den Eltern selbst.** Das Sekretariat überträgt ihn nicht vom Papier, außer im Ausnahmefall — und das ist der Grund, warum die Verabreichungserlaubnis über die Audit-Spalte tatsächlich der erteilenden Person zuzuordnen ist (siehe unten).

Der Satz ist **größer als der Schulvertrag**: die Checklisten ergänzen Seh-/Hörschwäche und therapeutische Maßnahmen samt Behandlungsgrund.

## Eine Zeile je Merkmal, nicht dreißig Spalten

Die Papierformulare legen eine breite Tabelle nahe — Allergien ja/nein, Art der Allergien, Medikamente ja/nein, welche, Attest, Erlaubnis, und so fort. Gebaut ist stattdessen **eine Zeile je Merkmal mit der Merkmalsart als Werteliste**. Zwei Gründe, beide praktisch:

- Eine weitere Merkmalsart ist ein Datensatz statt einer Migration.
- Das Spalten-GRANT der engeren DB-Rolle greift auf **einer** Tabelle statt auf dreißig Spalten.

Alle sechs Formulare folgen ohnehin demselben Muster, und genau das sind die Spalten: was liegt vor, was ist zu tun, ggf. Behandlungsgrund, ggf. Attest, ggf. Erlaubnis zur Verabreichung oder Durchführung.

## Was hier steht, gilt

Es gibt **keinen Behandlungszeitraum**, obwohl die Checklisten ihn bei therapeutischen Maßnahmen real erheben. Ein Merkmal, das nicht mehr zutrifft, wird **gelöscht** statt mit einem Enddatum versehen; eine zurückgenommene Erlaubnis wird zur Ablehnung umgesetzt statt ein Widerrufsfeld zu bekommen (siehe unten).

Das ist die einzige Stelle, an der Datensparsamkeit die Schema-Ausnahme aus `rules.md` Abschnitt 1 schlägt, und der Grund gilt nur für Art. 9: ein „bis"-Datum entfernt die Zeile nicht, es behauptet nur, dass sie abgelaufen ist. Weil kein Abnehmer danach filtert, stünde der breit sichtbare Hinweis einer längst beendeten Therapie weiterhin allen unterrichtenden Personen vor Augen — ein Datum, das niemand liest, ist bei besonderen Kategorien schlechter als keines, weil es den Anschein einer Bereinigung erzeugt, die nicht stattfindet.

**Was das Löschen auslöst, ist damit offen — und das ist der Preis dieser Entscheidung, nicht ihr Widerspruch.** Erhoben wird einmal je Kind, eine wiederkehrende Sammelaktion gibt es nicht (die eine war einmalig und kommt nur bei einer grundlegend neuen Frage an alle Schüler wieder). Die Merkmale ändern sich also nur, wenn Eltern es melden. Ein Enddatum hätte daran nichts geändert — es hätte die Zeile ebenso wenig entfernt —, aber es bleibt: ohne turnusmäßigen Anlass steht eine beendete Therapie so lange, bis jemand von sich aus etwas sagt. Als **akzeptiertes Risiko** benannt (`rules.md` Abschnitt 5); der naheliegende Anker wäre der Eltern-Selfservice (Domäne 8), wo Eltern ihren eigenen Satz sehen und korrigieren — dann ist die Bereinigung dieselbe Handlung wie die Pflege. Siehe „Offene Punkte".

**Kein UNIQUE je Kind und Art:** mehrere Allergien sind der Normalfall, zwei Therapien nebeneinander ebenso.

Drei Formularfelder sind dabei zu einem zusammengefasst, weil sie dasselbe meinen — Beschreibung der Notfallsituation, nicht auszuführende Tätigkeiten und Verabreichungshinweis sind alle die Antwort auf „was ist zu tun oder zu unterlassen".

**Die Verabreichungserlaubnis trägt drei Zustände in zwei Spalten** (`permission_granted_at`, `permission_declined_at`, CHECK: nie beides): erteilt, ausdrücklich verweigert, nicht beantwortet. Mit nur einem Zeitpunkt fielen die letzten beiden zusammen, und die Vollständigkeitsprüfung des Sekretariats könnte bei einem Kind mit Notfallmedikament ohne Erlaubnis nicht entscheiden, ob nachzufassen ist. Dieselbe Bauform wie `consents` — bewusst kein Boolean (verlöre den Zeitpunkt und damit den Nachweis nach Art. 7 Abs. 1 DSGVO) und keine Werteliste (Fremdschlüssel und Join für ein Paar, das nicht wachsen kann; `rules.md` Abschnitt 3 nimmt reine Ja/Nein-Merkmale von der Lookup-Regel aus).

Dass die Spalte den dritten Zustand **selbst** tragen muss, ist die Ausnahme und nicht die Regel: anderswo steht der Anker daneben (siehe `domains/grenzkarte.md`, „Drei Zustände"). Hier gibt es keinen, weil die Erlaubnis je **Merkmal** gilt — ein mitten im Schuljahr ergänztes Notfallmedikament hat kein unterschriebenes Blatt, und zwei Notfallmedikamente desselben Kindes sind getrennt zu erlauben.

## Der zweistufige Zugriff ist die eigentliche Konstruktion

- **Den vollen Satz** sehen Sekretariat, Klassenlehrer:in und Hort.
- **Alle unterrichtenden Personen** sehen ausschließlich einen kurzen handlungsrelevanten Hinweis, den die Klassenlehrkraft formuliert: „keine Sprungübungen", „Notfallmedikament im Sekretariat".

Das sind **zwei Spalten mit unterschiedlichem GRANT auf derselben Tabelle**, kein zweites Berechtigungssystem. Ein Fachlehrer braucht die Handlungsregel, nicht die Diagnose — der volle Satz wäre Über-Offenlegung nach Art. 9. Eine echte Fachlehrer-Berechtigung bräuchte ein Unterrichtszuordnungs-Modell, und das lebt in Untis (dauerhaft out of scope).

**Der Hinweis ist deshalb keine Kurzfassung der Anweisung.** Der Unterschied ist nicht die Länge, sondern der Leserkreis: im Hinweis darf keine Diagnose stehen, und wer ihn formuliert, trifft genau diese Entscheidung. Wer die beiden Spalten später „aufräumt" und zusammenlegt, hebt den Art.-9-Schutz auf, ohne es zu merken.

Die sensibelste einzelne Angabe ist der **Behandlungsgrund** — eine Diagnose. Sie teilt das GRANT des vollen Satzes, wird nirgends ausgewertet und nur angezeigt.

Die GRANTs selbst stehen wie bei den Konfessionsspalten nicht im Schema, sondern in `wb-backend/db/init-roles.sh`. Zwei Bedingungen, ohne die die Konstruktion nicht greift: die Laufzeit-Rolle darf **kein** tabellenweites `GRANT SELECT/UPDATE` auf die Merkmalstabelle bekommen, und der Owner der Tabelle darf nicht die Laufzeit-Rolle sein. Das Prüfskript kann das nicht belegen — es läuft als Superuser; belegt wird die Struktur, die den Schutz möglich macht.

## Masernschutznachweis

Gesetzlich verpflichtend (§20 IfSG), auf allen vier Checklisten geprüft — und **nie als Kopie**. Festgehalten wird der Nachweis-**Status**; „hier gehen viele Wege". Es entsteht kein Dokument, und der Nachweis braucht keinen Verweis nach Q2: **die Zeile ist der Nachweis**.

Die Zeile trägt zwei Tatsachen, einzeln oder zusammen: **vorgelegt** (Vorlagedatum samt Vorlageart, nur gemeinsam) und **gemeldet** (`reported_to_health_office_on`). Die Infektionsschutz-Anlage des Betreuungsvertrags hält ausdrücklich fest, dass ein fehlender Masern-Immunitätsnachweis dem Gesundheitsamt gemeldet wird — „geprüft, nicht vorgelegt, gemeldet" ist damit ein realer Zustand und von „nie geprüft" (keine Zeile) unterscheidbar. Wird der Nachweis nachgereicht, kommt die Vorlage in dieselbe Zeile, das Meldedatum bleibt als Beleg.

Eigene Tabelle statt einer Merkmalszeile, weil er kein „was liegt vor" und keine Handlungsanweisung hat. Das Kind ist zugleich Primärschlüssel — ein Kind hat genau einen Nachweis-Status oder keinen, ein zweiter wäre eine Dublette. Damit ist die Alltagsabfrage („liegt er vor?") ein Punkt-Lookup, und genau das verlangt die Anforderung, ihn schnell nachprüfen zu können.

## Was hier nicht steht

- **Einwilligung und Unterschrift** des Gesundheitsdatenblatts sind Q1 und Q2 aus dem Anmelde-Schema. Hier stünden sie ein zweites Mal.
- **Die Zeckenentfernung** ist keine Eigenschaft des Kindes, sondern eine Erlaubnis — eine Zustimmung (Q1) mit eigenem Zweck, widerrufbar wie jede andere.
- **Ein Behandlungszeitraum** (siehe „Was hier steht, gilt").
- **Das Küchenprofil** (Essensvariante, Vegetarier-Frage des Betreuungsvertrags): eine Handlungsanweisung an die Küche, keine Diagnose — es lebt in Domäne 6 mit eigenem Leserkreis (`domains/mensa.md`), das medizinische Merkmal bleibt hier.
- **Die Geburtsurkunde** ist kein Gesundheitsdatum und bleibt eine reine Q2-Zeile mit Bezug Kind; hier hätte sie das falsche Zugriffsprofil.
- **Diagnose-Codes** (ICD o. ä.). Niemand fragt danach, und ein Code verleitet zu Auswertungen, für die es keine Rechtsgrundlage gibt.
- **Historie.** Es gilt ausschließlich, was in der Datenbank steht — kein Beginn, kein Ende, keine abgelaufene Zeile. Ein Merkmal, das nicht mehr zutrifft, wird gelöscht (siehe „Was hier steht, gilt").

## Anschluss an die anderen Domänen

Das **Attest** zeigt auf die Q2-Dokumentzeile im Anmelde-Schema, statt einen zweiten Dateiverweis aufzumachen: die Datei liegt in SharePoint, und der Lösch-Job muss sie über genau einen Weg finden. Das Prüfskript zeigt beides — das Attest ist über diesen einen Weg auffindbar, und es lässt sich nicht löschen, solange ein Merkmal darauf zeigt.

**Dass das Attest zu diesem Kind gehört, erzwingt das Schema nicht** — die Bedingung führt über `documents.child_id` und wäre nur als Trigger ausdrückbar, dieselbe dokumentierte Lücke wie bei `contract_responses.person_id`. Hier wiegt sie am schwersten: ein fremdes Attest an der Merkmalszeile gäbe die Dateireferenz eines Art.-9-Dokuments an den Leserkreis eines anderen Kindes weiter und blockierte dessen Löschung über zwei Fremdschlüssel hinweg. Die Bindung liegt deshalb in der Eingabemaske, die zum Attest ausschließlich Dokumente desselben Kindes anbietet.

**Damit liegt die Löschreihenfolge fest, und sie läuft gegen das Gefälle der Fristen.** Dieser Bestand hat voraussichtlich die kürzeste Frist im System, hält über das Attest aber ein `ON DELETE RESTRICT` in eine Domäne mit anderer Frist. Der Lösch-Job muss deshalb hier anfangen: erst das Merkmal, dann die Q2-Dokumentzeile, dann die Datei in SharePoint (`idea/06-dsgvo-organisatorisch.md`). Umgekehrt blockiert er.

**Ein Kind lässt sich nicht löschen, solange Merkmale oder ein Masernnachweis daran hängen** (`ON DELETE RESTRICT` auf beiden Tabellen, im Prüfskript belegt). Die Zusage aus `domains/stammdaten.md`, ein Kind zu löschen sei **ein** Befehl auf die Personenzeile, gilt seit dieser Domäne nicht mehr unverändert — dort nachgezogen.

**Schulbegleitung** ist ein Unterstützungsbedarf und gehört hierher, nicht in ein Freitextfeld der Bewerbung: sie gilt über das Aufnahmeverfahren hinaus und wird im Schulalltag gebraucht — mit diesem Zugriffsprofil, nicht mit dem der Bewerbung.

## Offene Punkte

- Aufbewahrungs- und Löschfristen stehen aus (`TODO.md`). Gesundheitsdaten dürften die kürzeste Frist im System haben, und sie hängt nicht am selben Anker wie die Stammdaten. Für **externe Hortkinder** sagt der Betreuungsvertrag die Löschung bereits zu („Diese Daten werden nach Austritt aus dem Hort gelöscht") — der Anker ist dort das Ende der letzten Betreuungsbuchung.
- Wer den handlungsrelevanten Hinweis formulieren darf, ist als Rolle noch nicht benannt — fachlich ist es die Klassenlehrkraft, technisch braucht es dafür ein eigenes `GRANT UPDATE` auf genau diese Spalte. Dieselbe Lücke betrifft den **Hort**: er sieht laut Festlegung den vollen Satz, hat aber noch keine benannte Rolle, die `init-roles.sh` abbilden könnte.
- **Woran hängt die Bereinigung?** Ohne Behandlungszeitraum und ohne wiederkehrende Sammelaktion ändert sich ein Merkmal nur, wenn Eltern es melden. Der naheliegende Anker ist der Eltern-Selfservice (Domäne 8): sehen Eltern ihren eigenen Gesundheitssatz und können ihn korrigieren, ist die Bereinigung dieselbe Handlung wie die Pflege. Zu entscheiden mit dem Zuschnitt von Domäne 8, nicht vorher.
