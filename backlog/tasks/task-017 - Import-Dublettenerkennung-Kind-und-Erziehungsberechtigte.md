---
id: TASK-017
title: 'Import: Dublettenerkennung Kind und Erziehungsberechtigte'
status: To Do
assignee: []
created_date: '2026-08-27 11:35'
updated_date: '2026-08-30 18:23'
labels:
  - import
  - stammdaten
milestone: m-1
dependencies: []
references:
  - schema/stammdaten-schema.sql
ordinal: 17000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Nachname + Geburtsdatum beim Kind, Vor- + Nachname bei Erziehungsberechtigten. Die E-Mail trägt dort nicht mehr.
<!-- SECTION:DESCRIPTION:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Der genannte Schlüssel trennt Zwillinge nicht: 'Nachname + Geburtsdatum beim Kind' trifft bei zwei Geschwistern derselben Geburt immer, und das Soll führt sie ausdrücklich als zwei Kinder ('Zwillinge sind zwei', 05 Z3; 'Zwillinge sind zwei Verträge', 08). Ein Import, der darüber zusammenführt, macht aus zwei Kindern eines — und das fällt erst auf, wenn eines von beiden in keiner Klassenliste steht. Der Vorname muss in den Schlüssel, oder der Abgleich meldet und führt nicht zusammen. Bei den Erziehungsberechtigten ist der genannte Schlüssel (Vor- und Nachname) aus demselben Grund ein Hinweis und keine Entscheidung. Derselbe Befund steht an TASK-013, das denselben Schlüssel für die laufende Bewerbung vorschlägt.


**Die Familienbildung, entschieden am 06.09.2026.** ASV kennt keine Familie; Weltenbaum haengt
Putzdienst und Elternbonus daran. Sie wird deshalb im Import vorgeschlagen und vom Sekretariat
bestaetigt — **nicht von Hand gebildet**: Bei einem Jahrgangsbestand dieser Groesse waere das eine
Woche Arbeit, waehrend die Automatik den Grossteil sicher trifft.

Zwei Quellen, in dieser Reihenfolge:

1. **Der Geschwister-Graph.** `svp_schueler_stamm_geschwister` ist eine reine Paarbeziehung
   (`schueler_stamm_id`, `geschwister_id`); eine Familie ist die **Zusammenhangskomponente** darin.
   Ob die Tabelle gepflegt ist, zeigt erst der echte Export.
2. **Deckungsgleiche Kontaktmenge** als Rueckfall, wo der Graph schweigt: dieselben
   Erziehungsberechtigten heissen dieselbe Familie.

**Die Anschrift ist ausdruecklich kein Kriterium.** "Familie heisst die Eltern, nicht der Haushalt.
Getrennt lebende Eltern bleiben eine Familie" (hebel.md) — wer ueber die Adresse gruppiert, zerlegt
genau die Familien, die der Putzdienst als eine zaehlen muss.

**Was das Sekretariat bekommt, ist die Zweifelsliste**, nicht der ganze Bestand: Kinder, die keine
der beiden Quellen erfasst; Widersprueche zwischen Graph und Kontaktmenge; und die Patchwork-Faelle,
in denen sich zwei Kontaktmengen ueberschneiden, ohne gleich zu sein. Alles Uebrige laeuft durch.

**Zwei Fragen gehoeren an den echten Export und damit ans lokale Modell** (Betreiber, 06.09.2026):
Welches Schuljahr die Kontakte einer Familie liefert — Vorschlag ist das juengste, in dem das Kind
eingeschrieben war —, und wie `svp_kontakt.name1/name2/name3` real belegt sind, denn
`persons.last_name` ist NOT NULL und getrennt gefuehrt. Beides ist am DDL nicht zu beantworten.


**Am echten Export gemessen (06.09.2026)** — selektiv restauriert in eine Wegwerf-Datenbank,
ausgewertet ausschliesslich als Zaehlung, Container danach entfernt. Vier Annahmen sind damit
widerlegt, und der Weg oben aendert sich:

| | |
|---|---|
| Kinder | 737 |
| `svp_schueler_stamm_geschwister` | **0 Zeilen** |
| `svp_schueler_schuljahr_kontakt` | **0 Zeilen** |
| `svp_kontakt` | **0 Zeilen** |
| `svp_schueler_anschrift` mit `person_id` | 1460, fuer alle 737 Kinder |
| verschiedene `person_id` darin | **1460** — jede genau einmal |
| Elternteile ohne Geburtsdatum | **1460, also alle** |
| eindeutig nach Vor- und Nachname | 830 |
| eindeutig nach Name + Adressinhalt | 963 |
| eindeutig nach Adressinhalt allein | 505 |

1. **Der Geschwister-Graph faellt aus.** Die Tabelle ist leer; Quelle 1 der Familienbildung
   existiert in diesem Bestand nicht.
2. **Der Kontaktweg faellt aus.** `svp_kontakt` und `svp_schueler_schuljahr_kontakt` sind leer —
   `ASV_TO_HUB_MAPPING.md` fuehrt beide, dieser Export nutzt sie nicht. Die Erziehungsberechtigten
   haengen an **`svp_schueler_anschrift`** (`schueler_stamm_id`, `person_id`, `anschrift_id`,
   `wl_anschriftstyp_id`), und die traegt zusaetzlich `im_verteiler_schriftverkehr` und
   `hauptansprechpartner` — die Vorlage fuer `family_guardians.include_in_correspondence`.
3. **Jede `person_id` kommt genau einmal vor.** Geschwister teilen sich die Elternzeile nicht;
   dieselbe Mutter steht bei zwei Kindern als zwei Personen. Die Deduplizierung ist damit
   **Voraussetzung** der Familienbildung und kein Nachgang: Ueber IDs verglichen hat kein
   Geschwisterpaar je dieselbe Elternmenge.
4. **Kein Elternteil traegt ein Geburtsdatum**, und jede Person traegt ihre **eigene**
   `anschrift_id` (daher 12.631 Anschriften). Verglichen werden kann deshalb nur ueber den Namen
   und den **Adressinhalt**, nie ueber eine ID.

**Was daraus folgt.** Der Name allein fuehrt 1460 auf 830 zusammen; nimmt man den Adressinhalt
hinzu, bleiben 963 — die Differenz von 133 sind Faelle, in denen derselbe Name an zwei Adressen
steht: getrennt lebende Eltern, Schreibvarianten, oder zwei echte Namensvettern. Genau diese 133
sind die Zweifelsliste fuers Sekretariat, und sie ist damit ueberschaubar statt hunderte Zeilen
lang. Zum Abgleich: 505 verschiedene Adressen bei 737 Kindern.
<!-- SECTION:NOTES:END -->
