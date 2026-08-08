# Fachdomänen — Scope

Vor der ersten Fachdomäne (`CLAUDE.md`, „Nächster Schritt") klären, was Weltenbaum fachlich überhaupt abbilden soll — sonst trifft die erste Domäne Annahmen, die eine spätere wieder umwirft. Grundlage für die Domänen-Liste (jetzt + absehbar später) und die Auswahl der ersten Domäne. Arbeitsdokument — Abschnitte 1–5 ausgefüllt, 6–7 offen.

## 1. Aktuelles Angebot der Schule

Christliche private Grund- und Realschule in Baden-Württemberg, Klasse 1–10, ca. 500 Schüler. Unterliegt den allgemeinen staatlichen Vorgaben, hat darüber hinaus eigene Besonderheiten. Aufnahme selektiv: Voranmeldung (bereits gebührenpflichtig) → Anmeldegespräch → Anmeldeprozess.

Angebote für Schüler/Eltern im laufenden Schulbetrieb:
- **Putzdienst:** Pflicht-Putztermine je Familie (regulär + Großputz), gegen Gebühr freikaufbar
- **Hort:** Ganztagesbetreuung Klasse 1–4, optional gegen Aufpreis, Ausweitung angedacht
- **Hausaufgabenbetreuung:** eigenständig in der Realschule, im Hort inklusive
- **AGs:** einzelne Arbeitsgemeinschaften
- **Mensa:** tageweise Anmeldung, gebührenpflichtig, berechtigt zum Essen an den angemeldeten Tagen

Weitere Einrichtungen/Angebote:
- **KITA:** eigener Alltag nicht Teil des Scopes, aber KITA-Mitarbeiter brauchen bereichsübergreifend Zugriff auf mindestens einen Prozess (Buchungsbeleg-/Rechnungsfreigabeprozess)
- **Ferienprogramm** (über den Hort): in allen Ferien außer den Weihnachtsferien, wochenweise mit wechselndem Thema, offen für alle Kinder bis zu einem bestimmten Alter — **auch für schulfremde Personen offen**, nicht nur für die Kochwerkstatt. Es gibt bereits jetzt Kinder/Eltern, die das nutzen, ohne offiziell an der Grund- oder Realschule angemeldet zu sein.
- **Kochwerkstatt:** für Kinder und Erwachsene, auch für schulfremde Personen offen
- Geplant: Ausweitung des außerschulischen Angebots allgemein

### Zeitliche Dringlichkeit (nächste 12 Monate)

Reihenfolge, in der die Prozesse im Jahresverlauf wieder akut werden:
1. **September — Elternputzdienst:** Buchungsfenster öffnet, gebucht wird für den Zeitraum Oktober–September des Folgejahres. Auswahl unter verfügbaren Terminen oder Freikauf gegen Gebühr; Personen ohne gebuchte Termine werden am Ende automatisch auf die restlichen freien Termine verteilt. Hat noch weitere Detailregeln, die später folgen. **Nächster fälliger Prozess.**
2. **bis Ende Oktober — Voranmeldung**
3. **ab spätestens Weihnachten — Ferienanmeldung**
4. **ab Februar — Anmeldeprozess + Anmeldegespräche** müssen stehen

## 2. Bestehende Software

- **ASV-BW:** amtliche Schulverwaltungssoftware, Pflicht für die jährliche Schulstatistik; für staatliche Schulen konzipiert, deckt daher nicht alle eigenen Besonderheiten ab
- **Optigem:** Buchhaltung
- **Untis** (Desktop, nicht WebUntis): Noten, Stundenpläne etc. in der Realschule — liegt außerhalb des eigenen Verwaltungsalltags, hier nicht im Detail betrachtet
- **Office 365:** zentrale Ablage für alles, was in keinem der drei genannten Tools abgebildet ist (Mail, Dateien, …)
- **Jotform:** Formulare

## 3. Aktuelle Probleme

### Historie

Früher liefen alle Prozesse (inkl. vermutlich einiger inzwischen vergessener) auf Papier bzw. handgepflegten Excel-Listen.

### Bisherige Digitalisierung

1. Jotform-Formulare für Voranmeldung, Anmeldeprozess, Ferienprogrammanmeldung
2. Power Automate: schreibt Formulardaten automatisch in Excel-Listen, übernimmt Mailversand
3. Versuch, SharePoint-Listen als feste Struktur einzuführen und per Power Query nach Excel zu synchronisieren — gescheitert: die Verwaltung bearbeitete Daten direkt in der Power-Query-Tabelle, ein Refresh überschrieb diese Änderungen wieder

Ergebnis: viele parallele Excel-Dateien pro Prozess, hoher Wartungsaufwand (z. B. bricht ein in Teams verschobener Datei-Link den Prozess, ohne dass die verschiebende Person das merkt), unsauberer/inkonsistenter Datenstand — unabhängig von ASV-BW, Optigem und Office 365.

Bisher automatisiert (alle über Excel als Datenbank): Voranmeldung, Anmeldeprozess, Putzdienst, Ferienprogrammanmeldung.
- **Anmeldeprozess:** der zuletzt gebaute und am weitesten entwickelte — Power-Automate-HTTP-Trigger + Jotform simulieren Frontend und Backend, private (ungeteilte) Excel-Tabellen steuern den Prozess. Funktioniert, ist aber fragil.
- Manuelles Eingreifen ist nicht auf einzelne Prozesse beschränkt: Verwaltung oder Hort verursachen in allen Prozessen laufend Fehler, die manuell korrigiert werden müssen.

### Datenflüsse zu ASV-BW / Optigem / Office 365

- **ASV-BW:** enthält die Stammdaten aller Schüler; neue Schüler werden nach abgeschlossenem Anmeldeprozess dort angelegt, spätere Änderungen laufen ebenfalls dort ein. Ob darüber hinaus weitere Daten dort geführt werden, ist unklar — die Dateneingabe erfolgt nicht selbst, sondern nur die Prozessautomatisierung drumherum.
- Daten, die ASV-BW nicht abbilden kann (z. B. Schulvertrag, Gesundheitsinformationen), liegen in Excel/SharePoint Teams.
- **Optigem:** Abrechnung aller Gebühren (Schulkosten, Mensa, Putzdienst-Freikauf, Ferienprogramm) sowie laufender Rechnungen/Ausgaben.
- **Rechnungsfreigabe:** eigener, stabil laufender Prozess über eine Teams-App (SPFx) + SharePoint-Listen, PDFs in SharePoint, mit rudimentärer Rechteverwaltung.

## 4. Zielbild

- **Kurzfristig:** alle Prozesse, die aktuell über Excel-Listen laufen, auf eine echte Datenbank mit sauberen Frontends/Backends umziehen — Prozesse einfacher, effizienter, klar definiert; die Verwaltung soll alles Relevante selbst verwalten können, unabhängig von manueller Handarbeit außerhalb der Verwaltung selbst.
- **Mittelfristig:** auch die Microsoft-365-Kontenverwaltung abdecken (aktuell über Vis365, ein Tool des Microsoft-Vermittlers, mit Einschränkungen wie max. 2 Kontaktpersonen pro Kind).
- **Langfristig:** die Weltenbaum-Datenbank als einzige Quelle der Wahrheit für die Verwaltung. Aktueller Zustand: Eltern werden in ASV-BW und Optigem parallel gepflegt, Kinder in ASV-BW und Untis, Lehrer in allen drei Programmen, dazu alle Accounts (Lehrer/Personal/Schüler) separat in Office 365, Elternadressen und Klassen-Verteilerlisten ebenfalls dort (Eltern selbst haben keinen eigenen Account) — hoher doppelter Pflegeaufwand, unklar welcher Datenstand jeweils aktuell/korrekt ist.
- **Explizit nicht im Fokus:** der eigentliche Schulalltag (Noten, Stundenplan) — zu komplex, dafür bestehen mit Untis bereits gute Tools mit einer (kleinen) API.
- **Noch ungeklärt:** wie mit Optigem und ASV-BW umgegangen wird — beide haben aktuell keine nutzbare API. ASV-BW gilt als gesetzt (Pflicht-Schulstatistik, muss flexibel auf kurzfristige gesetzliche Vorgaben reagieren können). Neue Schüler lassen sich nur nach ASV-BW importieren; in Optigem müssen sie per Hand angelegt werden. Änderungen an bestehenden Datensätzen laufen in beiden Systemen ausschließlich manuell — kein Update-Import in keinem der beiden.
- **Vorerst:** Fokus liegt auf den Prozessen selbst — Daten fließen weiterhin manuell (bzw. per Import bei komplett neuen Datensätzen) nach Optigem und ASV-BW zurück, eine Ablösung/Anbindung dieser beiden ist nicht Teil des aktuellen Fokus.

## 5. Nutzergruppen

Träger ist ein gemeinnütziger Verein. Hierarchie:
- **Vorstand:** nicht operativ, aber Entscheidungsmacht über das große Bild
- **Geschäftsführung:** operativer Kopf
- **Schulleitung und Bereichsleitungen** (je eine für Sekretariat, Hort, KITA, Grundschule, Realschule — bei Grundschule/Realschule zugleich der jeweilige Schulleiter): gleiche Ebene, unterhalb der Geschäftsführung
- **Übrige Mitarbeiter und Lehrer:** darunter, operative Nutzung teils bereichsübergreifend (KITA-Mitarbeiter z. B. im Buchungsbeleg-/Rechnungsfreigabeprozess, Abschnitt 1)

Konkrete Berechtigungen (wer darf/kann was) hängen vom jeweiligen Prozess ab und werden pro Fachdomäne separat geklärt.

**Schüler:** kein eigener Systemzugriff vorgesehen — durchgängig nur Datenobjekt, nie Akteur.

**Eltern:** interagieren ausschließlich passiv über Formulare (Ferienprogramm buchen, Voranmeldung, Putzdienst-Terminwahl, …). Kein aktiver Portalzugriff (z. B. Noten einsehen, Chat mit Lehrern) — das ist dauerhaft out of scope, nicht nur vorerst.

## 6. Domänen-Liste (jetzt + später)

Grobe Landkarte, abgeleitet aus Abschnitt 1 (Prozesskalender) und Abschnitt 4 (Zielbild) — erster Entwurf, noch zu prüfen.

Grundlage, parallel zum ersten Punkt bearbeitet:
- **Stammdaten** (Kind, Erziehungsberechtigte, Familie, Kontakte) — eigenständige Fachdomäne, kein bloßes Nebenprodukt: jeder folgende Prozess baut direkt darauf auf. Kein eigenes Kalenderdatum, aber ohne sie kann Putzdienst nicht starten. Datenimport kommt komplett auf einmal (nicht schrittweise je Fachdomäne) — Schema deckt deshalb von Anfang an die vollen ASV-BW-Kernfelder ab, nicht nur Putzdienst-Minimalfelder. Eigene Sekretariats-Oberfläche mit Vollzugriff auf alle Kind-Daten ist hoch priorisiert, aber nachrangig zu den terminlich gebundenen Prozessen unten. Details: `domains/stammdaten.md`.

Zeitkritisch, in Reihenfolge des Schuljahres:
1. **Putzdienst** — Eltern wählen/kaufen sich frei, Verwaltung startet den Prozess und pflegt die Termine, Restzuordnung automatisch. Ziel: Schulanfang September 2026. → erste Fachdomäne (Abschnitt 7).
2. **Voranmeldung** — Erstkontakt/gebührenpflichtige Anmeldung neuer Familien, mündet ins Anmeldegespräch. Fällig bis Ende Oktober 2026.
3. **Ferienanmeldung** (Ferienprogramm) — Buchung durch Eltern, auch schulfremde Personen. Fällig ab spätestens Weihnachten 2026.
4. **Anmeldeprozess + Anmeldegespräch** — vollständiger Aufnahmeprozess, mündet in Neuanlage in ASV-BW. Muss ab Februar 2027 stehen.

Nicht terminlich getrieben, Priorität offen:
5. **Rechnungsfreigabe** — läuft bereits stabil über Teams-App/SharePoint (Abschnitt 3), daher niedrige Migrationspriorität.
6. **Mensa-, Hort-, AG-Anmeldung** — bisher nicht als akut/digitalisiert benannt.
7. **M365-Kontenverwaltung** (Ablösung/Ergänzung von Vis365) — mittelfristiges Ziel (Abschnitt 4), IT-Administration statt klassischer Schulprozess.

Explizit nicht in dieser Liste: KITA-Alltag, Schulalltag (Noten/Stundenplan) — beide dauerhaft out of scope (Abschnitt 1/4).

## 7. Erste Fachdomäne

**Putzdienst** — zeitlich dringendster Prozess (Abschnitt 1), Ziel: produktiv nutzbar bis Schulanfang September 2026, kleiner Spielraum vorhanden, aber ausdrücklich ohne Abstriche bei Sicherheit/Automatisierung (`rules.md` §1–3). Prozessbeschreibung, Familie-Modell, Zyklus-Konfiguration und offene Punkte: `domains/putzdienst.md`.

Kritischer Pfad bis dahin:

*Infrastruktur:*
- Phase-4-Deploy-Auslöser auf der VPS bootstrappen (`pipeline/runbook.md` Schritt 5)
- NAS-Backup-Bootstrap (`TODO.md`) — muss vor echten Elterndaten laufen, nicht nachträglich
- Entra-ID-App-Registrierung (`pipeline/runbook.md` Schritt 7) — bestätigt zwingend: die Verwaltung startet den Prozess und pflegt die Putztermine intern, kein reiner Eltern-Self-Service

*Auth/Zugriff für Eltern:*
- OTP-Fallback tatsächlich implementieren (E-Mail-Check mit Enumeration-Schutz, Code-Speicherung/Ablauf/Rate-Limiting, Graph-API-Mail.Send mit eingeschränkter Application Access Policy — bisher nirgends entschieden, welches Postfach senden darf)
- Externes Frontend (Azure Static Web App + Function, `project-parts.md` Abschnitt 9) erstmals aufsetzen — CORS-Policy wird dadurch jetzt konkret

*Fachlich:*
- Stammdaten-Fachdomäne (Familie, Erziehungsberechtigte, Kind, Kontakte) als Grundlage — Details `domains/stammdaten.md`, Tabellenschema `domains/stammdaten-schema.sql`
- Putzdienst-eigenes Datenmodell darauf aufbauend: Putztermine, Zyklus-Konfiguration — Details `domains/putzdienst.md`
- Restplatz-Zuordnung über Google-OR-Tools-Constraint-Solver statt Eigenbau (`domains/putzdienst.md`)
- Putzdienst-Tabellenschema selbst noch zu entwerfen

*Organisatorisch:*
- Zweiter Admin muss vor Produktivbetrieb aktiv sein, nicht vor Entwicklungsstart (`TODO.md`)
