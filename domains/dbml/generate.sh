#!/usr/bin/env bash
# Erzeugt je Fachdomäne eine .dbml, die AUSSCHLIESSLICH die Beziehungen zeigt —
# je Tabelle nur Primär- und Fremdschlüssel, dazu die Ref-Zeilen.
#
#   ./domains/dbml/generate.sh          (aus dem Repo-Wurzelverzeichnis)
#
# Ergebnis: domains/dbml/<domäne>.dbml, einzeln einfügbar auf dbdiagram.io.
#
# ABGELEITET, NIE VON HAND PFLEGEN — dieselbe Regel wie bei
# domains/stammdaten-schema-plain.sql. Die Quelle ist die geladene Datenbank,
# nicht diese Dateien: das Skript fährt eine Wegwerf-Datenbank hoch, lädt die
# Schemata in ihrer Ladereihenfolge und liest Primär- und Fremdschlüssel aus dem
# Systemkatalog. Damit kann keine Beziehung still neben der .sql herlaufen
# (CLAUDE.md, „Einstieg in eine Session") — was hier steht, hat Postgres
# tatsächlich angelegt.
#
# Bewusst NUR Beziehungen: Spalten, Typen und Constraints stehen in der .sql und
# hätten hier eine zweite, veraltende Fassung. Wer eine vollständige Ansicht
# braucht, nimmt pgModeler gegen dieselbe Wegwerf-Datenbank.
#
# Gezeigt werden die AUSGEHENDEN Fremdschlüssel einer Domäne. Tabellen fremder
# Domänen erscheinen als Stub mit ihrer Herkunft im Namen — eingehende Kanten
# stehen im Diagramm der Domäne, die sie erklärt.
set -euo pipefail

CONTAINER=wbdbml
IMAGE=docker.io/library/postgres:18
OUT=domains/dbml

# Ladereihenfolge = Abhängigkeitsreihenfolge. Der Name vor dem Doppelpunkt wird
# zum Dateinamen und zur Domänenbezeichnung.
SCHEMATA=(
  "stammdaten:domains/stammdaten-schema.sql"
  "putzdienst:domains/putzdienst-schema.sql"
  "anmeldung:domains/anmeldung-schema.sql"
  "ferien:domains/ferien-schema.sql"
  "gesundheit:domains/gesundheit-schema.sql"
)

command -v podman >/dev/null || { echo "podman nicht gefunden" >&2; exit 1; }
[ -d "$OUT" ] || { echo "aus dem Repo-Wurzelverzeichnis aufrufen" >&2; exit 1; }

cleanup () { podman rm -f "$CONTAINER" >/dev/null 2>&1 || true; }
trap cleanup EXIT
cleanup

podman run --rm -d --name "$CONTAINER" -e POSTGRES_PASSWORD=x "$IMAGE" >/dev/null
until podman exec "$CONTAINER" pg_isready -U postgres >/dev/null 2>&1; do sleep 1; done

psql () { podman exec -i "$CONTAINER" psql -U postgres "$@"; }

# Zuordnung Tabelle → Domäne: nach jedem geladenen Schema gilt alles, was neu
# dazugekommen ist, als dessen Tabelle. Das braucht keine gepflegte Liste und
# geht deshalb auch bei einer neuen Domäne nicht kaputt.
psql -q -v ON_ERROR_STOP=1 -c \
  'CREATE TABLE _domain_map (domain text NOT NULL, tbl text PRIMARY KEY);
   CREATE TABLE _fk_map (domain text NOT NULL, oid oid PRIMARY KEY);' >/dev/null

for entry in "${SCHEMATA[@]}"; do
  domain=${entry%%:*}; file=${entry#*:}
  podman cp "$file" "$CONTAINER:/tmp/schema.sql"
  psql -q -v ON_ERROR_STOP=1 -f /tmp/schema.sql >/dev/null
  psql -q -v ON_ERROR_STOP=1 -c "
    INSERT INTO _domain_map (domain, tbl)
    SELECT '$domain', c.relname
      FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
     WHERE n.nspname = 'public' AND c.relkind = 'r'
       AND c.relname NOT LIKE '\_%'
       AND c.relname NOT IN (SELECT tbl FROM _domain_map);
    -- Fremdschlüssel getrennt zuordnen, nicht über die Tabelle: eine Domäne
    -- erweitert payments per ALTER TABLE um ihre eigene Vorgangs-Spalte (Q3),
    -- und diese Kante gehört ihr — nicht dem Putzdienst, der die Tabelle
    -- angelegt hat.
    INSERT INTO _fk_map (domain, oid)
    SELECT '$domain', k.oid FROM pg_constraint k
     WHERE k.contype = 'f' AND k.oid NOT IN (SELECT oid FROM _fk_map);" >/dev/null
  echo "geladen: $domain"
done

# Primärschlüssel und Fremdschlüssel als flache Zeilen; die Formatierung macht
# python3 unten, weil Gruppierung in SQL hier nur schlechter lesbar wäre.
psql -tAF'|' -v ON_ERROR_STOP=1 -c "
  SELECT 'PK', m.domain, c.relname, a.attname, format_type(a.atttypid, a.atttypmod)
    FROM pg_constraint k
    JOIN pg_class c ON c.oid = k.conrelid
    JOIN _domain_map m ON m.tbl = c.relname
    JOIN unnest(k.conkey) WITH ORDINALITY AS ck(attnum, ord) ON true
    JOIN pg_attribute a ON a.attrelid = c.oid AND a.attnum = ck.attnum
   WHERE k.contype = 'p'
   ORDER BY c.relname, ck.ord;" > /tmp/wbdbml-pk.txt

psql -tAF'|' -v ON_ERROR_STOP=1 -c "
  SELECT 'FK', m.domain, c.relname, a.attname, format_type(a.atttypid, a.atttypmod),
         fc.relname, fa.attname, fm.domain, tm.domain
    FROM pg_constraint k
    JOIN pg_class c   ON c.oid  = k.conrelid
    JOIN pg_class fc  ON fc.oid = k.confrelid
    JOIN _fk_map m      ON m.oid  = k.oid
    JOIN _domain_map tm ON tm.tbl = c.relname
    JOIN _domain_map fm ON fm.tbl = fc.relname
    JOIN unnest(k.conkey)  WITH ORDINALITY AS ck(attnum, ord) ON true
    JOIN unnest(k.confkey) WITH ORDINALITY AS fk(attnum, ord) ON fk.ord = ck.ord
    JOIN pg_attribute a  ON a.attrelid  = c.oid  AND a.attnum  = ck.attnum
    JOIN pg_attribute fa ON fa.attrelid = fc.oid AND fa.attnum = fk.attnum
   WHERE k.contype = 'f'
   ORDER BY c.relname, k.conname, ck.ord;" > /tmp/wbdbml-fk.txt

python3 - "$OUT" <<'PY'
import sys, collections, os

out_dir = sys.argv[1]
labels = {"stammdaten": "Stammdaten", "putzdienst": "Putzdienst",
          "anmeldung": "Anmeldung", "ferien": "Ferienanmeldung",
          "gesundheit": "Gesundheitsdaten"}
sources = {"stammdaten": "domains/stammdaten-schema.sql",
           "putzdienst": "domains/putzdienst-schema.sql",
           "anmeldung": "domains/anmeldung-schema.sql",
           "ferien": "domains/ferien-schema.sql",
           "gesundheit": "domains/gesundheit-schema.sql"}

pk = collections.defaultdict(list)          # tabelle -> [(spalte, typ)]
domain_of = {}
for line in open("/tmp/wbdbml-pk.txt"):
    line = line.rstrip("\n")
    if not line:
        continue
    _, dom, tbl, col, typ = line.split("|")
    pk[tbl].append((col, typ))
    domain_of[tbl] = dom

# fk_dom = Domäne, die die Kante erzeugt hat; tbl_dom = Domäne der Tabelle.
# Beide gehen auseinander, wo eine Domäne payments per ALTER TABLE erweitert.
fks = []                                     # (fk_dom, tbl, col, typ, ftbl, fcol, fdom, tbl_dom)
for line in open("/tmp/wbdbml-fk.txt"):
    line = line.rstrip("\n")
    if not line:
        continue
    _, dom, tbl, col, typ, ftbl, fcol, fdom, tbl_dom = line.split("|")
    fks.append((dom, tbl, col, typ, ftbl, fcol, fdom, tbl_dom))
    domain_of.setdefault(tbl, tbl_dom)
    domain_of.setdefault(ftbl, fdom)

for dom, label in labels.items():
    own_fks = [f for f in fks if f[0] == dom]
    own_tables = sorted({t for t, d in domain_of.items() if d == dom})
    foreign_tables = sorted(
        {f[4] for f in own_fks if f[6] != dom} | {f[1] for f in own_fks if f[7] != dom})

    # Spalten je Tabelle: Primärschlüssel plus die Fremdschlüssel-Spalten.
    cols = collections.defaultdict(dict)
    for tbl in own_tables:
        for col, typ in pk.get(tbl, []):
            cols[tbl][col] = (typ, True)
    for _, tbl, col, typ, ftbl, fcol, _fd, _td in own_fks:
        cols[tbl].setdefault(col, (typ, False))
        if ftbl in foreign_tables:
            cols[ftbl].setdefault(fcol, ("", False))

    lines = [
        f"// {label} — nur Beziehungen",
        "//",
        f"// Erzeugt von domains/dbml/generate.sh aus {sources[dom]}.",
        "// ABGELEITET — nicht von Hand pflegen. Quelle ist die geladene Datenbank,",
        "// nicht diese Datei; Spalten, Typen und Constraints stehen in der .sql.",
        "//",
        "// Je Tabelle stehen ausschließlich Primär- und Fremdschlüssel, damit die",
        "// Kanten lesbar bleiben. Tabellen anderer Domänen sind Stubs und tragen",
        "// ihre Herkunft als Notiz.",
        "",
    ]

    for tbl in own_tables:
        lines.append(f"Table {tbl} {{")
        entries = cols.get(tbl) or {}
        if not entries:
            lines.append("  // ohne Schlüsselbeziehung")
        for col, (typ, is_pk) in entries.items():
            suffix = " [pk]" if is_pk else ""
            lines.append(f"  {col} {typ or 'uuid'}{suffix}")
        lines.append("}")
        lines.append("")

    for tbl in foreign_tables:
        lines.append(f'Table {tbl} [note: \'aus {labels[domain_of[tbl]]}\'] {{')
        for col, (typ, is_pk) in (cols.get(tbl) or {}).items():
            suffix = " [pk]" if is_pk else ""
            lines.append(f"  {col} {typ or 'uuid'}{suffix}")
        lines.append("}")
        lines.append("")

    seen = set()
    for _, tbl, col, _t, ftbl, fcol, _fd, _td in own_fks:
        ref = f"Ref: {tbl}.{col} > {ftbl}.{fcol}"
        if ref not in seen:
            seen.add(ref)
            lines.append(ref)

    if foreign_tables:
        lines += ["", f'TableGroup "Fremde Domänen" {{']
        lines += [f"  {t}" for t in foreign_tables]
        lines.append("}")

    path = os.path.join(out_dir, f"{dom}.dbml")
    with open(path, "w") as fh:
        fh.write("\n".join(lines).rstrip() + "\n")
    print(f"geschrieben: {path}  ({len(own_tables)} Tabellen, {len(seen)} Beziehungen)")
PY
