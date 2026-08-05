# VPS-Repo — Coding Style

Governs all code in `vps/`. Root repo `cyborg` (`../CLAUDE.md`, `../rules.md`) is German, operator-only, architecture/concept context — not code rules. Other implementation repos get their own analogous `CLAUDE.md`.

Status: draft, pending Johannes's review.

## 1. Language: English
Identifiers, comments, stdout/stderr output: English. `.md` files in root repo (`cyborg`) stay German. Everything in `vps/`: English, no exceptions.

## 2. Shell script header
Every `.sh` starts with:
```bash
#!/usr/bin/env bash
# <what this does> (see <spec doc path>)
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
trap 'echo "ERROR: line $LINENO" >&2' ERR
```
No `IFS=$'\n\t'` — vars/arrays are always quoted, adds no benefit, known footgun.

## 3. Idempotency + loud failure
- Check state before acting (`describe` before `create`), never act blind.
- Unexpected/ambiguous state → hard-fail, non-zero exit, clear message. Never guess, never just warn.
- Errors → stderr. Success/info → stdout.
- Non-zero exit on any failure, zero only on success.
- Never suppress a real action's failure. `>/dev/null 2>&1` only on pure existence-check probes.
- Manual scripts (Phase 1–2): above is sufficient. Recurring automated jobs (Phase 2 heartbeat): also need active push-alert on failure (`rules.md` §3).

## 4. Config vs. code
- Values that can change without logic changing (names, ports, admins, timeouts, retries) → `vars.sh` (scalars) or `.yml` (lists). Never a literal inside a logic script.
- One canonical source per fact — e.g. `ports.yml` read by both Phase 1 (Cloud Firewall) and Phase 3 (UFW).
- `vars.sh`: assignments only, no conditionals/loops/functions.

## 5. Naming
- Shell script files: kebab-case (`docker-install.sh`).
- Python files: snake_case (`admins_to_ssh_keys.py`).
- Bash config constants: `SCREAMING_SNAKE_CASE`.
- Bash local vars: `snake_case`.
- Bash functions: `snake_case`, verb-first.
- Python: PEP 8 (`snake_case` vars/functions, `UPPER_SNAKE_CASE` constants).
- YAML keys: `snake_case`.
- `hcloud` resource names: kebab-case (`db-prod-fsn-01`, `vps-firewall`).

## 6. Comments: why, not what
- No comment restating the next line.
- Comment only for non-obvious constraints, workarounds, or reasoning.
- Public interfaces: one-line purpose comment, nothing more.
- No commented-out code — delete it, git history has it.

## 7. Secrets never in output/logs
- No secret printed to stdout/stderr, except an explicit, clearly-marked one-time handoff (e.g. a freshly generated credential shown once for the admin to store in the password manager).
- No secret as a CLI argument (visible in `ps`/shell history) — stdin or file instead.
- No secret logged, even at debug/verbose level — mask before logging.
- Secret material covered by `.gitignore`, never committed.

## 8. Small, focused scripts/functions
- One script per phase/task. No multi-purpose script driven by flags.
- One function, one job. An inline "now do X" comment signals a missing function.
- Split only when a script is actually hard to follow, not preemptively.

## 9. Python only where Bash is unreadable
- Default: Bash, for CLI orchestration (`hcloud`, `ssh`, `cryptsetup`, `ufw`).
- Python: only for YAML/JSON transformation Bash handles poorly.
- Python helper = its own file, called from a Bash entrypoint. Never inline (root repo rule: no files in files).
- stdlib + PyYAML only. No new dependency without a concrete, current need.

## 10. Linting & formatting: automated
- `.sh`: shellcheck-clean, or `# shellcheck disable=SC1234` + one-line reason.
- `.py`: `black`, default settings.
- Run locally pre-commit (documented command in `vps/README.md`). CI wiring waits until a CI platform is chosen for this repo.

## 11. Minimal check for non-trivial logic
- Branch/loop/parsing logic → one small runnable check (`assert`-based smoke test or minimal `test_*.py`).
- Trivial one-liners: no test needed.
- Backlog: `lib/admins_to_ssh_keys.py`, `lib/ports_to_firewall_rules.py` — both qualify, neither has one yet.

## 12. Commit hygiene
- One commit = one self-contained, working change.
- Message: short imperative summary (~72 chars), blank line, body only if needed (why, not what).
- Unrelated changes → separate commits.

## 13. Keep it simple — no overengineering
- No abstraction/config layer/flag/generalization without a concrete, current need. Never "for later."
- Simpler version still works → use it.
- No feature flags, unused params, or new dependency for what stdlib/an existing tool already solves.
- Ladder (mirrors `rules.md` §1): needed at all? → covered by existing code? → covered by stdlib? → only then, minimal custom code.
- Deliberate shortcut → one-line comment naming it + when to revisit.

## 14. Concise, filler-free text
Applies everywhere: comments, commits, docs, log/error messages.
- No filler/hedging ("basically", "essentially", "it should be noted").
- No content-free adjectives ("robust", "powerful", "seamless").
- Short sentence over paragraph. Bullets over prose for 3+ items.
- State each fact once, in one place.
- Error/log message: what happened + actionable next step, nothing more.
- Explanation longer than the change it describes → the change is too complex, not under-explained.
