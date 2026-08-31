---
id: TASK-150
title: >-
  Importskript für den Vollimport KI-gestützt lokal gegen die echten ASV-Daten
  entwickeln
status: To Do
assignee: []
created_date: '2026-08-31 18:04'
updated_date: '2026-08-31 19:57'
labels:
  - import
  - stammdaten
  - ki
milestone: m-1
dependencies:
  - TASK-036
references:
  - schema/stammdaten-schema.sql
  - dsgvo.md
  - verarbeitungsverzeichnis.md
ordinal: 162000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Das Importskript entsteht KI-gestützt, aber zweigeteilt entlang der Frage, wo Klardaten anfallen. Die ASV-Struktur trägt keine: Der Referenzdump unter `~/Documents/projectNightmare/ASV-BW/` enthält 717 Tabellen reines DDL und keine einzige Datenzeile. Struktur durchsteigen, Quelle-zu-Ziel zuordnen, die Matching-Regeln ausformulieren, das ETL-Skript schreiben und die synthetischen Fixtures bauen ist deshalb **Arbeit am Cloud-Modell** — dort liegt das Urteilsvermögen, und personenbezogen wird dabei nichts. Erst der Lauf gegen den **echten Export** berührt Klardaten, und nur dieser Teil gehört dem **lokalen Modell**: Skript starten, Fehlerausgabe lesen, mechanische Abweichungen (Encoding, Format, fehlende Werte) im Skript nachziehen. Ergebnis der Iteration ist immer das Skript selbst (reproduzierbar, diffbar), nie ein direkter Schreibzugriff auf die Datenbank. So verarbeitet kein Auftragsverarbeiter personenbezogene Daten und `verarbeitungsverzeichnis.md` braucht keinen neuen Eintrag — das war der ursprüngliche Grund für „lokal" und er bleibt erfüllt, mit weniger Last auf der schwächeren Seite.

Zwei Aufgaben sind dem lokalen Modell ausdrücklich entzogen, weil eine Testreihe an der echten Aufgabe gezeigt hat, dass es sie nicht trägt. **Ermessen:** Die Matching-Regeln aus TASK-016 (Adress-Lookup), TASK-017 (Kind/Erziehungsberechtigte, Zwillingsfalle im Schlüssel) und TASK-018 (Kohorten-Rückrechnung) sind Entscheidungen, keine mechanischen Bugs. Vorgelegt bekamen zwei Modelle die Kollision aus TASK-017 — beide änderten den Schlüssel eigenmächtig, ohne die Zwillinge auch nur zu erwägen, und eines tat es sogar mit der ausdrücklichen Regel im Systemprompt, indem es Regeltreue behauptete und die Semantik trotzdem umbaute. **Anonymisierung:** Beide Modelle gaben Klardaten wörtlich zurück und nannten das Ergebnis anonymisiert. Das lokale Modell meldet deshalb nur die *Gestalt* eines Sonderfalls — welche Spalte, welche Regel bricht —, und die synthetische Fixture entsteht daraus, ohne dass die Zeile das Verzeichnis des Exports je verlässt.

Gewählt ist **gpt-oss-20b in nativem MXFP4** (`ggml-org/gpt-oss-20b-GGUF`, 12,11 GB, MoE mit 20,9 B gesamt und 3,6 B aktiv), betrieben über **llama.cpp mit Vulkan-Backend**. Arbeitspunkt sind **64k Kontext mit fp16-KV-Cache**: 12,11 GB Gewichte plus 1,6 GB Cache plus Compute-Buffer ergeben rund 15,0 der 16 GB, das Modell bleibt also vollständig auf der Karte. Reserve bis zu den nativen 131k besteht über `-ctk q8_0 -ctv q8_0`, wird aber nicht gebraucht. Eine 5-Bit-Stufe gibt es hier nicht und ist auch keine Lücke: MXFP4 mit 4,25 bpw ist die Auslieferungspräzision des Modells, ein Requantisieren nach oben holt nichts zurück.

Entschieden hat eine Testreihe an der echten Aufgabe, nicht ein Benchmark-Score: Veröffentlichte Zahlen sagen für diesen Zuschnitt nichts — Qwen3-Coder-30B-A3B hat die besseren und verliert. Zehn maschinell geprüfte Aufgaben gegen den echten ASV-Dump und `schema/stammdaten-schema.sql`, gpt-oss-20b **5/10** bei 131–151 tok/s, Qwen3-Coder-30B-A3B **4/10** bei 28–35 tok/s. Beide lesen Struktur fehlerfrei: aus 21k Token Heuhaufen fanden beide alle 28 Tabellen mit Fremdschlüssel auf `svp_schueler_stamm`, ohne eine zu erfinden. Beide scheitern an Ermessen und Anonymisierung — daher der Zuschnitt oben. Den Ausschlag gab, dass gpt-oss-20b mit 14,4 GB **vollständig auf der Karte bleibt**, während Qwen 21 seiner 48 Expert-Lagen ins RAM legen muss und dabei viermal langsamer wird; und dass es bei kaputten Werten meldet, statt wie Qwen ein Geburtsdatum zu erfinden.

Zwei Rahmenbedingungen gelten unabhängig vom Modell. **Vulkan statt ROCm**, weil der Rechner auch zum Spielen dient: llama.cpp fährt über denselben RADV-Treiber wie die Spiele, es kommt kein Treiber und kein Compute-Stack hinzu. Auf RDNA4 ist Vulkan beim Decode ohnehin schneller als ROCm; bezahlt wird das mit rund 40 % langsamerem Prefill. Das Fedora-Paket `llama-cpp` scheidet deshalb aus — es hängt an `hipblas` und `libamdhip64`. **Kein Konto**, weder zum Laden des Modells noch im Betrieb; der Harness (Codex CLI `--oss` oder OpenCode gegen `llama-server`) braucht ebenfalls keines.

Die vollständige ASV-Struktur passt in kein Kontextfenster, auch in keins der großen: 108 Views, 2.131 Fremdschlüssel und 13.452 Spalten über die 717 Tabellen ergeben in 5,23 MB rund 1,58 Mio. Token, allein `svp_schueler_stamm` trägt 176 Spalten. Sie wird deshalb durchsucht statt geladen, gegen einen einmal abgeleiteten Kompakt-Index aus Tabellenname und Spaltenzahl (rund 7k Token für alle 717). Je Durchgang liegen damit etwa 40–70k Token im Fenster: Index, der Fremdschlüssel-Teilgraph der Domäne, die Volldefinitionen von zehn bis zwanzig Tabellen, das Ziel-Schema und das entstehende Skript. Portioniert wird entlang der zwölf Domänen, die in `schema/` bereits stehen — gegen echte Daten iteriert wird erst, wenn der Export vorliegt.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Das lokale Modell hat nur Lesezugriff auf den Export, kein Schreibzugriff auf die Datenbank — Ergebnis der Iteration ist ausschließlich das Skript
- [ ] #2 Änderung eines Matching-Schlüssels (016/017/018) ist vom Betreiber bestätigt, von keinem Modell allein entschieden
- [ ] #3 Am echten Export gefundene Sonderfälle liegen als synthetische Testfixtures vor, gebaut aus der gemeldeten Gestalt des Falls statt aus anonymisierten Klardaten — Probelauf aus 036 bleibt ohne erneuten Klardatenzugriff wiederholbar
- [x] #4 Modellwahl fällt bei Umsetzungsbeginn, nicht in diesem Ticket
- [ ] #5 Der echte Export liegt außerhalb jedes Verzeichnisses, in dem das Cloud-Modell arbeitet, und keine Zeile daraus gelangt über eine Fixture ins Repo
<!-- AC:END -->
