---
id: TASK-210
title: >-
  Der Werbebeitrag im öffentlichen Portal — Text, Canva-Bild und Preis sauber
  trennen
status: To Do
assignee: []
created_date: '2026-09-03 14:38'
labels:
  - portal
  - oberflaeche
  - dsgvo
dependencies:
  - TASK-175
references:
  - oberflaechen.md
  - soll-prozesse/21-akademie.md
  - soll-prozesse/10-ferienprogramm.md
ordinal: 223000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Der öffentliche Teil des Portals soll Angebote bewerben — ein neues Akademie-Angebot, neue Ferientermine, allgemeine News (TASK-175). Gestaltet wird in **Canva**: Es gibt eine Vorlage je Art, jemand füllt sie und lädt das Ergebnis hoch (03.09.2026, mit Corrado). Weltenbaum baut **kein Layout-System** — Schriften, Farben und Positionen bleiben in Canva.

Zu entscheiden ist die eine Frage, an der alles Weitere hängt: **Wie viel steht im Bild und wie viel daneben?**

- **A — Das Bild trägt alles.** Titel, Text und Grafik sind eine Datei; das System speichert Bild plus Alternativtext. Schönster Eindruck, höchster Preis: nicht durchsuchbar, auf dem Telefon unlesbar klein, jede Tippfehlerkorrektur bedeutet einen neuen Canva-Lauf, und ein Preis kann darin nie aktuell sein.
- **B — Das Bild ist nur Grafik.** Titel, Text und Kosten stehen als Felder im System, das Layout macht die Seite. Aktuell, lesbar, durchsuchbar — aber die Gestaltung ist unsere und nicht Corrados.
- **C — Kopfbild plus Felder.** Das Canva-Bild ist der Blickfang, Titel, Kurztext und das Kostenelement stehen daneben als Felder. Die Vorlage in Canva legt Format und Stil fest, nicht den Inhalt.

**Empfehlung: C, und zwar nicht aus Geschmack.** Das BFSG gilt für dieses Portal (TASK-118, bestätigt am 01.09.2026), Maßstab ist WCAG 2.1 AA — und Text als Bild ist dort nur zulässig, wo er wesentlich ist (Logos). Ein Werbebeitrag, dessen Aussage allein im Bild steht, fällt durch; ein Kopfbild mit Text daneben nicht. A scheidet damit praktisch aus, und C holt trotzdem den gestalterischen Gewinn.

**Was ein Beitrag dann trägt:** Variante (Werteliste, eine je Canva-Vorlage, mit festem Seitenverhältnis), Titel, Kurztext, das Bild samt Alternativtext, Sichtbarkeitszeitraum, wer ihn eingestellt hat, und optional den Verweis auf das beworbene Angebot.

**Preise, drei Regeln:**

- Der Beitrag trägt **keine Zahl**. Kosten erscheinen nur als Element, das beim Aufruf aus der Datenbank liest — der Verweis auf das Angebot ist der Schalter dafür.
- Ein Preis kann bei uns gar nicht veralten: Jeder Betrag trägt seinen Gültigkeitstag, und gelesen wird der, dessen Tag zuletzt erreicht wurde (hebel.md). Veralten kann nur ein Beitrag, der ein Angebot bewirbt, das es nicht mehr gibt — **deshalb endet seine Sichtbarkeit mit dem Angebot**, und ein eigenes Enddatum kann sie nur verkürzen.
- Die eine Stelle, an der ein alter Preis doch sichtbar würde, ist **das Bild selbst**: Eine in Canva eingebaute Zahl sieht keine Datenbank und kein Prüfskript. Also keine Beträge ins Bild, bestätigt beim Hochladen.

**Bilder mit Kindern brauchen das Fotoeinverständnis aller Abgebildeten.** Das kann kein System aus einer Datei ablesen; wer hochlädt, bestätigt es. Der Anker am Kind steht bereits.

**Die Bilder liegen außerhalb der Schülerakte** und werden ohne Anmeldung ausgeliefert — sie sind nach der Akademie-Ausschreibung der zweite Teil des Systems ohne Login. Dasselbe Bild trägt später die Sammelmail (TASK-208): einmal abgelegt, zweimal gezeigt.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Entschieden zwischen A, B und C — mit dem BFSG-Maßstab als Begründung, nicht mit Geschmack
- [ ] #2 Die Varianten stehen als Werteliste; eine neue Canva-Vorlage ist eine Zeile plus ein Seitenverhältnis
- [ ] #3 Der Beitrag trägt keine Zahl: Kosten kommen als Element aus der Datenbank
- [ ] #4 Die Sichtbarkeit endet mit dem beworbenen Angebot; ein eigenes Enddatum verkürzt sie nur
- [ ] #5 Beim Hochladen wird bestätigt, dass im Bild kein Betrag steht und die Abgebildeten einverstanden sind
- [ ] #6 Jedes Bild trägt einen Alternativtext — ohne ihn kein Beitrag
- [ ] #7 Die Bilder liegen außerhalb der Schülerakte und werden ohne Anmeldung ausgeliefert
<!-- AC:END -->
