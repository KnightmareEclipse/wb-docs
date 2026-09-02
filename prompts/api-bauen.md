# Prompt: die Routen einer Fachdomäne bauen

Gegenstück zu [`api-planen.md`](api-planen.md). Dort entsteht der Plan, hier der Code. **Eine Domäne
je Durchgang**, dieselbe Portionierung wie beim Planen und beim Schema.

Gearbeitet wird **in einer `wb-backend`-Session**, nicht hier: Dort lädt sich `CLAUDE.md` des Repos
von selbst, und alles, was über Stil, Ablage, Datenbankzugriff, Auth, Tests und Migrationen gilt,
steht darin. Dieser Prompt wiederholt nichts davon.

Kopieren, `DOMÄNE` ersetzen, absenden. Effort `high`, bei einer Domäne mit vielen
Berührungspunkten `xhigh`; Thinking anlassen. Vorher `git status` sauber, der Stack oben.

**Dieser Durchgang läuft ohne Rückfrage** — was das heißt, steht in [`gemeinsam.md`](gemeinsam.md).

---

Wir bauen die Routen der Fachdomäne **DOMÄNE** in `wb-backend`. Auftrag ist
`wb-docs/api/DOMÄNE-api.md`. Es gilt `gemeinsam.md`, `CLAUDE.md` beider Repos und
`wb-backend/README.md`; beides liest du zuerst und ich wiederhole es hier nicht.

## Die eine Regel, aus der der Rest folgt

**Der Plan ist die Spezifikation, nicht die Anregung.** Jede Route in `api/DOMÄNE-api.md` wird
gebaut, keine wird dazuerfunden, und keine wird stillschweigend anders gebaut, als sie dort steht.
Die sechs Angaben je Route — wer darf, worauf eingeschränkt, schreibend oder lesend, welcher Aktor,
welche enge Rolle — sind der Prüfauftrag für den Test, nicht Prosa.

## Fünf Regeln entscheiden hier über Erfolg, und keine steht im Plan

Sie stehen in `wb-backend/CLAUDE.md` §6 und `README.md` unter „Writing data". **Lies beide Stellen**
— hier stehen nur ihre Namen, damit du weißt, wonach du suchst, nicht ihre Fassung:

`route_class=TransactionRoute` an jedem Router · kein `commit` im Endpunkt · kein Bulk-`update()`
oder `delete()` · `GRANT UPDATE` immer spaltengenau, nie tabellenweit · `__change_anchor__` und
`__protected_columns__` an jedem Modell.

Vier davon fängt ein Test, wenn du sie vergisst (`tests/test_changelog.py`,
`tests/test_privileges.py`). Die fünfte fängt niemand: Ein Endpunkt, der die Ownership-Bedingung aus
der Spalte „Worauf eingeschränkt" nicht in die Query schreibt, ist grün und offen zugleich.

## Die Reihenfolge, und sie ist keine Empfehlung

1. **Modelle**, falls die Domäne noch keine hat — ein Modul je Domäne.
2. **Migration**: die der Domäne **bearbeiten**, nicht eine neue anhängen, solange kein Bestand
   existiert, der den Neuaufbau nicht überlebt (`CLAUDE.md` §6). Die Tabellenrechte gehören in
   dieselbe Migration; eine Spalte enger zu ziehen heißt erst `REVOKE` auf der Tabelle, dann die
   erlaubten Spalten neu granten.
3. **Eine bearbeitete Migration heißt: Datenbank wegwerfen und neu abspielen.** Alembic stempelt
   nach Id, nicht nach Inhalt — ein `upgrade` auf einer Datenbank, die die alte Fassung schon lief,
   ist ein stiller Nichts-Lauf. Und `migrate` liest die Quellen aus dem Image: ohne vorheriges
   `build` fährst du den vorigen Stand mit Rückgabewert 0.
4. **Router**, einer je Domäne, registriert in `main.py`.
5. **Tests**, je Route mindestens einer auf die Ownership-Bedingung — nicht auf die Rolle. Der Test,
   der zählt, ist der, in dem ein Berechtigter eine fremde Id rät und eine Absage bekommt.
6. **Die Prüfskripte aus `wb-docs/schema/`** gegen die neu abgespielte Datenbank, alle dreizehn und
   nicht nur die der Domäne (`wb-docs/CLAUDE.md`, Abschnitt Schemaarbeit). In den Bericht kommt der
   Rückgabewert je Datei, nicht der Text auf dem Schirm.

## Wenn der Plan falsch ist

Er wird es an einigen Stellen sein — beim Bau fällt auf, was beim Planen nicht auffallen konnte:
eine Spalte, die die Route so nicht liefern kann, zwei Routen, die dieselbe Transaktion brauchen,
eine Bedingung, die sich nicht in einer Query ausdrücken lässt.

**Dann wird der Plan geändert, nicht umgangen.** Im selben Lauf, im selben Commit wie der Code, der
ihn widerlegt, und mit dem Grund in der Datei. Code, der schweigend von seinem Plan abweicht, macht
aus einer Spezifikation eine Behauptung — und die nächste Domäne baut gegen die Behauptung.

Fällt dir am **Schema** etwas auf: eine Zeile in deinen Bericht, kein Eingriff, es sei denn die
Route ist ohne die Änderung nicht baubar. Dann ist die Änderung Teil dieses Laufs, und
`wb-docs/schema/` samt Prüfskript und Kopfkommentar wird nachgezogen (die Liste steht in
`wb-docs/CLAUDE.md`).

## Die Gegenprobe, und sie gehört zur Aufgabe

Mechanisch, in beide Richtungen, nicht aus dem Gedächtnis:

1. Jede Route in `api/DOMÄNE-api.md` existiert im Router, mit derselben Methode, demselben Pfad und
   derselben Einschränkung.
2. Jeder Endpunkt im Router steht im Plan. Einer ohne ist zu streichen oder in den Plan zu
   schreiben — mit Begründung, warum er dort fehlte.

Zähl beides aus und schreib die zwei Zahlen in den Bericht. Weichen sie ab, steht darunter je
Abweichung eine Zeile.

## Was am Ende steht, ist der Beleg und nicht die Behauptung

- `pytest` grün, mit der Zahl der Tests **vorher und nachher** — eine Domäne, die keine Tests
  hinzufügt, hat keine gebaut.
- `ruff check`, `ruff format --check`, `mypy app` ohne Befund.
- `tests/test_privileges.py` und `tests/test_changelog.py` ausdrücklich genannt: Sie fangen die zwei
  Fehler, die von außen unsichtbar sind.
- Die dreizehn Prüfskripte mit ihrem Rückgabewert.
- **Ein Pull Request**, damit `ci` denselben Lauf unabhängig nachfährt. Ein Push auf `main` löst ihn
  nicht aus (`rules.md` Abschnitt 2) — und ein Bau, den nur die eigene Maschine gesehen hat, ist
  nicht geprüft, sondern nur beobachtet.

Ein Commit je Domäne, nicht je Datei: Modelle, Migration, Router und Tests sind eine Änderung, oder
sie sind eine halbe.

## Was nicht in diesen Durchgang gehört

- **Keine Route ohne Zeile im Plan.** Auch keine, die offensichtlich fehlt — die gehört erst in den
  Plan und dann in den Code, und das ist derselbe Lauf, aber nicht dieselbe Datei.
- **Keine Oberfläche.** Welche Seite die Route ruft, entscheidet dieser Durchgang nicht.
- **Kein Deploy.** Entwickelt wird lokal; ausgerollt wird auf Ansage und nie nebenbei.
- **Keine Abstraktion für die nächste Domäne.** `CLAUDE.md` §14 gilt hier ungebremst: Der zweite
  Fall darf abschreiben, erst der dritte darf verallgemeinern.
