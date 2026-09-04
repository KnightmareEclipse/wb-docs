---
id: TASK-184
title: Wer außer Sekretariat und Hort an die Dateien der Schülerakte darf
status: To Do
assignee: []
created_date: '2026-09-01 20:01'
updated_date: '2026-09-01 20:29'
labels:
  - entscheidung
  - sharepoint
  - dsgvo
  - wb-docs
  - geschaeftsfuehrung
dependencies: []
references:
  - grenzkarte.md
  - soll-prozesse/08-schulvertrag.md
  - glossar.md
ordinal: 197000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Lehrkräfte sollen ggf. auf die Schülerakte zugreifen. Die Richtung ist am 02.09.2026 entschieden: **Niemand bekommt dafür SharePoint-Rechte.** An die Bibliothek kommt kein Mensch mehr direkt; gelesen wird über Weltenbaum, und dort entscheidet je Aufruf dieselbe Regel wie über die Zeile daneben (grenzkarte.md, Q2; TASK-187).

Damit fällt der Weg weg, der das Problem gewesen wäre — ein Grant je Klasse auf den Kohorten-Ordner. Er hätte der Klassenlehrkraft die ganze Akte ihrer Kinder gegeben, samt Gesundheitsblatt und Vertrag, und wäre bei jedem Wechsel der Klassenleitung nachzuziehen gewesen.

Offen bleibt allein die fachliche Frage, und die gehört der Schule: **Welche Kategorien darf eine Lehrkraft sehen, und darf sie auch ablegen?** Welche Kinder sie sieht, beantwortet TASK-161; welche Kategorien es überhaupt gibt, TASK-058.10.

**Beantwortet am 04.09.2026 (Geschaeftsfuehrung), und die Antwort ist ein Nein mit einem Schalter daneben:** Lehrkraefte sehen die **Dateien** der Schuelerakte vorerst gar nicht. Das trennt scharf zwischen Datei und Datenbank — was an Gesundheitsangaben in der Datenbank steht, sieht eine Lehrkraft nach ihrer Einsichtsstufe wie bisher; das Attest als Datei nicht.

**Gebaut ist die Moeglichkeit trotzdem**, weil ihr Anlass benannt ist: Wer ein Medikament verabreicht, will womoeglich den genauen Wortlaut des Attests lesen. `child_file_categories.is_teacher_readable` traegt das je Kategorie, Voreinstellung **false**, und heute steht es nirgends auf true — das Pruefskript weist beides nach, auch fuer eine neu angelegte Kategorie. 'Ganz und auch nur begrenzt' ist damit dieselbe Mechanik: alle Haekchen oder einige.

**Bewusst nur Lesen.** Ein zweites Haekchen fuers Ablegen gibt es nicht — der Anlass ist Nachlesen, und ein Recht ohne Anlass waere eines, das niemand begruenden kann. Spaeter waere es eine zweite Spalte und kein Umbau.

**Am Weg aendert das Haekchen nichts:** Gelesen wird ueber Weltenbaum, nie ueber eine SharePoint-Berechtigung.

Offen bleibt allein die zweite Haelfte der urspruenglichen Frage: ob die Schulleitung ihren heutigen Direktzugriff auf den Kohorten-Ordner abgibt.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Benannt, welche Kategorien eine Lehrkraft sehen darf — und ob lesend oder auch ablegend
- [ ] #2 Entschieden, ob die Schulleitung ihren Zugriff auf den Kohorten-Ordner abgibt und ebenfalls über Weltenbaum liest
- [ ] #3 Die Sicht der Lehrkraft ist eine Positivliste von Arten, nicht von Kategorien — unbestimmte Dateien bleiben außen
<!-- AC:END -->
