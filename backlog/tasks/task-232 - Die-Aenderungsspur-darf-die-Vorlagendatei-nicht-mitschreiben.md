---
id: TASK-232
title: Die Aenderungsspur darf die Vorlagendatei nicht mitschreiben
status: To Do
assignee: []
created_date: '2026-09-04 00:20'
labels:
  - schema
  - wb-backend
  - dsgvo
milestone: m-5
dependencies: []
ordinal: 244000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
`change_log` trägt `old_value` und `new_value` als **Text**, eine Zeile je geänderter Spalte. Eine Vorlagendatei von 400 KB als `bytea` würde damit bei jedem `PATCH` **zweimal** in die Spur kopiert — rund ein Megabyte je Änderung, für einen Wert, den niemand aus der Spur je lesen will.

**Die Regel:** Für `contract_texts.template_docx` schreibt die Spur die **Prüfsumme** statt des Werts. Dass sich die Datei geändert hat und auf welche Prüfsumme, ist die ganze Aussage, die gebraucht wird.

**Der Mengeneffekt ist dabei klein, und zwar durch die Bauform**: Die Geschäftsführung bearbeitet die **Arbeitsfassung in SharePoint** — das erzeugt keine einzige Datenbankänderung. Ein `PATCH` auf eine angekündigte Fassung entsteht nur beim erneuten Einfrieren, also durch eine bewusste Handlung. Die Zahl der Spurzeilen folgt damit der Zahl der Freigaben, nicht der Zahl der Tastendrücke.

Was dabei verloren geht, ist der vorherige Dateiinhalt einer **angekündigten** Fassung. Das ist hinnehmbar: Eine Fassung, deren Tag nie erreicht wurde, hat nichts belegt. Eine erreichte wird nie geändert (TASK-222).
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Fuer template_docx traegt change_log die Pruefsumme, nicht den Wert
- [ ] #2 Der Kommentar an der Spalte sagt, warum — und dass es die einzige solche Ausnahme ist
- [ ] #3 Gegenprobe: eine geaenderte Vorlagenfassung hinterlaesst eine Spurzeile ohne Dateiinhalt
<!-- AC:END -->
