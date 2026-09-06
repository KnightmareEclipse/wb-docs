# Prüfbericht: Routen der Domäne gesundheit — der offene Rest

Gegen `origin/gesundheit-umbau` (`1569109`). Sechs der acht Funde sind geschlossen (`wb-backend`,
Commits `eddddf4`, `5dbe008`; `wb-docs`, Commit `0315837`). Zwei bleiben offen.

[GESUNDHEIT-R4] Klasse 5 · GET /children/{child_id}/health-record, PUT /children/{child_id}/health-note
Plan: `class_lead` gehört „der Klassenlehrkraft (`classes.class_teacher_id`, **keine `roles`-Zeile**)".
Im Code entscheidet `reach_child` vor `_sight`, und dessen `staff_sees_child` endet mit
`return TEACHER_ROLE in user.roles`: Wer Klassenlehrkraft ist, die Rolle `teacher` aber nicht
trägt, bekommt 404, bevor `is_class_teacher` überhaupt gefragt wird — lesend wie schreibend. Der
Sichtkreis hängt damit doch an einer `roles`-Zeile.
Gemessen: `return TEACHER_ROLE in user.roles` → `return False`, `test_sports_sees_…` wird rot
(404 statt 200) — die Erreichbarkeit hängt an genau dieser Zeile. Kein Test setzt eine
Klassenlehrkraft ohne `teacher`-Rolle; `as_class_teacher` vergibt sie immer.
Vorschlag: in `staff_sees_child` die Klassenlehrkraft als eigenen Zweig führen, wie `cared_for`,
dazu ein Test mit `roles=frozenset()` und gesetzter `class_teacher_id`.

**Nicht in diesem Lauf geschlossen, und warum.** Der Fund liegt am gemeinsamen Hebel
`staff_sees_child` (`app/core/security.py`), nicht in `gesundheit.py` — der Ownership-Weg, den
`reach_child` für jede Domäne prüft. Ein Umweg allein in dieser Domäne wäre ein zweiter,
abweichender Ownership-Pfad neben dem gemeinsamen, genau die Dopplung, die R6 unten als Fehler
verwirft. Ein Reparaturlauf ändert `app/core/` nur im ersten Lauf (`api-reparieren.md`); dieser ist
ein späterer.

[GESUNDHEIT-R6] Klasse 4 · **verworfen, gemessen.** Der Fund behauptet, die Schulart-Bedingung der
Schulleitung stehe redundant zweimal (`staff_sees_child` und `_sight`) und das Entfernen je einer
Kopie bleibe grün. Gemessen: beide Mutationen einzeln nachgestellt — Kopie in `_sight` entfernt,
dann rückgängig gemacht und stattdessen die Kopie in `staff_sees_child` entfernt. Beide Male wird
`test_school_management_is_bound_to_its_own_branch` rot (`KeyError: 'categories'`, weil `reach_child`
bzw. `_sight` dann 404 liefert). Die beiden Kopien sind nicht redundant: `staff_sees_child` gate't
die Existenz in `reach_child`, `_sight` bestimmt danach getrennt die Sichtbreite — beide Zwecke sind
verschieden und je einzeln schon durch den vorhandenen Test gehalten. Der Satz „zwei Kopien sind
eine zu viel" entkräftet sich an diesem Test selbst.
