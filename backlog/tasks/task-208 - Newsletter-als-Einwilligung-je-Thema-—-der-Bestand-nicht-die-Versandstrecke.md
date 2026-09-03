---
id: TASK-208
title: 'Newsletter als Einwilligung je Thema — der Bestand, nicht die Versandstrecke'
status: To Do
assignee: []
created_date: '2026-09-03 13:55'
updated_date: '2026-09-03 14:05'
labels:
  - schema
  - dsgvo
  - querschnitt
dependencies: []
references:
  - schema/querschnitt-schema.sql
  - schema/stammdaten-schema.sql
  - soll-prozesse/03-irregulaerer-abgang.md
ordinal: 221000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Aus B7 (Alumni) und dem Gespräch vom 03.09.2026 — aber breiter als ein Verteiler: **Newsletter-Themen**, für die sich jede Person einzeln an- und abmeldet. Das trägt Alumni, Förderkreis und Interessenten ohne jedes Vertragsverhältnis mit demselben Bauteil; der Anker ist die **Person**, nicht das Kind, und `persons` verlangt keine Familie.

**Der zweite Verbraucher ist die Sammelmail aus dem Portal** — die Einladung zum Elternabend an alle Sorgeberechtigten einer Klasse. Sie ist geplant, nicht beschlossen, aber sie benutzt dieselbe Form, und deshalb wird sie hier mitgedacht statt später danebengebaut.

**Das Teure steht schon.** `outbound_emails` führt heute je Mail eine Zeile mit der Adresse, an die sie ging, der Person (nullable — eine noch unbekannte Familie hat keine), dem Anlass, dem Zeitpunkt und dem Rückläufer. Genau das braucht eine Sammelmail je Empfänger. Was fehlt, ist eine **Sendung** darüber — Betreff, Vorlage, Auslöser, Zeitpunkt — und ein nullable Verweis darauf an `outbound_emails`. Eine Spalte, kein Umbau; sie entsteht, wenn die erste Sammelmail gebaut wird.

Drei Regeln, die später teuer sind und deshalb jetzt festgehalten werden:

- **Eine Zeile je Empfänger, nie ein BCC-Feld.** Sonst ist weder Zustellung noch Widerspruch je Person nachvollziehbar, und der Abmeldelink braucht ohnehin einen Token je Person. Nebenbei ist es der Grund, warum die Portalvariante reputationsseitig **besser** ist als ein Mensch mit 500 Adressen im BCC: gleicher Absender, aber Einzelnachrichten mit `List-Unsubscribe` statt einer Sammelmail, die jeder Spamfilter als solche liest.
- **Der Empfängerkreis wird beim Senden aufgelöst und dann festgeschrieben**, nicht als Abfrage gespeichert. Eine Sendung, die ihre Empfänger jedes Mal neu berechnet, zeigt im nächsten Jahr eine andere Liste als die, die sie tatsächlich hatte.
- **Der Abmeldelink gilt nur für Newsletter-Themen, nie für Vorgangsmails.** Wer sich vom Elternabend abmelden könnte, bekäme die nächste Vertragsfrist auch nicht mehr — die Einladung zum Elternabend steht auf dem Vertrag, nicht auf einer Einwilligung.

**Was die Sendung sehr wohl trägt:** Betreff und Text als Eingabe, den Empfängerkreis, den Abmeldelink und je Empfänger den Zustellstatus. Ein Newsletter wird jedes Mal neu geschrieben — dafür braucht es ein Textfeld, keine Vorlage.

**Nicht gebaut wird ein Newsletter-Produkt**: kein Vorlagen-Editor (eine Oberfläche zum Gestalten mit Formatierung, Bildern und Vorschau), keine Zustellstatistik über Öffnungs- und Klickraten (sie braucht Zählpixel und getrackte Links, also einen eigenen einwilligungspflichtigen Bestand — `undeliverable_at` je Mail beantwortet die einzige Frage, die hier gestellt wird: kam sie an), und kein A/B-Versand (zwei Betreffzeilen an zwei Hälften messen, was besser geöffnet wird — er setzt dasselbe Öffnungstracking voraus und beantwortet eine Frage, die die Schule nicht stellt). Und die Menge bleibt der Prüfstein: Der Tenant setzt harte Grenzen (Empfänger je Tag und Nachrichten je Minute), fünfhundert Familien liegen weit darunter, mehrere tausend Ehemalige nicht mehr unbedingt.

Der Widerspruch löscht nicht, er setzt einen Zeitpunkt. Sonst ist später nicht belegbar, dass ab diesem Tag nichts mehr geschrieben wurde — und eine gelöschte Zeile ist wieder eine Adresse, die beim nächsten Import zurückkehrt.

**Die Absenderadresse steht je Anlass**, nicht global: Vorgangsmails, Hortsachen und Newsletter dürfen verschiedene tragen. Welche es gibt, hängt an der Domainfrage (fragen.md, Frage 10) und wird in TASK-188 entschieden; hier ist es eine Spalte an der Mail.

Offen und nicht Teil dieses Tickets: **wie die Schule erfährt, wer Alumni werden will** — Frage 18 in fragen.md.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Die Themen stehen als Werteliste, ein neues ist eine Zeile
- [ ] #2 Je Person und Thema eine Zeile mit zwei Zeitpunkten — eingewilligt und widersprochen, nie beides
- [ ] #3 Der Anker ist die Person; eine Zeile ohne Kind und ohne Familie ist gültig, das Prüfskript zeigt es
- [ ] #4 Jede Newsletter-Mail trägt einen Abmeldelink je Thema und einen für alle; der Token hängt an der Person
- [ ] #5 Vorgangsmails tragen keinen Abmeldelink — die Gegenprobe: eine Mail ohne Thema kommt ohne ihn heraus
- [ ] #6 Ein Widerspruch löscht die Zeile nicht: nach ihm steht sie noch da und der Versand überspringt sie
- [ ] #7 Die Sammelmail ist mitgedacht: outbound_emails trägt je Empfänger eine Zeile, und der Verweis auf eine Sendung ist später eine nullable Spalte — kein Umbau
- [ ] #8 Entschieden, ab welcher Menge der Versand aus dem Portal an die Grenzen des Tenants stößt
<!-- AC:END -->
