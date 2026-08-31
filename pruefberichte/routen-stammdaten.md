# Prüfbericht: Routen der Domäne stammdaten

Die vierzehn übrigen Funde des dreizehnten Prüfzyklus sind geschlossen; die Historie hält sie.
Offen bleibt einer, weil ihn kein Block entscheidet.

## Funde

```
[STAMMDATEN-R14] Klasse 5 · PUT /persons/{person_id}/email als Versandweg
Die Route schickt über Graph eine Mail an eine vom Aufrufer frei gewählte Adresse und
trägt — anders als `POST /auth/codes` — keines der vier Mailbudgets des Plans. Die
einzige Schranke ist die globale Notbremse von 300 Anfragen je Minute und Adresse.
Der Plan verlangt hier keines, deshalb steht das als Beobachtung und nicht als
Planabweichung; der Absenderruf der Schule hängt trotzdem daran.
Vorschlag: dasselbe Adressbudget wie am Anmeldecode anlegen — es liegt schon in
`app/routers/auth.py`.
```
