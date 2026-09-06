# Routen-Prüfbericht: mensa — der offene Rest

Elf der zwölf Funde sind geschlossen (`wb-backend`, Commits `69afb3d`, `d91a1d5`, `ff94212`,
`36659ca`, `486e3a5`, `9fd46e1`, `2604a77`; MENSA-R13 war beim Öffnen der Stelle bereits durch
`0c3ee5b` behoben). Einer wartet auf den dreizehnten Lauf, weil er den gemeinsamen Hebel betrifft.

[MENSA-R2] Klasse 5/8 · GET /children/{child_id}/meal-profile
Plan: „secretariat, school_management, domestic_services_management, day_care_staff". Der Router
lässt `domestic_services_management` durch `require_staff`, aber das zweite Tor, `reach_child` →
`staff_sees_child` (`app/core/security.py`), kennt die Rolle nirgends: weder in
`UNRESTRICTED_ROLES`, noch als Zweigrolle, noch als Hortrolle, noch als `teacher`. Die Rolle
erreicht damit kein einziges Kind.
Gemessen: In `test_the_canteen_reads_no_single_profile` `as_role("canteen")` durch
`as_role("domestic_services_management")` ersetzt — `assert 404 == 403`. Die Rolle bekommt nicht
die erwartete Absage der Rolle, sondern die Absage der Reichweite.
Vorschlag: `domestic_services_management` in `UNRESTRICTED_ROLES` aufnehmen — oder, wenn sie das
einzelne Kind nicht sehen soll, aus der Route streichen und Plan und Block nachziehen.

**Nicht in diesem Lauf geschlossen, und warum.** Der Fund nennt seine eigene Zuständigkeit: Er
liegt am gemeinsamen Hebel (`UNRESTRICTED_ROLES`/`staff_sees_child` in `app/core/security.py`),
nicht in `mensa.py`, und ein Reparaturlauf ändert `app/core/` nur im ersten Lauf; dieser ist einer
von mehreren nebeneinander laufenden Fachdomänen-Läufen. Die zweite Bauform des Vorschlags — die
Rolle aus der Route streichen — kollidiert mit dem Block: `soll-prozesse/11-mensa.md` selbst zählt
die Hauswirtschaftsleitung zu den Stellen, für die die Essensvariante „sichtbar" ist, und ein
Domänenlauf fasst `soll-prozesse/` ohnehin nicht an.
