# Routen-Prüfbericht: cleaning — der offene Rest

Siebzehn der achtzehn Funde sind geschlossen (`wb-backend`, Commits `cleaning-R…`), einer wartet
auf den dreizehnten Lauf, weil er keine Domäne allein betrifft.

[cleaning-R17] Klasse 6 · POST …/buyouts und POST …/buyout
`checkout.open()` — ein HTTP-Aufruf an Stripe — läuft innerhalb der Request-Transaktion von
`get_db()`; `TransactionRoute` schließt sie erst nach dem Handler. Geschrieben wird nichts und
gesperrt auch nichts, der Preis ist eine gehaltene Verbindung über die Stripe-Runde. Genau die
Bauform, gegen die `TransactionRoute` gebaut wurde (`app/db/session.py`).
Gelesen: betrifft vermutlich jede Domäne, die eine Zahlung eröffnet — zählbar erst im
dreizehnten Lauf.
Vorschlag: die Sitzung nach dem Ende der Transaktion eröffnen oder die Stelle im Plan als
bewusst benennen.

**Nicht in diesem Lauf geschlossen, und warum.** Der Fund nennt seine eigene Zuständigkeit: Er
liegt am gemeinsamen Hebel (`app/db/session.py`), nicht in `cleaning.py`, und ein Eigenbau in
dieser einen Domäne wäre genau das, was `api-reparieren.md` verbietet. Ein Reparaturlauf ändert
`app/db/` nur im ersten Lauf; dieser ist der vierte.

[cleaning-R12] **verworfen, gemessen.** Der Fund nennt zwei Sicherungen gegen das eigene Angebot
im Tausch — den Familienfilter in `takeable` und `row[0] != offer_id` in `_mutual`. Beide
zusammen entfernt: eine Familie kann ihr eigenes zweites Angebot weiterhin nicht annehmen. Erst
mit `row[4] in standing` fällt die Regel. Die zwei genannten Zeilen tragen sie also nicht, sie
sind neben ihr; gemessen wird `standing` jetzt von
`test_a_date_the_family_already_stands_on_cannot_be_ticked` (cleaning-R9).
