---
id: TASK-204
title: Fünf domänenübergreifende Entscheidungen aus dem Prüfzyklus
status: To Do
assignee: []
created_date: '2026-09-02 23:45'
labels:
  - wb-docs
  - wb-backend
  - pruefzyklus
dependencies: []
references:
  - api/gemeinsam.md
  - app/core/security.py
  - app/services/mail.py
  - app/db/session.py
ordinal: 217000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Fünf Funde der vier bisherigen Prüfläufe liegen am gemeinsamen Hebel, nicht in einer Domäne. Ein Reparaturlauf darf sie deshalb nicht schließen (prompts/api-reparieren.md), und mit dem Löschen ihrer Berichte wären sie weg — deshalb stehen sie hier.

1. Admin an Freigabe und engen Spalten (anmeldung-R2, R3). gemeinsam.md nimmt ihn ausdrücklich aus: die engen Spalten und was einer Person zur Entscheidung zugewiesen ist — Freigabe, Gegenzeichnung, Straf-Aussetzung. app/core/security.py legt ADMIN_ROLE aber in jedem require_role und jedem staff_roles unbedingt dazu, also zeichnet ein Admin Verträge gegen und liest jede IBAN. Entweder der Satz fällt oder die Tore der Freigabe-Routen.

2. Der Mailweg (anmeldung-R6, routen-elternbonus.md). send_tracked schreibt seine outbound_emails-Zeile in einer eigenen Transaktion, committet sie und schickt sofort; drei Pläne versprechen daneben eine Transaktion samt Mails. Wirft eine Schleife nach der ersten Mail, ist der Vorgang zurückgerollt und die Familie hat ihn trotzdem gelesen. Der Elternbonus baut dieselbe Sache umgekehrt, mit background.add_task nach dem Commit. Zwei Bauformen, eine Regel fehlt.

3. Der Anker der Lauf-Marken (anmeldung-R8, R9). Die Definition selbst — eine outbound_emails-Zeile jener Zweckbestimmung, für jene Person, seit dem Moment, den der Auslöser nennt — kennt den Vorgang nicht. Zwei Kinder einer Familie teilen sich Person, Zweck und Zeitpunkt, ein ganzer Jahrgang teilt sich das Fristende aus einer Freigabe: Die erste Mail unterdrückt jede weitere dauerhaft.

4. Die Zahlungssitzung in der Anfragetransaktion (cleaning-R17). checkout.open ruft Stripe, während get_db die Transaktion hält — genau die Bauform, gegen die TransactionRoute gebaut wurde. Seit dem ersten Prüflauf geparkt.

5. configured_value ohne Stichtag (elternbonus-R1). Die Funktion nimmt immer den heute gültigen Wert. Der Jahresschluss am 1. August rechnet damit das am 31. Juli beendete Schuljahr zum neuen Satz ab; dieselbe Funktion trägt die Bewerbungsgebühr.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Entschieden und in gemeinsam.md nachgezogen: erbt Admin an einer Freigabe- oder Gegenzeichnungsroute, oder erbt er dort nicht
- [ ] #2 Entschieden und in api/gemeinsam.md nachgezogen: welche der beiden Bauformen der Mailweg ist, und was der Satz von einer Transaktion samt Mails danach verspricht
- [ ] #3 Entschieden: woran eine Lauf-Marke hängt, wenn eine Person zwei Vorgänge derselben Sorte trägt
- [ ] #4 Entschieden: die Zahlungssitzung bleibt in der Anfragetransaktion und der Preis steht im Plan, oder sie wandert dahinter
- [ ] #5 Entschieden: configured_value bekommt einen Stichtag, oder der Jahresschluss rechnet bewusst mit dem heutigen Wert
<!-- AC:END -->
