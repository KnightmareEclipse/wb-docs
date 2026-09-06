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

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
**Abbildung der Stammdaten-Domaene, gelesen am 06.09.2026** gegen
`~/Documents/projectNightmare/ASV-BW/asv_struktur.sql` (reines DDL). Der Kompakt-Index war
dafuer nicht noetig: `ASV_TO_HUB_MAPPING.md` nennt die Tabellen, und gebraucht werden neun.

| Weltenbaum | ASV-BW |
|---|---|
| `persons` (Kind) | `svp_schueler_stamm`: familienname, vornamen, rufname, wl_geschlecht_id, wl_anrede_id |
| `children` | dieselbe Zeile: geburtsdatum, geburtsort, wl_geburtsland_id, wl_verkehrssprache_id, wl_staatsangehoerigkeit_id, wl_weitere_staatsangeh_id, wl_religionszugehoerigkeit_id |
| `children` (Einschreibung) | `svp_schueler_schuljahr`: schuljahr, klassenstufe, klassenbezeichnung, eintrittsdatum, austrittsdatum |
| `persons` (Erwachsene) | `svp_person` bzw. `svp_kontakt` ueber `svp_schueler_schuljahr_kontakt` |
| `family_guardians.guardian_relation_id` | `svp_schueler_schuljahr_kontakt.verknuepfungsart` |
| `addresses` | `svp_anschrift`: strasse, nummer, postleitzahl, ortsbezeichnung, ortsteil, wl_staat_id |
| `persons.email`, `phone_numbers` | `svp_kommunikation`: kommunikationsadresse, wl_kommunikationstyp_id, bemerkung |
| Wertelisten | `svp_wl_geschlecht`, `_staatsangehoerigkeit`, `_verkehrssprache`, `_religionszugehoerigkeit` |

**Sieben Befunde, die vor dem ersten Lauf entschieden sein muessen:**

1. **ASV kennt keine Familie.** Weltenbaum haengt Putzdienst und Elternbonus an `families`, ASV
   kennt nur Kind zu Kontakten je Schuljahr. Die Familie muss abgeleitet werden — Kandidat ist
   `svp_schueler_stamm_geschwister`, hilfsweise die Deckungsgleichheit der Kontaktmenge. Das ist
   die Kernentscheidung des Imports und gehoert zu TASK-017.
2. **Kontakte haengen am Schuljahr, nicht am Kind.** Welches Schuljahr die Familie bildet, ist zu
   setzen — Vorschlag: das juengste, in dem das Kind eingeschrieben war.
3. **`svp_kontakt` trennt Vor- und Nachname nicht** (name1/name2/name3). `persons.last_name` ist
   NOT NULL und getrennt gefuehrt. Ermessen, kein mechanischer Bug.
4. **`rufname` ist in ASV NOT NULL**, in Weltenbaum nullable mit der Bedeutung "leer heisst, der
   Vorname gilt". Beim Import wird `rufname = vornamen` zu NULL, sonst traegt jede Zeile einen
   Rufnamen, der keiner ist.
5. **`geburtsname` hat in Weltenbaum kein Ziel** — bewusst, oder eine fehlende Spalte?
6. **`children.congregation` hat in ASV keine Quelle.** Die Kirchengemeinde kommt nicht aus dem
   Import und bleibt beim Bestandskind leer (05).
7. **Der Dump traegt mehrere Schemata** mit identischen Tabellen (`asv.`, `asvstat_<id>.`).
   Welches der echte Export mitbringt, entscheidet sich am Export selbst.
<!-- SECTION:NOTES:END -->
