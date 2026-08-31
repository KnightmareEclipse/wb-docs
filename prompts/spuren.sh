#!/bin/sh
# Eine Spur je offenem Prüfbericht: zwei Arbeitsbäume nebeneinander, ein eigener
# Compose-Stack, eine Hintergrundsession mit api-reparieren.md darauf. Nur für die
# Fachdomänen — `routen.md`, `stammdaten` und `querschnitt` fassen gemeinsamen Code
# an und laufen nacheinander im Hauptbaum (api-reparieren.md, Kopf).
#
# Getrennt wird bis zur Datenbank hinunter, und das ist der Grund für das ganze
# Skript: `tests/conftest.py` truncatet `persons`, `families` und den Rest vor und
# nach jeder Suite. Zwei Läufe an einer Datenbank wischen sich gegenseitig die rote
# Messung weg, auf der dieser Prompt steht — und ein so entstandener roter Test
# sieht aus wie ein Fund.
set -eu

root=$(cd "$(dirname "$0")/../.." && pwd)
docs="$root/wb-docs"
back="$root/wb-backend"

# Der saubere Hauptbaum ist die Rücknahme: Was eine Spur danebengreift, ist ein
# `git checkout` entfernt. Uncommittete eigene Arbeit daneben macht den Fehlgriff
# von ihr ununterscheidbar.
for repo in "$docs" "$back"; do
    [ -z "$(git -C "$repo" status --porcelain)" ] ||
        { echo "$repo ist nicht sauber — erst committen"; exit 1; }
done

for bericht in "$docs"/pruefberichte/routen-*.md; do
    [ -e "$bericht" ] || { echo "Kein offener Bericht"; exit 0; }
    domaene=$(basename "$bericht" .md)
    domaene=${domaene#routen-}
    spur="$root/spur-$domaene"

    if [ -d "$spur" ]; then
        echo "spur-$domaene steht schon, übersprungen"
        continue
    fi

    # Das Paar heißt wie die Repos und liegt nebeneinander, weil beides gelesen
    # wird: schema-check.sh nimmt `WB_DOCS:-../wb-docs`, und der Prompt schreibt
    # seine Doku-Pfade relativ. Ein anderes Layout greift still auf den Hauptbaum
    # durch, und dann committen alle Spuren in dasselbe wb-docs.
    mkdir -p "$spur"
    git -C "$back" worktree add "$spur/wb-backend" -b "reparatur-$domaene" >/dev/null
    git -C "$docs" worktree add "$spur/wb-docs"    -b "reparatur-$domaene" >/dev/null

    # Ohne eigenen Projektnamen teilen sich alle Spuren Container und Volume des
    # Hauptstacks — siehe oben, dann ist die Trennung nur auf dem Papier.
    cp "$back/.env" "$spur/wb-backend/.env"
    echo "COMPOSE_PROJECT_NAME=spur-$domaene" >> "$spur/wb-backend/.env"

    # Symlinks statt Kopien: Eine Kopie erbt `user_home_t` statt `container_file_t`,
    # Postgres kommt nicht an sein Passwort und stirbt beim Start — in pytest kommt
    # das als Collection-Error auf `db_password` an und sieht wie ein Codefehler aus.
    # Nebenbei bleibt jedes Geheimnis einmal auf der Platte statt einmal je Spur.
    for geheimnis in "$back"/secrets/*; do
        ln -sf "$geheimnis" "$spur/wb-backend/secrets/"
    done

    # Eine volle Session je Spur, kein Subagent: Der Lauf urteilt über jeden Fund
    # selbst, und genau das verbietet `gemeinsam.md` einem Subagenten.
    # Der Kopf bis zum Trennstrich ist Bedienanleitung — er nennt die Reihenfolge
    # aller dreizehn Läufe und dieses Skript, und eine Session, die das als Auftrag
    # liest, hält sich für den Orchestrator. Abgeschnitten bleibt ihr Auftrag übrig.
    prompt=$(sed -e '1,/^---$/d' -e "s/DOMÄNE/$domaene/g" "$docs/prompts/api-reparieren.md")
    # `--bg` meldet "backgrounded · <id>" und darunter vier Zeilen Bedienhinweis;
    # ohne das `sed` stünde der ganze Block in `id`.
    id=$(cd "$spur/wb-backend" && claude --bg --effort xhigh \
        --permission-mode bypassPermissions --add-dir "$spur/wb-docs" "$prompt" |
        sed -n '1s/.* //p')
    [ -n "$id" ] || { echo "$domaene: nicht gestartet"; exit 1; }
    echo "$domaene: $id"
done

echo
echo "claude agents        — Stand aller Läufe"
echo "claude logs <id>     — Meldung eines Laufs"
