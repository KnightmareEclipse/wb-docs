# Routen-Prüfbericht: auth — der offene Rest

Sieben der acht Funde sind geschlossen (`wb-backend`, Commits `9632844`, `143e5aa`, `ef9ae3b`;
`wb-elternportal` für AUTH-R8; dazu zwei reine Doku-Funde ohne Code-Commit, AUTH-R5 und AUTH-R7).
Einer bleibt offen, weil seine Stelle in einer anderen Domäne liegt — „Diese eine Domäne, und
keine zweite" (`api-reparieren.md`).

[AUTH-R6] Klasse 8 · `app/routers/ferien.py:154` `optional_user` (fremde Domäne)
`get_current_user` antwortet 503, wenn Entra-ID nicht erreichbar ist — „the caller's token
may be fine". `optional_user` fängt `except HTTPException` und macht daraus `None`: aus dem
Ausfall des Identitätsanbieters wird „nicht angemeldet", und ein Mitarbeitender sieht still
die öffentliche Ansicht. Beim Öffnen der Stelle bestätigt: `except HTTPException` fängt
weiterhin jede Klasse, die 503 eingeschlossen.
Gelesen, nicht gemessen: hier nur genannt, weil es der auth-Hebel ist, den sie umgeht — die
Stelle selbst liegt in `ferien.py`, nicht in `auth.py`, und deren eigener Prüfbericht ist
bereits geschlossen. Ein Reparaturlauf ändert eine zweite Domäne nicht, auch keine kleine.
Vorschlag: nur 401/403 zu `None` machen und die 503 durchreichen — im nächsten Lauf, der
`ferien.py` anfasst.
