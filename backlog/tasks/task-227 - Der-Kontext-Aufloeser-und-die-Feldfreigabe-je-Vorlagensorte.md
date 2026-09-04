---
id: TASK-227
title: Der Kontext-Aufloeser und die Feldfreigabe je Vorlagensorte
status: To Do
assignee: []
created_date: '2026-09-04 00:19'
labels:
  - wb-backend
  - dsgvo
milestone: m-5
dependencies: []
ordinal: 239000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Damit ein neues Feld keinen Code kostet, darf der Kontext kein handgebautes Dictionary sein. Damit er nichts leakt, darf er auch kein Auflöser mit `__getattr__` sein, der bei jedem Namen in die Datenbank greift.

**Die Bauform: der Kontext wird vorab aus einer Deklaration gebaut.** Was nicht deklariert ist, existiert nicht — kein Prüflauf entscheidet darüber, es ist schlicht nicht da. Dazu `jinja2.StrictUndefined`, damit ein unbekannter Name **wirft** statt leer zu rendern. Das schlägt zwei Fliegen: `{{ gesundheit.hiv }}` in einem Ferienbrief scheitert beim Hochladen, und ein Tippfehler `{{ kind_nmae }}` ebenso — statt einer leeren Stelle im unterschriebenen Vertrag.

**Die Freigabe spricht die Sprache, die es schon gibt.** `health_visibility_scopes` und `health_field_visibility` samt `presence_only` sind gebaut und rollenweise über GRANTs vergeben; ein zweites Modell daneben wäre genau das, was `grenzkarte.md` verbietet. Eine Vorlagensorte deklariert deshalb **einen Sichtkreis, keine Feldliste**:

| Sorte | darf |
|---|---|
| `care_contract` | `kind`, `familie`, `vertrag`, `gesundheit` im Sichtkreis **care** |
| `school_contract_gs` | dieselben, `gesundheit` im Sichtkreis der Schule |
| Ferienbrief | `kind`, `familie` — **kein** `gesundheit` |

Damit ist ein neues Merkmal im Sichtkreis `care` in der Vorlage verfügbar, sobald die Zeile in der Werteliste steht. Ohne Code, ohne Deploy.

**Der strengere Maßstab ist der Leserkreis der Datei, nicht der der Zeile.** Die Bibliothek gibt Sekretariat und Geschäftsführung Vollzugriff; ein Feld, das ins Dokument gerät, ist für jeden Leser dieses Dokumenttyps da. Die Freigabe hängt deshalb an „wer liest Dokumente dieser Art".

**Zwei Filter, einmal geschrieben, für jedes Boolean in jedem Formular:** `| ja` und `| nein` liefern `X` oder leer, mit optionalem Argument für ein anderes Zeichen. Kästchen-Glyphen (`☒`) brauchen eine Schrift, die sie hat — sonst steht im PDF ein leeres Viereck; `X` in der Dokumentschrift kann nicht schiefgehen. `.true` geht nicht als Name, `true` ist in Jinja ein Schlüsselwort.

`{%p if %}` über denselben Namensraum bleibt erlaubt und ist erwünscht: So schaltet die Geschäftsführung ganze Absätze, ohne dass deren Text im Code landet. Die Regel dahinter: **Aus den Daten kommen Werte und Zeilen, aus der Vorlage kommt jeder Satz.**

`[?]` Die Namen der Platzhalter sind extern sichtbar — die Geschäftsführung tippt sie. Deutsch oder englisch, `{{ kind_name }}` oder `{{ child_name }}`. — Betreiber
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Der Kontext wird vorab aus der Deklaration gebaut; ein nicht deklarierter Name existiert nicht
- [ ] #2 StrictUndefined ist gesetzt: ein unbekannter Name wirft, statt leer zu rendern
- [ ] #3 Die Freigabe laeuft je Namensraum und fuer Gesundheit je Sichtkreis — ein neues Merkmal ist damit kein Code
- [ ] #4 presence_only zieht mit: wo der Sichtkreis nur das Vorliegen sieht, steht das auch im Dokument
- [ ] #5 Die Vorschau laeuft nur gegen Beispieldaten, nie gegen ein echtes Kind
- [ ] #6 Die Namen der Platzhalter sind mit dem Betreiber besprochen — sie sind extern sichtbar
<!-- AC:END -->
