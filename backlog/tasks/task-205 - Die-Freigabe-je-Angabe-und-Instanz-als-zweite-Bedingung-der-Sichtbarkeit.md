---
id: TASK-205
title: Die Freigabe je Angabe und Instanz als zweite Bedingung der Sichtbarkeit
status: To Do
assignee: []
created_date: '2026-09-03 11:33'
updated_date: '2026-09-03 14:51'
labels:
  - schema
  - gesundheit
  - dsgvo
  - wb-docs
dependencies: []
references:
  - schema/gesundheit-schema.sql
  - schema/gesundheit-schema-check.sql
  - api/gesundheit-api.md
  - soll-prozesse/08-schulvertrag.md
  - soll-prozesse/09-hortvertrag.md
  - grenzkarte.md
ordinal: 218000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Der Datenschutzbeauftragte hat am 02.09.2026 den feingranularen Sichtschnitt abgelehnt ("wer definiert das! Wird so auch nicht abgefragt") und einen groben gesetzt: Lehrkräfte und Hortmitarbeitende sehen alles — für ihre Kinder —, allein die Küche wird auf Allergie und Lebensmittelunverträglichkeit reduziert. Unbeantwortet blieb die zweite Hälfte derselben Frage: ob der Hort eine eigene Einwilligung braucht oder die Bestätigung der Eltern beim Hortvertrag reicht.

Dieses Ticket beantwortet sie strenger, als er verlangt hat, und behält dabei den einen Bestand je Kind: Schule und Hort sind zwei Instanzen derselben Angabe, nicht zwei Bestände. Die Eltern geben je Instanz erst überhaupt frei oder lehnen ab, und geben danach jede einzelne Angabe einzeln frei; eine Angabe kann auch nur für eine Instanz entstehen. Sichtbarkeit ist damit ein Schnitt aus zwei Mengen — die Konfiguration sagt, welche Felder ein Sichtkreis sehen kann (`health_field_visibility`), die Daten sagen, welche Angabe ihm überhaupt vorliegt. Beides bleibt eine Zeile, kein Schema-Eingriff je neuer Frage.

Zwei Tabellen, additiv, keine bestehende Spalte fällt:

- `child_health_releases` — je `child_health_record_id` und `health_visibility_scope_id` die vorgeschaltete Frage, mit `released_at` und `declined_at` als zwei Zeitpunkten statt eines Häkchens: "beim Hort nicht gefragt" darf nicht aussehen wie "beim Hort abgelehnt". Dieselbe Bauform wie `child_health_records` und aus demselben Grund.
- `health_trait_releases` — je `health_trait_id` und `health_visibility_scope_id` die Freigabe der einzelnen Angabe, zusammengesetzter Primärschlüssel wie bei `health_field_visibility`. Sie trägt zugleich die zwei Termine aus TASK-162: Zweckende und Löschtermin gehören hierher und nicht an die Angabe — dieselbe Allergie liegt der Schule dauerhaft und dem Ausflug befristet vor, und erst mit der letzten verfallenen Freigabe geht die Angabe selbst.

An `health_visibility_scopes` kommt ein Häkchen `needs_release`: `full`, `kitchen` und `emergency` sind keine Freigabeziele, `school`, `care` und die Anlass-Instanzen sind es. Eine zweite Werteliste daneben wäre eine zweite Liste derselben Dinge.

Folge für den Zuschnitt: `class_lead` und `sports` fallen zu einem Sichtkreis zusammen, weil beide nach der Antwort des Datenschutzbeauftragten alles sehen. `care` aber ausdrücklich NICHT — sie sieht dieselben Felder und ist trotzdem ein eigenes Freigabeziel. Aus sechs Sichtkreisen werden fünf, nicht vier.

Zwei Regeln, ohne die das Modell kippt:

- Der Notfallausschnitt ignoriert Freigaben. Sonst blendete eine Hort-Ablehnung genau den Zugriff, der im Ernstfall zählt (Auflage vom 02.09.2026: "der Mitarbeitende sieht im Notfall alles").
- Die Küche ist kein Freigabeziel, sie erbt: über die Mensa-Tagesliste gilt die Freigabe an die Schule, über die Hortliste die an den Hort. Ohne diesen Satz ist unbestimmt, was ein Kind isst, dessen Eltern die Schule freigegeben und den Hort abgelehnt haben.

Doppelte Angaben verhindert das Schema bereits: `ix_health_traits_single` lässt je Kind und Kategorie genau eine Angabe zu, außer wo `health_trait_types.allows_multiple` gesetzt ist; die Freigabe hängt an der Angabe und erzeugt keine zweite. Für die Mehrfach-Kategorien (zwei Notfallmedikamente desselben Kindes) bleibt allein das vorbefüllte Bestätigen aus TASK-163 — das ist damit nicht mehr Komfort, sondern trägt.

Offen und Teil dieses Tickets: ob `health_trait_releases` den Bestandsbezug mitführt, um per zusammengesetztem Fremdschlüssel auszuschließen, dass eine Angabe an eine Instanz freigegeben wird, deren vorgeschaltete Frage abgelehnt ist. Preis der strengen Fassung: eine mitgeführte Spalte und je ein zusätzliches UNIQUE an `child_health_answers` und `health_traits` — dieselbe Bauform, mit der `health_traits` schon heute `health_trait_type_id` mitführt. Preis der billigen: die Regel liegt in der Schreibschicht, und das Prüfskript sieht sie nicht.

Preis insgesamt, damit er nicht später als Überraschung auftaucht: jede Leseroute der Domäne bekommt eine zweite Bedingung, und die Policy aus TASK-157 einen Join mehr — eine Policy bleibt es. Der eigentliche Aufwand liegt in der Oberfläche der zweiten Anmeldung (TASK-163), nicht im Schema.

Vor dem Bau dem Datenschutzbeauftragten zur Bestätigung vorlegen: Das Modell ist strenger als seine Vorgabe, ein Nein wäre eine Überraschung.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Ein Bestand je Kind bleibt: keine Tabelle trägt Gesundheitswerte je Instanz
- [ ] #2 child_health_releases unterscheidet 'nicht gefragt' von 'abgelehnt' — mit Gegenprobe
- [ ] #3 Eine Angabe ohne Freigabe ist für den Sichtkreis unsichtbar; das Prüfskript weist den Lesefall ab
- [ ] #4 Der Notfallausschnitt liefert auch die Angaben, die dieser Instanz nie freigegeben wurden — als Gegenprobe
- [ ] #5 Eine Freigabe an einen Sichtkreis mit needs_release = false wird abgewiesen
- [ ] #6 Zweckende und Löschtermin stehen an der Freigabe, nicht an der Angabe; die Angabe geht mit der letzten verfallenen Freigabe
- [ ] #7 care ist ein eigener Sichtkreis geblieben, und der Grund steht als Kommentar an der Werteliste
- [ ] #8 Entschieden, ob die Freigabe den Bestandsbezug mitführt (zusammengesetzter Fremdschlüssel) oder ob die Schreibschicht sie hält
- [ ] #9 Die Küchenregel steht in genau einer Datei und wird anderswo nur genannt
- [ ] #10 Der Kopfkommentar von schema/gesundheit-schema.sql begründet 'eine Zeile je Feld' nicht mehr mit dem abgelehnten Sportbeispiel, sondern mit Küche und Attest
- [ ] #11 Eine Handlung gibt alles frei: die Eltern müssen nicht jede Angabe einzeln anklicken, das Einzelne bleibt möglich (03.09.2026)
- [ ] #12 Das Modell ist von der Geschäftsführung bestätigt (03.09.2026); der Datenschutzbeauftragte wird unterrichtet, nicht gefragt — es ist strenger als seine Vorgabe
<!-- AC:END -->
