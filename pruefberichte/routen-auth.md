# Routen-Prüfbericht: auth — der offene Rest

Sechs der acht Funde sind geschlossen (`wb-backend`, Commits `9632844`, `143e5aa`, `ef9ae3b`; dazu
zwei reine Doku-Funde ohne Code-Commit, AUTH-R5 und AUTH-R7). Zwei bleiben offen, weil ihre Stelle
in einem anderen Repo oder einer anderen Domäne liegt — „Diese eine Domäne, und keine zweite"
(`api-reparieren.md`).

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

[AUTH-R8] Klasse 8 · `wb-elternportal/src/Login.tsx:78` (fremdes Repo, keine Route)
Block 00 Z1: die Antwort des Feldes nennt „der Code sei unterwegs, dazu **die
Absenderadresse** und den Hinweis, im Spam-Ordner nachzusehen". Der Spam-Hinweis steht, die
Absenderadresse fehlt. Beim Öffnen der Stelle bestätigt: nur der Spam-Hinweis steht dort.
Gelesen, nicht gemessen — und außerhalb dessen, was eine `wb-backend`-Session bauen kann:
kein Worktree, kein Commit-Recht in diesem Lauf für `wb-elternportal`.
Vorschlag: die Absenderadresse in den Hinweis aufnehmen; sie steht als `mail_sender` schon in
`app/core/config.py`.
