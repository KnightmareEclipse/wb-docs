# TODO — vor dem VPS-Setup

Organisatorische Vorbereitungen, die vor Phase 1 ([`pipeline/vps-repo/01-provisioning.md`](pipeline/vps-repo/01-provisioning.md)) stehen müssen. Reine Konzept-Doku deckt das nicht ab — das hier sind reale Konten/Entscheidungen.

## Accounts & Zugänge

- [ ] Hetzner-Cloud-Konto anlegen — organisationseigen, nicht privat (`rules.md` Abschnitt 6)
- [ ] Zweiten Admin bestimmen — Bus-Faktor verlangt mindestens zwei Personen mit vollem Zugriff (`rules.md` Abschnitt 6)
- [ ] Gemeinsame KeePass-Datenbank anlegen, Ablageort für alle Admins klären (z. B. bestehender M365-Tenant der Schule)
- [ ] KeePass-Datenbank mit Master-Passwort **+** Schlüsseldatei oder YubiKey schützen — KeePass kennt offline kein klassisches MFA, das ist das Äquivalent zur MFA-Pflicht aus `rules.md` Abschnitt 2
- [ ] MFA aktivieren: Hetzner-Cloud-Konto, DNS-Provider-Konto der Schule (`rules.md` Abschnitt 2)
- [ ] healthchecks.io-Hobbyist-Account anlegen + Check einrichten, Zugangsdaten in KeePass ablegen
- [ ] `secrets.env` in KeePass anlegen (erster Eintrag: healthchecks-Ping-URL) — Format/Schema siehe `pipeline/vps-repo/02-hardening.md`
- [ ] Pro Admin: eigenen Hetzner-API-Token erzeugen, eigenen SSH-Key erzeugen (Grundlage für spätere `admins.yml`)

## Konkrete Werte festlegen

- [ ] Servername + Hetzner-Label wählen (Konstante für `vps/infra/`)
- [ ] Region festlegen: `fsn1` oder `nbg1` (bisher beide genannt, siehe `pipeline/vps-repo/01-provisioning.md`)

## VPS-Repo

- [ ] Repo anlegen (Name, privat, Zugriff für weitere Admins) — siehe „Repo-Struktur" in `project-parts.md`
- [ ] `vps/CLAUDE.md` (Coding-Style-Regeln) neu schreiben + reviewen — vorheriger Entwurf wurde mit `vps/` gelöscht (Commit 798d19a), Review stand davor schon aus

## Optional, nicht blockierend

- [ ] Subdomain wählen + DNS A/AAAA-Record setzen — DNS-Zugang ist vorhanden, kann jederzeit vor dem App-Stack passieren, kein Muss für Phase 1–3

## Später relevant, jetzt nicht klären

- Cyber-Versicherung: ob Verschlüsselung at rest unabhängig von der technischen Notwendigkeit gefordert wird — erst vor Vertragsabschluss prüfen (`idea/01-boot-verschluesselung.md`)
