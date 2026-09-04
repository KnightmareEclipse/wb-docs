---
id: TASK-208
title: 'Newsletter als Einwilligung je Thema — der Bestand, nicht die Versandstrecke'
status: In Progress
assignee: []
created_date: '2026-09-03 13:55'
updated_date: '2026-09-04 01:06'
labels:
  - schema
  - dsgvo
  - querschnitt
milestone: m-5
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

**Was die Sendung sehr wohl trägt:** Betreff und Text als Eingabe, den Empfängerkreis, den Abmeldelink und je Empfänger den Zustellstatus. ~~Ein Newsletter wird jedes Mal neu geschrieben — dafür braucht es ein Textfeld, keine Vorlage.~~ **Überholt am 04.09.2026:** Der Text soll dieselben Klartext-Platzhalter tragen wie ein Vertrag und je Empfänger aus Livedaten gefüllt werden — das ist TASK-250. Ein Textfeld bleibt es trotzdem; was dazukommt, ist das Füllen, nicht ein Editor.

**Nicht gebaut wird ein Newsletter-Produkt**: kein Vorlagen-Editor (eine Oberfläche zum Gestalten mit Formatierung, Bildern und Vorschau — Platzhalter im Text sind das nicht, sie werden getippt wie der Text daneben), keine Zustellstatistik über Öffnungs- und Klickraten (sie braucht Zählpixel und getrackte Links, also einen eigenen einwilligungspflichtigen Bestand — `undeliverable_at` je Mail beantwortet die einzige Frage, die hier gestellt wird: kam sie an), und kein A/B-Versand (zwei Betreffzeilen an zwei Hälften messen, was besser geöffnet wird — er setzt dasselbe Öffnungstracking voraus und beantwortet eine Frage, die die Schule nicht stellt). Und die Menge bleibt der Prüfstein: Der Tenant setzt harte Grenzen (Empfänger je Tag und Nachrichten je Minute), fünfhundert Familien liegen weit darunter, mehrere tausend Ehemalige nicht mehr unbedingt.

Der Widerspruch löscht nicht, er setzt einen Zeitpunkt. Sonst ist später nicht belegbar, dass ab diesem Tag nichts mehr geschrieben wurde — und eine gelöschte Zeile ist wieder eine Adresse, die beim nächsten Import zurückkehrt.

**Die Absenderadresse steht je Anlass**, nicht global: Vorgangsmails, Hortsachen und Newsletter dürfen verschiedene tragen. Welche es gibt, hängt an der Domainfrage (fragen.md, „Zieht der Mailversand mit meinCLEMENS mit?") und wird in TASK-188 entschieden; hier ist es eine Spalte an der Mail.

**Nachtrag 04.09.2026 (Geschäftsführung), zwei Dinge:**

**Erstens ist der Verteiler kein Bestand für Ehemalige allein.** Auch eine laufende Familie muss sich abmelden können, und dabei entsteht eine dritte Sorte Mail neben Newsletter und Vorgangsmail: die **Schulinformation**, abwählbar, aber **einer je Familie muss sie bekommen**. Ein Boolean trennt drei Fälle nicht — `is_newsletter_topic` ist deshalb eine Werteliste `mail_categories` geworden, an der zugleich die Untergrenze hängt; eine feinere Aufteilung (Ferienprogramm, Akademie) ist danach eine Zeile und kein Bau. Die Untergrenze selbst spannt über zwei Personenzeilen und kann kein CHECK sein: sie lebt in der Schreibschicht (TASK-246).

**Zweitens hätte Stufe 6 des Lösch-Laufs den Verteiler still abgeräumt.** `fk_consents_person` stand auf `ON DELETE CASCADE` — die Einwilligung ging mit der Person, statt sie festzuhalten, und niemand hätte widersprochen. Sie steht jetzt auf NO ACTION, der Lauf räumt die kindlosen Zustimmungen selbst und lässt genau die stehen, die abbestellbar und nicht widerrufen ist; die Person wird dann reduziert statt gelöscht (Anrede und Name bleiben, Anschrift und Telefon gehen). Die Regel dafür steht in `soll-prozesse/17`: Was seinen Anker überdauern muss, hält ihn fest.

**Wie die Schule erfährt, wer Alumni werden will, ist ebenfalls beantwortet:** eine Mail am 1. Juni, vor dem Abgang im Juli — an die Zehntklässler selbst und an die Sorgeberechtigten, deren letztes Kind geht (`soll-prozesse/04`). Nachher wäre niemand erreichbar, weil die Adresse drei Monate nach dem Austritt fällt.

**Drittens: drei Kreise, drei Themen, und eine Zugehörigkeit daneben.** Ehemaliges Kind, ehemaliges Elternteil und ehemalige:r Mitarbeitende:r bekommen Verschiedenes zu lesen — das sind drei Zeilen in `consent_purposes` und kein Bau. Was der Verteiler allein nicht trägt, ist der **Jahrgang**: Er steht heute an `children.exit_date` und ist fünf Jahre nach dem Austritt fort, also bevor das erste Jubiläum ansteht. Er liegt deshalb in `alumni` (stammdaten-schema.sql), je Person und Art eine Zeile.

**Der Fall, an dem jede andere Bauform bricht:** Ein Ehemaliger bringt Jahre später sein eigenes Kind an die Schule. Dann ist er wieder ein vollständiges Elternteil mit Familie und Vertrag — an dieser Person ist nichts zu reduzieren, und in einer reduzierten Zeile wäre sein Jahrgang nicht unterzubringen. Dieselbe Person kann außerdem als Kind gegangen und später als Mitarbeitende ausgeschieden sein: zwei Zugehörigkeiten, zwei Jahre. Eltern tragen keinen Jahrgang, weil ihr letztes Kind in einem Jahr ging und ein früheres vielleicht vier Jahre davor.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Die Themen stehen als Werteliste, ein neues ist eine Zeile
- [x] #2 Je Person und Thema eine Zeile mit zwei Zeitpunkten — eingewilligt und widersprochen, nie beides
- [x] #3 Der Anker ist die Person; eine Zeile ohne Kind und ohne Familie ist gültig, das Prüfskript zeigt es
- [ ] #4 Jede Newsletter-Mail trägt einen Abmeldelink je Thema und einen für alle; der Token hängt an der Person
- [ ] #5 Vorgangsmails tragen keinen Abmeldelink — die Gegenprobe: eine Mail ohne Thema kommt ohne ihn heraus
- [x] #6 Ein Widerspruch löscht die Zeile nicht: nach ihm steht sie noch da und der Versand überspringt sie
- [x] #7 Die Sammelmail ist mitgedacht: outbound_emails trägt je Empfänger eine Zeile, und der Verweis auf eine Sendung ist später eine nullable Spalte — kein Umbau
- [ ] #8 Entschieden, ab welcher Menge der Versand aus dem Portal an die Grenzen des Tenants stößt
- [x] #9 Die drei Sorten Mail stehen als Werteliste; eine Untergrenze an einer nicht abwählbaren Kategorie wird abgewiesen
- [ ] #10 Die Schreibschicht weist die Abwahl der letzten Schulinformation einer Familie ab (TASK-246)
- [x] #11 Die Zugehörigkeit steht neben der Person: je Person und Art eine Zeile, Jahrgang wo die Art ihn verlangt, und sie hält die Person fest
- [ ] #12 Die drei Themen und die drei Arten stehen als Anfangsbestand der Wertelisten (TASK-246)
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Gebaut, aber auf Q1 statt daneben — und das weicht vom Ticketwortlaut ab: Ein Newsletter-Thema IST ein Zustimmungszweck. consent_purposes ist bereits die Werteliste (ein neues Thema ist eine Zeile), consents bereits die Zeile je Person und Zweck mit granted_at/declined_at, revoked_at, delivery_address und dem Anker an der Person ohne Kind und ohne Familie; ix_consents_person_purpose haelt sie schon heute je Person und Zweck eindeutig, und mit 'marketing_holiday' steht dort seit je eine Werbe-Einwilligung ohne Kind. Zwei eigene Tabellen daneben waeren eine zweite Bauform fuer genau das, was Q1 traegt.

Drei Spalten statt zweier Tabellen:
- consent_purposes.mail_category_id + is_unsubscribable (mitgefuehrt) — die Sorte Mail, die dieser Zweck steuert, und das Haekchen der Kategorie, samt uq_consent_purposes_unsub fuer den zusammengesetzten Fremdschluessel. Leer bei einem Zweck, der gar keine Mail steuert (Fotoerlaubnis, Gesundheitsdaten); ck_consent_purposes_unsub verhindert dort einen erfundenen Abmeldelink. Stand nach dem ersten Bau als Boolean is_newsletter_topic da — ein Boolean trennt die drei Sorten aus dem Nachtrag oben nicht.
- mail_categories — die Werteliste dazu, mit is_unsubscribable und requires_family_recipient; ck_mail_categories_floor weist eine Untergrenze an einer nicht abwaehlbaren Kategorie ab.
- outbound_emails.consent_purpose_id + is_unsubscribable (mitgefuehrt) — ck_outbound_emails_topic laesst genau die abbestellbare Mail ein Thema tragen, und der zusammengesetzte Fremdschluessel weist einen Vorgangszweck ab. Damit ist Kriterium 5 als Gegenprobe gebaut: eine Vorgangsmail KANN kein Thema tragen und kommt deshalb ohne Link heraus.
- outbound_emails.from_address — nullable, weil welche Adressen es gibt an der Domainfrage haengt (TASK-188, fragen.md, „Zieht der Mailversand mit meinCLEMENS mit?"). Kein Wert wird hier erfunden.

Kein Token in der Datenbank (Kriterium 4 halb): Der Abmeldelink ist ein Token ueber die Personenkennung, wie der Signaturlink des Kindes ab 14 — der hat ebenfalls keine Spalte (api/querschnitt-api.md). Der Link je Thema folgt aus consent_purpose_id, der fuer alle aus der Person. Zu bauen in wb-backend.

Der Widerspruch loescht nicht: revoked_at, und ck_consents_revoked sagt schon heute, dass eine Ablehnung nicht widerrufen wird. Gegenprobe im Pruefskript.

Und der Anker haelt jetzt fest statt mitzugehen: fk_consents_person steht auf NO ACTION. Das Pruefskript zeigt beides — die Person mit offener Newsletter-Zeile laesst sich nicht loeschen, und nachdem der Lauf die uebrigen kindlosen Zustimmungen selbst geraeumt hat, gehen die anderen Personen.

Offen: Kriterium 8 (ab welcher Menge der Tenant sperrt) — eine Zahl, die recherchiert und bestaetigt werden muss, kein Schemapunkt. Die Sendung ueber outbound_emails entsteht erst mit der ersten Sammelmail, wie im Ticket beschrieben — hier bewusst nicht gebaut.
<!-- SECTION:NOTES:END -->
