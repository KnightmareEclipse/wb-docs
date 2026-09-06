---
id: TASK-248
title: 'Mailversand, Verteiler und Gruppen aus Weltenbaum in den Tenant schreiben'
status: To Do
assignee: []
created_date: '2026-09-04 18:32'
updated_date: '2026-09-04 18:33'
labels:
  - m365
  - mail
  - zurueckgestellt
milestone: m-5
dependencies: []
priority: low
ordinal: 261000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Geschaeftsfuehrung, 04.09.2026: **geplant, aber vorerst niedrige Prioritaet.** Der Versand laeuft kuenftig ueber meinclemens.schule (entschieden); wie viele Absender dahinterstehen, ist Frage 7 in fragen.md.

**Bis dahin gilt der Weg, der keinen Grant braucht:** Weltenbaum sagt der zustaendigen Stelle ueber eine Nachzieh-Aufgabe, dass ein Verteiler, eine Gruppe oder ein Konto zu pflegen ist — getan wird es in Vis365. Das schliesst genau die Luecke, an der heute der Faden reisst (prozesse.md, Abschnitt 16: 'laeuft ueber Zuruf an hoffentlich die richtigen Personen'), und kostet nichts.

**Was recherchiert ist und beim Bau nicht noch einmal gesucht werden muss:**

- **Klassische Verteilerlisten und mail-enabled Security Groups sind in Graph read-only.** Erstellen und Mitglieder pflegen geht dort nur fuer M365-Gruppen und normale Security Groups; fuer Exchange-Objekte bleibt Exchange Online PowerShell der einzige unterstuetzte Weg. Bei der Schule sind die Klassengruppen Teams/M365-Gruppen, die Elternadressen aber Distribution Lists — es sind also zwei Wege, nicht einer.
- **Es gibt kein Groups.Selected.** Der enge Grant laeuft ueber eine Entra-Directory-Rolle, gescopet auf eine Administrative Unit, in der genau die Objekte liegen, die Weltenbaum gehoeren. Haken: Der Service Principal braucht zusaetzlich tenantweite Leserechte (Directory Readers), weil sich Leserechte nicht auf eine AU einschraenken lassen — im gemeinsamen Tenant mit der KITA ist das der Preis. Noch schmaler waere, den Service Principal zum Owner der einzelnen Gruppen zu machen.
- **Fuer Exchange gibt es RBAC for Applications** — Rollenzuweisung an einen Service Principal mit Resource Scope (Admin Units oder Security Groups). Das ist der Nachfolger der Application Access Policy, die zugang.md heute fuer Mail.Send beschreibt.
- **Ein Freigabeschritt ueber PIM geht nicht:** Service Principals koennen nicht 'eligible' sein, approval-basierte Aktivierung gibt es fuer sie nicht. Ein zweiter Dienst mit Freigabe waere Eigenbau — und eine Freigabe je Aenderung frisst genau den Gewinn. Freigabe je **Lauf** ist der Kompromiss, der traegt.
- **Der Umweg ueber eine Datei, die Vis365 frisst, ist verworfen** — aber aus zwei Gruenden statt drei. Das Zwischenformat ist eine dritte Wahrheit, und der Upload ist wieder ein Weg ueber einen Menschen, genau der, der heute reisst. **Nicht** traegt dagegen das Argument, ein Import sei kein Abgleich: Vis365 hat dafuer einen eigenen Schalter, der Schuelerkonten loescht, die in den importierten Daten fehlen (Tim, 04.09.2026). Das war ein Fehlschluss beim Aufschreiben und ist hier richtiggestellt, damit ihn niemand als Begruendung weiterreicht.

**Belegt aus der Praxis (Tim, zweiter Admin, 04.09.2026):** Beim Jahreswechsel ist das **Aktualisieren der Elternverteiler der laengste und fehleranfaelligste Griff** — 'das dauert immer ewig, weil hier wohl eine andere API von Microsoft verwendet wird. Ist sehr fehleranfaellig und daher muss man den Status ueberpruefen.' Genau das ist der recherchierte Befund von oben, von der anderen Seite erlebt: Distribution Lists laufen nicht ueber Graph. **Es ist damit der erste Griff, den eine Ablösung abnehmen wuerde** — und der einzige aus dem Jahreslauf, bei dem sich der Aufwand gegen den Gewinn rechnet.

**Und die Unordnung im Tenant hat ein Gesicht:** Das 'Krisenteam 2.0' liegt als falscher Typ vor, laesst sich laut Vis365 nicht von einem Schueler- in ein Mitarbeiterteam umwandeln und muesste neu angelegt werden; beim Jahreslauf archiviert der Schalter es jedes Mal mit, und jemand muss es zurueckholen. Solche Faelle sind der Preis, den das Ticket oben als Vorprojekt nennt — hier steht der erste bekannte.

**Der Serienbrief haengt daran und steht getrennt:** TASK-250. Er kann nur an einen Kreis gehen, dessen Mitglieder Weltenbaum selbst kennt — traegt jemand in Exchange eine Adresse von Hand nach, hat sie keinen Personenbezug und ihre Platzhalter blieben leer. Damit faellt er mit der Entscheidung oben, ob Weltenbaum alleinige Quelle des Verteilers ist.

**Der Schnitt gegen Vis365, wenn gebaut wird:** Weltenbaum schreibt, was aus seinen Daten folgt — Konten je Kind und Mitarbeitendem, Klassengruppen, Verteiler. Vis365 macht, was Weltenbaum nicht kennt — Geraete, Lizenzzuweisung, Teams-Richtlinien, Zwei-Faktor. Diese Grenze ist zugleich die Liste der Objekte, die in die Administrative Unit gehoeren.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Entschieden, ob die Verteiler M365-Gruppen werden (ein Weg) oder Distribution Lists bleiben (zweiter Weg ueber Exchange PowerShell)
- [ ] #2 Der Grant steht in zugang.md mit Pfad und Preis, und er ist auf eine Administrative Unit gescopet
- [ ] #3 Der Schnitt gegen Vis365 ist als Objektliste der AU niedergeschrieben, nicht als Absichtserklaerung
- [ ] #4 Bis dahin: die Nachzieh-Aufgabe traegt jede Pflege, die ein Mensch in Vis365 tun muss
<!-- AC:END -->
