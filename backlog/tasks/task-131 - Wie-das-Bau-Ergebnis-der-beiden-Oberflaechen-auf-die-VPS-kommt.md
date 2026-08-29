---
id: TASK-131
title: Wie das Bau-Ergebnis der beiden Oberflaechen auf die VPS kommt
status: Done
assignee: []
created_date: '2026-08-28 22:47'
updated_date: '2026-08-29 00:23'
labels:
  - deploy
  - frontend
milestone: m-0
dependencies: []
references:
  - deploy.md
  - oberflaechen.md
  - repos.md
priority: high
ordinal: 143000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Der Reverse-Proxy liefert Elternportal und interne Oberflaeche aus und haengt sich dafuer je ein dist/-Verzeichnis ein (WB_PORTAL_ROOT/WB_INTERN_ROOT in wb-backend/docker-compose.yml); lokal zeigen die Vorgaben auf die Nachbar-Repos. Offen ist allein, wie diese Verzeichnisse auf der VPS entstehen - deploy.md sagt bisher nur 'ueber denselben Push-Ausloeser wie der App-Stack', ohne den Weg zu nennen. Drei Wege mit Preis: (a) je Oberflaeche ein eigenes Bare-Repo unter dem deploy-User mit eigenem post-receive-Hook, der im Container baut und nach /srv/wb-frontends/<name> legt - eine Kette je Repo, dafuer laesst sich eine Oberflaeche allein ausrollen; Preis: drei Hooks und drei Units statt einer. (b) Die beiden Repos als Git-Submodule in wb-backend - ein Push rollt alles aus; Preis: Submodule, und jede Frontend-Aenderung braucht einen Commit im Backend-Repo. (c) Der bestehende Hook holt die beiden Repos beim Bau von GitHub - keine zweite Kette; Preis: die VPS braucht Lesezugriff auf GitHub, also einen Deploy-Key, den es heute bewusst nicht gibt (rules.md Abschnitt 2). Der Bau selbst ist in deploy.md bereits geregelt: pnpm, --frozen-lockfile, im Container ohne gemountete Secret-Dateien.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ein Push rollt die Oberflaeche aus, ohne dass jemand ein Verzeichnis von Hand auf die Maschine legt
- [x] #2 Der Weg steht in deploy.md, samt dem Preis der beiden verworfenen Alternativen
<!-- AC:END -->
