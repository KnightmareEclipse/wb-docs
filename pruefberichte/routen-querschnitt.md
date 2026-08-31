# Prüfbericht: Routen des Querschnitts

21 Routen in `app/routers/querschnitt.py`, 27 Tests in `tests/test_querschnitt.py`.
**Nullpunkt grün** (27 passed). Auftrag: [`api/querschnitt-api.md`](../api/querschnitt-api.md).
Gemessen nach der Methode aus `prompts/api-pruefen.md`.

## Funde

```
[QUER-R1] Klasse 1 · GET /change-log
Plan: „Drei Ausprägungen: das Sekretariat sieht sie überall, die Rollenhistorie sehen zusätzlich
  Admins und Geschäftsführung (der einzige solche Fall), und **die Rechnungsfreigabe regelt das
  Sehen abweichend — dort nicht das Sekretariat**." Der Docstring der Route schreibt denselben Satz
  aus.
  Gebaut ist nur die zweite Ausprägung. Die Route setzt

      allowed = _SECRETARIAT in user.roles or ADMIN_ROLE in user.roles

  ohne jede Tabellenbedingung; die dritte fehlt ersatzlos. Damit liest das Sekretariat die
  Änderungsspur eines Belegs — `GET /change-log?table_name=expense_claims&row_id=…` —, obwohl der
  Block 12 es dort ausdrücklich ausschließt, und die Spur trägt alte und neue Werte je Spalte.
Nicht gemessen, gelesen: es gibt nichts, dessen Sicherung man herausnehmen könnte.
Vorschlag: eine Tabellenbedingung wie beim Rollenverlauf, nur andersherum — für die Tabellen der
  Rechnungsfreigabe fällt `_SECRETARIAT` aus `allowed` heraus.
```

```
[QUER-R2] Klasse 1 · PUT/DELETE /persons/{person_id}/consents/{purpose}
`_reach_person_both_doors()` ist die ganze Ownership-Prüfung dieser beiden Routen: für den
  Elternteil `if person_id != user.acting_as: 404`.
Gemessen: die Zeile entfernt, tests/test_querschnitt.py bleibt grün (27 passed). Ein Elternteil, der
  eine fremde `person_id` rät, setzt oder widerruft damit deren Einwilligung — heute die
  Werbeeinwilligung des Ferienprogramms, und die Zeile trägt Zeitpunkt und Person. Die Datei prüft
  die fremde Familie am Kind (Q9, rot) und die fremde Person nicht.
Vorschlag: ein Test, der als Elternteil eine fremde `person_id` schickt und 404 verlangt.
```

```
[QUER-R3] Klasse 5 · die zweite Tür der Einwilligungen und der Dokumentinhalt
Zwei Rollenschranken, beide `require_staff(...)` und beide ungeprüft:
  · `_reach_child_both_doors()` — `require_staff(user, _SECRETARIAT)`. Gemessen: entfernt → grün
    (27 passed). Danach beantwortet jede Mitarbeiterrolle, die das Kind über `reach_child` erreicht,
    eine Einwilligung an Stelle der Eltern — die Fotoeinwilligung eingeschlossen.
  · `GET /documents/{document_id}/content` — `require_staff(user, _SECRETARIAT, BRANCH_ROLE,
    "day_care_management")`. Gemessen: entfernt → grün. Danach lädt jede Rolle, die das Kind
    erreicht, die Datei herunter; die Zeile daneben (`GET /children/{id}/documents`) ist geprüft,
    der Inhalt nicht.
Vorschlag: je ein Test mit `as_role("teacher")` gegen 403.
```

```
[QUER-R4] Klasse 4 · die Einsichtsstufe an den Einwilligungen
`_reach_child_both_doors(..., write=write)` gibt das `write` an `reach_family()` weiter — die
  einzige Stelle, an der „nur lesen ruft keine schreibende Route" für diese Domäne hängt.
Gemessen: das `write=write` gestrichen → grün (27 passed). Kein Test hat einen Sorgeberechtigten
  mit Stufe „nur lesen"; dieselbe Lücke wie in `routen-mensa.md` und `routen-elternbonus.md`.
Vorschlag: ein Test mit leerem `writable_families` gegen 403.
```

```
[QUER-R5] Klasse 5 · zwei Rollenlisten ohne Test
`GET /children/{child_id}/photo-consent` trägt sieben Rollen, `GET /outbound-emails/undeliverable`
  genau `secretariat`.
Gemessen: die erste um `canteen` erweitert → grün; die zweite um `teacher` erweitert → grün
  (je 27 passed). Die Fotoeinwilligung ist laut Plan „die am breitesten gelesene Antwort im System"
  — welcher Kreis das ist, hält kein Test fest.
Vorschlag: je ein Test mit einer Rolle außerhalb der Liste gegen 403.
```

```
[QUER-R6] Klasse 4 · die zwei Wertelisten-Prüfungen der Route
`_ANSWERS` an der Einwilligung und `_OUTCOMES` am Abhaken sind Wertelisten, die kein CHECK trägt —
  die Route weist eine unbekannte Antwort bzw. ein unbekanntes Ergebnis mit 400 ab.
Gemessen, beide entfernt → je grün (27 passed). Danach landete ein beliebiger String in
  `consents.answer` bzw. `sync_tasks.outcome`, und beide Spalten liest die Oberfläche als
  Fallunterscheidung.
Vorschlag: je ein Test mit einem erfundenen Wert gegen 400.
```

## Angesehen, nicht als Fund gewertet

- **Ownership in der Query, wo Tests liegen.** Fremde Familie am Kind-Einwilligungsweg → rot; fremde
  Familie an der Dokumentenliste → rot; fremde Familie am Dokumentinhalt → rot.
- **Die Aufgabenroute.** Der Elternteil an der Liste → rot; der Rollenfilter der Liste → rot; die
  Bindung des Abhakens an die Rolle des Ziels → rot. Genau die Trennung, die der Plan zieht
  („Sehen und Abhaken sind zweierlei").
- **Die Änderungsspur.** Rollenschranke entfernt → rot; die Ausnahme für den Rollenverlauf entfernt
  → rot. Nur die dritte Ausprägung fehlt, und das ist R1.
- **Die sparsame Ansicht der Eltern an den Dokumenten.** Der Filter auf „missing" entfernt → rot.
- **Die Rollenschranke der Vertragstexte** entfernt → rot.
- **Zwei Türsicherungen sind doppelt.** Die 403 des Elternteils an `GET /change-log` lässt sich
  entfernen, ohne dass die Suite rot wird — weil der Rollencheck darunter denselben Status liefert.
  Das sagt nichts über den Test aus; die Sicherung ist redundant, nicht wirkungslos. Dieselbe Form
  wie an der Storno-Eintragung in `routen-ferien.md`.
- **Ein Lauf war keine Messung.** Der Ausdruck `if row.valid_from <= _today():` steht in dieser
  Datei mehr als einmal — Wert und Vertragstext teilen ihn —, der Mustertreffer war nicht eindeutig
  und der Lauf hat ihn übersprungen. Die Regel „nur ein noch nicht gültiger Betrag ist beweglich"
  ist damit hier ungemessen; in `routen-mensa.md` und `routen-ferien.md` ist dieselbe Regel je rot
  geworden.
- **Klasse 6.** Keine Route dieser Datei schreibt zwei Tabellen zugleich oder schickt eine Mail;
  `raise_task`/`complete_task` sind Hebel, die andere Domänen in ihrer eigenen Transaktion rufen.
- **Klasse 7.** Die Läufe des Querschnitts (Wochenmail, Lösch-Lauf) haben keinen Endpunkt und
  gehören nicht zu den Routen dieser Datei.
