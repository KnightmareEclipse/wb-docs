# TODO — vor dem VPS-Setup

Organisatorische Vorbereitungen, die vor Phase 1 ([`pipeline/vps-repo/01-provisioning.md`](pipeline/vps-repo/01-provisioning.md)) stehen müssen. Reine Konzept-Doku deckt das nicht ab — das hier sind reale Konten/Entscheidungen.

## Accounts & Zugänge

- [x] Hetzner-Cloud-Konto anlegen — organisationseigen, nicht privat (`rules.md` Abschnitt 6)
- [x] Zweiten Admin bestimmen — Bus-Faktor verlangt mindestens zwei Personen mit vollem Zugriff (`rules.md` Abschnitt 6)
- [x] Gemeinsame KeePass-Datenbank anlegen, Ablageort für alle Admins klären (z. B. bestehender M365-Tenant der Schule)
- [x] KeePass-Datenbank mit starkem, einzigartigem Master-Passwort schützen — kein Keyfile/YubiKey, siehe Begründung in `rules.md` Abschnitt 2
- [x] MFA aktivieren: Hetzner-Cloud-Konto, DNS-Provider-Konto der Schule (`rules.md` Abschnitt 2)
- [x] healthchecks.io-Hobbyist-Account anlegen + Check einrichten, Zugangsdaten in KeePass ablegen
- [x] `secrets.env` in KeePass anlegen (erster Eintrag: healthchecks-Ping-URL) — Format/Schema siehe `pipeline/vps-repo/02-hardening.md`
- [x] Pro Admin: eigenen Hetzner-API-Token erzeugen, eigenen SSH-Key erzeugen (Grundlage für spätere `admins.yml`)

## Konkrete Werte festlegen

- [x] Servername + Hetzner-Label wählen (Konstante für `wb-vps/infra/`)
    Projektname: Weltenbaum
    Servername: db-prod-fsn-01
    IPv4: 167.233.211.96
    IPv6: 2a01:4f8:c012:90d0::/64

- [x] Region festgelegt: `fsn1` (Falkenstein), siehe `pipeline/vps-repo/01-provisioning.md`
- [x] Wöchentliches Wartungsfenster (automatischer Reboot nach Kernel-Patches) festgelegt: Samstag, 03:00 Uhr, siehe `idea/01-boot-verschluesselung.md`/`pipeline/vps-repo/02-hardening.md`

## VPS-Repo

- [x] Repo anlegen (Name, privat, Zugriff für weitere Admins) — siehe „Repo-Struktur" in `project-parts.md`
    Github wird genutzt als Hosting Plattform, da Gitlab Kreditkartendaten will für jeden User der sich anmeldet bei Gitlab.
    Github Organisation erstellt, warüber alle Repos laufen. wb-vps ist erstes Repo!
- [x] `wb-vps/CLAUDE.md` (Coding-Style-Regeln) neu schreiben + reviewen — jetzt eigenständig (kein Bezug auf dieses Repo), stale LUKS-/Break-Glass-Referenzen entfernt (Festplattenverschlüsselung ist raus, nur noch verschlüsseltes Swap mit Random-Key)

## Optional, nicht blockierend

- [x] Subdomain wählen — `api.clemens.schule`, siehe `idea/02-netzwerk-firewall.md`
- [ ] DNS A/AAAA-Record für `api.clemens.schule` setzen — bewusst zurückgestellt, bis der Server läuft (manuell im All-Inkl-KAS unter Tools → DNS-Verwaltung, nicht über die einfache Subdomain-Verwaltung), kein Muss für Phase 1–3

## Später relevant, jetzt nicht klären

- Cyber-Versicherung: ob Verschlüsselung at rest unabhängig von der technischen Notwendigkeit gefordert wird — erst vor Vertragsabschluss prüfen (`idea/01-boot-verschluesselung.md`)
