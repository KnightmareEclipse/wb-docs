# Phase 6 — Wiederkehrendes Reboot-Unlock

`[MANUELL, dauerhaft]`

SSH → Dropbear → Passphrase → Platte entschlüsselt → Dropbear beendet sich → normaler Boot läuft weiter. Dieser Schritt ist bei jedem Reboot manuell — kein Tooling-Defizit, sondern das Sicherheitsmodell aus `idea/01-boot-verschluesselung.md`.

Ist Dropbear per SSH nicht erreichbar (Netzwerkfehler im Initramfs, defektes Initramfs nach einem Kernel-Update): gleicher Fallback wie [Phase 3](03-erstes-unlock.md) — Zugriff über Hetzner-Konsole/VNC.
