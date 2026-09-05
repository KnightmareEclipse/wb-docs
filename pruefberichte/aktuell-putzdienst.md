# Prüfbericht putzdienst

`schema/putzdienst-schema.sql` samt `schema/putzdienst-schema-check.sql`, gegen
`soll-prozesse/01-putzdienst.md` (dazu 02, 03, `hebel.md`, `grenzkarte.md`, `rules.md` 1/3/7).

Ladelauf aller vierzehn Schemata in dokumentierter Reihenfolge: **rc=0 je Datei**.
`putzdienst-schema-check.sql` gegen die vollständige Datenbank: **rc=0**.
`[A!]`, `[A]`, `[?]`: keine in dieser Domäne.

## Funde

```
[PUTZDIENST-F1] putzdienst · Klasse 1 · cleaning_assignments / cleaning_swap_acceptances
01 Z4 sagt „jede Familie hat exakt so viele Termine je Art, wie sie in diesem
Putzdienstjahr leisten muss"; der Tausch trägt die Terminart mit, den Zyklus nicht —
ein Angebot über einen Septembertermin des alten Jahres lässt sich gegen einen
Oktobertermin des neuen ankreuzen und vollziehen (nachgestellt, geht durch), womit
eine Pflicht des einen Jahres im anderen landet. Der Fall ist nicht konstruiert: der
Monat Puffer ist Absicht, in ihm laufen die Septembertermine des alten Jahres und das
Anmeldefenster des neuen nebeneinander.
Vorschlag: `cleaning_cycle_id` an `cleaning_assignments` mitführen und über einen
zusammengesetzten Fremdschlüssel an `cleaning_slots` binden, wie es die Terminart
schon zweimal vormacht — Angebot und Annahme erben ihn dann.
```

```
[PUTZDIENST-F2] putzdienst · Klasse 7 · cleaning_slots.attendance_sheet_library_id
01, Dateien: „Unterschrieben kommt sie zurück und wird eingescannt beim Termin
abgelegt" — der Fremdschlüssel zeigt in `sharepoint_libraries`, deren eigener
Kommentar sagt „Die Karte führt die Bibliotheken als Tabelle, und es sind vier"
(Schülerakte, Hortakte, Belege, Fotoerlaubnisse). Die Anwesenheitsliste passt in keine:
sie „gehört keinem und hätte in der Schülerakte keinen Platz" (putzdienst-schema.sql).
Damit legt diese Domäne eine personenbezogene Datei in einen fünften Bestand, den
weder `grenzkarte.md` (Q2, Bibliothekstabelle) noch TASK-053 („Die drei SharePoint-
Bibliotheken einrichten") kennt — es gibt für ihn also weder einen Leserkreis in der
Karte noch ein `Sites.Selected`-Grant, ohne das die Route nicht schreiben kann.
Das Prüfskript zeigt dieselbe Lücke: Es legt die Liste behelfsweise in eine Bibliothek
mit dem Code `generated`, den die Rechnungsfreigabe für die Belege benutzt.
Vorschlag: Bibliothekstabelle in `grenzkarte.md` Q2 um den Bestand „Anwesenheitslisten"
(App schreibt und liest, Menschen keine) ergänzen und TASK-053 auf vier Grants ziehen.
```

```
[PUTZDIENST-F3] putzdienst · Klasse 5 · putzdienst-schema-check.sql:541
Die Probe „01 — Zuteilung freigegeben, bevor das Anmeldefenster schließt" wird nicht
von der Fensterregel abgewiesen, sondern von `ck_cleaning_cycles_release` über den
Zweig `allocated_at IS NULL` (einzeln nachgestellt, Constraint-Name aus der Meldung).
Sie ist damit dieselbe Probe wie die vier Zeilen darunter („freigegeben, ohne dass die
Zuteilung gelaufen ist") und belegt nichts über das Anmeldefenster. Einen Constraint
`allocation_released_at >= registration_closes_at` gibt es nicht; die Regel gilt nur
transitiv über `allocated_at`. Das trägt heute — aber die Probe behauptet, es direkt
zu prüfen.
Vorschlag: Die Probe auf ihren wirklichen Fall stellen — `allocated_at` erst gültig
setzen, dann eine frühere Freigabe versuchen — oder sie streichen und die Transitivität
im Kopfkommentar benennen.
```

```
[PUTZDIENST-F4] putzdienst · Klasse 7 · cleaning_assignments.source (Zeile 320)
`CHECK (source IN ('reserved','allocated','swapped','manual'))` ist eine Auswahl aus
vier benannten Alternativen, und `rules.md` Abschnitt 3 verlangt dafür eine
Lookup-Tabelle. Die dort ausgeschriebene Ausnahme greift nicht: keine der vier
Ausprägungen entscheidet, welche andere Spalte derselben Zeile Pflicht ist. Der
Kommentar begründet den Wert, nicht die Bauform — und der `payment_mode` derselben
Datei ist genau diesen Weg vor kurzem in die andere Richtung gegangen.
Vorschlag: Entweder Werteliste `cleaning_assignment_sources` wie `payment_modes`, oder
ein Satz am CHECK, warum die Herkunft eine strukturelle Tatsache und keine Bezeichnung ist.
```

```
[PUTZDIENST-F5] putzdienst · Klasse 3 · putzdienst-schema-check.sql:307
Das Zitat „neben Stripe bleibt die manuelle Bestätigung durch die Buchhaltung als
benannter Ausweg für Überweisung und Bargeld bestehen" steht dort unter der Quelle
„01:". Block 01 enthält weder „Stripe" noch „Bargeld" noch „Überweisung"; der Satz
stammt wörtlich aus `grenzkarte.md`, Q3. Ein Blockzitat wiegt schwerer als ein
Kartensatz — die Karte lässt sich vom Block überstimmen, umgekehrt nicht.
Vorschlag: Quelle auf „grenzkarte.md, Q3" ändern.
```

```
[PUTZDIENST-F6] putzdienst · Klasse 7 · grenzkarte.md:248
Die Zeile „1 Putzdienst (gebaut) | … | Q3 | nein" nennt als genutzten Querschnitt allein
Q3. Das Schema legt zusätzlich `fk_sync_tasks_cleaning_slot` an (Q5, der siebte Bezug der
Nachzieh-Aufgabe) und hängt mit `fk_cleaning_slots_sheet_library` an der
Bibliotheks-Werteliste aus Q2. Die Ferien-Zeile derselben Tabelle führt „Q1, Q3, Q5"
korrekt; hier ist der Stand nicht mitgezogen worden.
Vorschlag: Spalte auf „Q3, Q5" setzen (und Q2, falls F2 die Bibliothek bestätigt).
```

```
[PUTZDIENST-F7] putzdienst · Klasse 5 · fk_cleaning_buyouts_payment_mode
Das mitgeführte `is_invoiced` soll nicht lügen können — der zusammengesetzte
Fremdschlüssel hält es (nachgestellt: `('invoiced', false)` wird abgewiesen). Eine
Gegenprobe dafür hat das Skript nicht; geprüft wird nur `ck_..._no_invoice` über eine
Zeile, deren Flag ehrlich ist. Für die gleich gebaute mitgeführte Terminart gibt es die
Probe („Angebot, das seinen regulären Termin als Großputz ausgibt") — hier fehlt sie an
beiden Freikäufen.
Vorschlag: Je Freikauf eine `expect_reject`-Probe mit `payment_mode='invoiced'` und
`is_invoiced=false`.
```

```
[PUTZDIENST-F8] putzdienst · Klasse 1 · cleaning_assignments.no_show
01 Z7 sagt, nach dem Freikauf „erscheinen Eltern an dem Tag nicht zum Putzdienst und
zahlen dafür auch keine Strafe". `no_show = true` auf einer Zuteilung, an der ein
`cleaning_slot_buyouts` hängt, geht durch (nachgestellt). Die Regel spannt zwei Tabellen
und kann kein CHECK sein — sie liegt an der Route (TASK-101, Done). Nur steht davon
nichts im Schema, obwohl die Nachbarauslassung („Bewusst KEINE Familie an der Annahme")
genau so begründet ist.
Vorschlag: Ein Kommentar an `no_show`, der die Auslassung samt ihrer Stelle benennt.
```

```
[PUTZDIENST-F9] putzdienst · Klasse 5 · uq_cleaning_cycle_quotas
„die Platzzahl … steht als Standard je Art einmal für das ganze Jahr" (01) — der
Schlüssel steht in der Namensliste des Skripts, eine Gegenprobe hat er nicht. Die
Schwester `uq_cleaning_family_quotas` hat eine („zweite abweichende Pflichtmenge
derselben Familie und Art im selben Jahr").
Vorschlag: Eine `expect_reject`-Probe auf eine zweite Zeile mit (Zyklus 1, Art 1).
```

```
[PUTZDIENST-F10] putzdienst · Klasse 5 · cleaning_cycles.registration_mail_sent_at
Die Marke trägt Z2 und macht den Lauf einmalig („er sucht die Zyklen, die keine
tragen"). Sie hat weder eine Gegenprobe noch — anders als die beiden Erinnerungsmarken
und die eingescannte Liste — eine Spaltenprüfung im Skript. Ein Umbenennen beim Bau in
`wb-backend` fiele hier nicht auf.
Vorschlag: In den vorhandenen Spalten-Existenzblock aufnehmen.
```

## Angesehen, nicht als Fund gewertet

```
putzdienst · Kopfkommentar `cleaning_cycles`: „Das Putzdienstjahr läuft von Oktober bis
        September, der Unterricht beginnt schon im September — dieser Monat Puffer ist
        Absicht" setzt zwei Sätze aus dem „Auslöser" und dem eingeklappten Hinweis mit
        einem Gedankenstrich zusammen. Beide Hälften sind wörtlich, die Aussage die des
        Blocks — kein Sinnzitat.
putzdienst · `cleaning_family_quotas`: „(null Termine)" und „(anteilig)" kürzen im
        Block je eine offene Klammer weg. Der gekürzte Teil trägt nichts, was das Feld
        beträfe.
putzdienst · `no_show = true` bei leerem `attendance_recorded_at` geht durch. Das ist
        kein zweiter Fall neben F8: Der Anker macht die Angabe bedeutungslos, nicht
        falsch, und dieselbe Route schreibt beide (TASK-101).
putzdienst · `cleaning_buyouts.bought_count` lässt sich über die Pflichtmenge des
        Zyklus hinaus setzen (99 bei 5 geht durch). Die offene Zahl ist eine Differenz
        über vier Tabellen; ein CHECK kann sie nicht tragen, und der Block verlangt
        keinen Riegel.
putzdienst · Der Einzel-Freikauf hat keinen Riegel gegen die Freikauf-Frist. „Die Frist
        steht bewusst nicht als Spalte" ist begründet, und TASK-019 (Done) trägt sie an
        der Stelle, die die Zahlung auslöst.
putzdienst · Eine neue Zuteilung an einem abgesagten Termin geht durch. Ein Constraint
        dagegen wäre nicht baubar, ohne die bestehenden zu treffen: „Ein abgesagter
        Termin bleibt stehen, damit die betroffenen Familien sehen, was mit ihm war".
putzdienst · `fk_cleaning_slot_buyouts_assignment` mit NO ACTION sah nach einem
        blockierten Lösch-Lauf aus; `querschnitt-schema.sql` führt die Freikäufe in
        Stufe 3 ausdrücklich vor `cleaning_assignments`, und die Probe des Skripts
        räumt in derselben Folge.
querschnitt · „die beiden Preise stehen als Werte im System" trägt:
        `configured_values` führt `cleaning_buyout_cents` und `cleaning_penalty_cents`.
querschnitt · Die vier Aufgaben aus 01 haben ihren Bezug: der Monatslauf der Strafen
        `reference_period`, die Druckaufgabe `cleaning_slot_id`; „Zuteilung freigeben"
        und „Anwesenheit eintragen" folgen aus dem Bestand statt aus einer Zeile — so
        an `sync_tasks` ausgeschrieben.
```

Alle übrigen wörtlichen Zitate der beiden Dateien wurden gegen 01, 02 und 03 gehalten
und stimmen im Wortlaut.

## Nach Gewicht

F1, F2, F3, F4, F5, F6, F7, F8, F9, F10 — in dieser Reihenfolge aufgeschrieben und
sortiert. Betrieblich bricht allein F1; F2 blockiert eine Route, bevor sie gebaut wird;
F3 bis F10 kosten Belegkraft, keine Daten.

**Die Domäne kommt nicht ohne Fund durch: zehn.**
