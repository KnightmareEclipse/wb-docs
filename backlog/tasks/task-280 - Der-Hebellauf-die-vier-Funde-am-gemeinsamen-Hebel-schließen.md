---
id: TASK-280
title: 'Der Hebellauf: die vier Funde am gemeinsamen Hebel schließen'
status: To Do
assignee: []
created_date: '2026-09-06 17:43'
labels:
  - wb-backend
  - pruefzyklus
milestone: m-0
dependencies: []
ordinal: 292000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Vier Funde der Routen-Prüfläufe liegen in app/core/ und app/db/, nicht in einer Domäne. Ein Domänenlauf darf sie deshalb nicht anfassen — sonst bauen sechs nebenläufige Sessions denselben Hebel sechsmal verschieden —, und ihre Berichte sind auf genau diesen Rest gekürzt: routen-cleaning.md, routen-mensa.md, routen-gesundheit.md, routen-auth.md. Geschlossen werden sie mit prompts/api-reparieren.md in einer wb-backend-Session im Hauptbaum, ohne DOMÄNE: Der Prompt kennt den Hebellauf und setzt für ihn 'diese eine Funktion, und keine zweite' an die Stelle der einen Domäne. Alle vier zusammen in einem Lauf, weil sie einander an derselben Funktion treffen — ein zweiter Lauf sähe, was der erste gebaut hat, statt was sein Bericht meint. Zwei der vier sind bereits entschieden und ihre Vorgabe steht im Plan, nicht mehr im Bericht: cleaning-R17 in api/gemeinsam.md ('Sofortzahlung', Schritt 1), MENSA-R2 in api/mensa-api.md an der Zeile der Route.

**Nicht auf dem kritischen Pfad des Putzdiensts** (06.09.2026). Keiner der vier Funde und keine der
vier Entscheidungen aus TASK-204 hält den Livegang von Stammdaten und Putzdienst auf: Die
Lauf-Marken des Putzdiensts hängen bereits an `cleaning_cycles` und `cleaning_slots`, der
Stichtag der Werte wird frühestens zum Jahresschluss am 01.08.2027 fällig, und die Admin-Rolle
trägt heute allein der Betreiber. Fällig sind sie zum Livegang der **Voranmeldung** — dort trifft
der Anker-Fund zwei Kinder derselben Familie (TASK-277, TASK-278). Bis dahin trägt die Doku ihre
Lücke sichtbar: api/gemeinsam.md und hebel.md sagen an jeder der vier Stellen "entschieden, nicht
gebaut".
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 cleaning-R17: die Zahlungssitzung wird nach dem Ende der Anfrage-Transaktion eröffnet, an allen vier Aufrufstellen (cleaning zweimal, anmeldung, ferien)
- [ ] #2 MENSA-R2: domestic_services_management erreicht das einzelne Kind über einen eigenen engen Zweig, nicht über UNRESTRICTED_ROLES
- [ ] #3 GESUNDHEIT-R4: die Klassenlehrkraft ist in staff_sees_child ein eigener Zweig, sie erreicht ihr Kind auch ohne roles-Zeile teacher
- [ ] #4 AUTH-R6: optional_user in ferien.py macht nur 401/403 zu None und reicht die 503 des Identitätsanbieters durch
- [ ] #5 Je Fund ein Test, der vor der Änderung rot war; pytest, ruff, mypy und schema-check.sh danach grün
- [ ] #6 Die vier Berichte sind gelöscht
<!-- AC:END -->
