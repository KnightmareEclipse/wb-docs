---
id: TASK-130
title: Die Anfrage-Transaktion committet erst nach den Hintergrund-Mails
status: Done
assignee: []
created_date: '2026-08-28 22:24'
updated_date: '2026-08-29 00:18'
labels:
  - wb-backend
  - putzdienst
  - befund
milestone: m-0
dependencies: []
references:
  - wb-backend/app/db/session.py
  - wb-backend/app/services/mail.py
  - api/gemeinsam.md
priority: high
ordinal: 142000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Gemessen am Tausch: der PUT auf /cleaning/swap-offers/{id}/acceptances antwortet in 27 ms mit swapped_for, direkt danach steht die Verbindung als 'idle in transaction' mit der Empfaenger-Abfrage als letztem Statement, und der Tausch ist erst nach Sekunden sichtbar. Ursache: FastAPI raeumt die yield-Dependency get_db() erst nach den BackgroundTasks ab, also nach den Graph-Aufrufen von send_tracked(). Zwei Folgen: der Tausch haelt seine beiden SELECT ... FOR UPDATE-Sperren ueber zwei externe HTTP-Aufrufe hinweg, und eine Oberflaeche, die nach dem Schreiben neu laedt, sieht den alten Stand. Betrifft jede mailende Route; elternseitig nur den Tausch, weil Reservieren und Freigeben nicht mailen. Das Elternportal nimmt deshalb die Antwort der Route als Auskunft und nicht die neu geladene Liste - fuer die Sekretariatsansichten (TASK-113) traegt das nicht, dort loest jede Terminaenderung eine Mail aus. Zwei Wege, beide mit Preis: (a) Mail ueber den bestehenden Fuenf-Minuten-Lauf statt ueber BackgroundTasks - eine Regel weniger ('was mailt, ist ein Lauf'), Preis: die Bestaetigungsmail kommt bis zu fuenf Minuten spaeter, und outbound_emails braucht eine Marke fuer 'noch nicht raus'. (b) Die Transaktion vor den Hintergrund-Tasks schliessen, statt sie von FastAPI abraeumen zu lassen - Preis: eine eigene Stelle, die die Reihenfolge haelt, neben der Zusage aus wb-backend/README.md 'Writing data', dass ein Endpunkt nicht selbst committet.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Nach der Antwort einer schreibenden Route steht keine Transaktion mehr offen - gegengeprueft an pg_stat_activity, nicht am Augenschein
- [x] #2 Der Tausch haelt seine FOR-UPDATE-Sperren nicht mehr ueber einen externen Aufruf hinweg
<!-- AC:END -->
