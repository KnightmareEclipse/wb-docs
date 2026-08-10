#!/usr/bin/env bash
# Führt die Benchmark-Suite aus: jede Query N_RUNS mal per EXPLAIN (ANALYZE)
# gegen den laufenden wbstress-Container, meldet min/avg/max Execution Time.
# Aufruf: run-suite.sh <docker-exec-praefix, z.B. "docker exec wbstress"> <N_RUNS> <output.tsv>
set -euo pipefail
DEXEC="$1"
N_RUNS="${2:-5}"
OUT="$3"

run_query() {
  local name="$1" category="$2" sql="$3" wrap_txn="${4:-}"
  local times=()
  for i in $(seq 1 "$N_RUNS"); do
    local q="$sql"
    if [ "$wrap_txn" = "rollback" ]; then
      q="BEGIN; SET LOCAL app.actor='system:benchmark'; EXPLAIN (ANALYZE, TIMING, SUMMARY) $sql ROLLBACK;"
    else
      q="EXPLAIN (ANALYZE, TIMING, SUMMARY) $sql"
    fi
    local out
    out=$($DEXEC psql -U postgres -t -A -c "$q" 2>&1) || true
    local t
    t=$(echo "$out" | grep -oE "Execution Time: [0-9.]+" | head -1 | grep -oE "[0-9.]+") || true
    if [ -z "${t:-}" ]; then
      echo "WARN: keine Zeit fuer '$name' Lauf $i erhalten. Ausgabe: $out" >&2
      continue
    fi
    times+=("$t")
  done
  if [ "${#times[@]}" -eq 0 ]; then
    echo -e "${category}\t${name}\tFEHLER\tFEHLER\tFEHLER\t0" >> "$OUT"
    return
  fi
  local min max sum avg
  min=$(printf '%s\n' "${times[@]}" | sort -n | head -1)
  max=$(printf '%s\n' "${times[@]}" | sort -n | tail -1)
  sum=$(printf '%s\n' "${times[@]}" | awk '{s+=$1} END{print s}')
  avg=$(awk -v s="$sum" -v n="${#times[@]}" 'BEGIN{printf "%.3f", s/n}')
  echo -e "${category}\t${name}\t${min}\t${avg}\t${max}\t${#times[@]}" >> "$OUT"
}

echo -e "kategorie\tquery\tmin_ms\tavg_ms\tmax_ms\tlaeufe" > "$OUT"

# A. Punkt-Lookups ------------------------------------------------------------
run_query "Person per PK" "A. Punkt-Lookup" \
  "SELECT * FROM persons WHERE person_id = (SELECT person_id FROM bench_pool_guardian_persons ORDER BY n LIMIT 1 OFFSET floor(random()*(SELECT count(*) FROM bench_pool_guardian_persons))::int);"

run_query "Guardian-Login per E-Mail (OTP-Einstieg)" "A. Punkt-Lookup" \
  "SELECT p.person_id, g.guardian_id FROM persons p JOIN guardians g ON g.guardian_id = p.person_id WHERE p.email = (SELECT email FROM bench_pool_emails ORDER BY n LIMIT 1 OFFSET floor(random()*(SELECT count(*) FROM bench_pool_emails))::int);"

run_query "Hauptnummer einer Person" "A. Punkt-Lookup" \
  "SELECT number FROM phone_numbers WHERE person_id = (SELECT person_id FROM bench_pool_guardian_persons ORDER BY n LIMIT 1 OFFSET floor(random()*(SELECT count(*) FROM bench_pool_guardian_persons))::int) AND is_primary;"

run_query "Kind per PK" "A. Punkt-Lookup" \
  "SELECT * FROM children WHERE child_id = (SELECT child_id FROM bench_pool_children ORDER BY n LIMIT 1 OFFSET floor(random()*(SELECT count(*) FROM bench_pool_children))::int);"

# B. LIKE-Suchen ---------------------------------------------------------------
run_query "Namenssuche, Praefix selektiv ('nachname123%')" "B. LIKE-Suche" \
  "SELECT count(*) FROM persons WHERE lower(last_name) LIKE 'nachname123%';"

run_query "Namenssuche, Praefix breit ('nachname1%')" "B. LIKE-Suche" \
  "SELECT count(*) FROM persons WHERE lower(last_name) LIKE 'nachname1%';"

run_query "Namenssuche, Teilstring ('%23456%', kein Index nutzbar)" "B. LIKE-Suche" \
  "SELECT count(*) FROM persons WHERE lower(last_name) LIKE '%23456%';"

# C. Adresssuche -----------------------------------------------------------
run_query "Adresssuche exakt (PLZ+Strasse+Hausnr, Eingabemaske-Duplikatpruefung)" "C. Adresssuche" \
  "SELECT address_id FROM addresses a WHERE (a.postal_code, a.street, a.house_number) = (SELECT postal_code, street, house_number FROM bench_pool_addresses ORDER BY n LIMIT 1 OFFSET floor(random()*(SELECT count(*) FROM bench_pool_addresses))::int);"

# D. Mittlere JOINs ----------------------------------------------------------
run_query "Kind + Familie" "D. Mittlerer JOIN" \
  "SELECT c.child_id, f.family_id FROM children c JOIN families f ON f.family_id = c.family_id WHERE c.child_id = (SELECT child_id FROM bench_pool_children ORDER BY n LIMIT 1 OFFSET floor(random()*(SELECT count(*) FROM bench_pool_children))::int);"

run_query "Kind + Hauptnummer" "D. Mittlerer JOIN" \
  "SELECT c.child_id, ph.number FROM children c JOIN persons p ON p.person_id = c.child_id LEFT JOIN phone_numbers ph ON ph.person_id = p.person_id AND ph.is_primary WHERE c.child_id = (SELECT child_id FROM bench_pool_children ORDER BY n LIMIT 1 OFFSET floor(random()*(SELECT count(*) FROM bench_pool_children))::int);"

run_query "Hauptzahler:in eines Kindes" "D. Mittlerer JOIN" \
  "SELECT c.child_id, py.iban, pp.last_name FROM children c JOIN payers py ON py.payer_id = c.payer_id JOIN persons pp ON pp.person_id = py.payer_id WHERE c.child_id = (SELECT child_id FROM bench_pool_children ORDER BY n LIMIT 1 OFFSET floor(random()*(SELECT count(*) FROM bench_pool_children))::int);"

run_query "Notfallkontakte eines Kindes, nach Prioritaet" "D. Mittlerer JOIN" \
  "SELECT c.child_id, pc.first_name, pc.last_name, cc.priority, cc.pickup_authorized FROM children c JOIN child_contacts cc ON cc.child_id = c.child_id JOIN persons pc ON pc.person_id = cc.contact_id WHERE c.child_id = (SELECT child_id FROM bench_pool_children ORDER BY n LIMIT 1 OFFSET floor(random()*(SELECT count(*) FROM bench_pool_children))::int) ORDER BY cc.priority NULLS LAST;"

run_query "Dublettenpruefung beim Import (Nachname+Geburtsdatum)" "D. Mittlerer JOIN" \
  "SELECT count(*) FROM children c2 JOIN persons p2 ON p2.person_id = c2.child_id WHERE (p2.last_name, c2.date_of_birth) = (SELECT p.last_name, c.date_of_birth FROM children c JOIN persons p ON p.person_id = c.child_id WHERE c.child_id = (SELECT child_id FROM bench_pool_children ORDER BY n LIMIT 1 OFFSET floor(random()*(SELECT count(*) FROM bench_pool_children))::int));"

# E. Schwere JOINs (5+ Tabellen) -----------------------------------------------
run_query "OTP-Request-Pfad: Familie mit allen Kindern+Erziehungsberechtigten+Telefon" "E. Schwerer JOIN" \
  "SELECT c.child_id, p_kind.last_name, g.guardian_id, p_g.last_name, ph.number FROM families f JOIN children c ON c.family_id = f.family_id JOIN persons p_kind ON p_kind.person_id = c.child_id JOIN family_guardians fg ON fg.family_id = f.family_id JOIN guardians g ON g.guardian_id = fg.guardian_id JOIN persons p_g ON p_g.person_id = g.guardian_id LEFT JOIN phone_numbers ph ON ph.person_id = p_g.person_id AND ph.is_primary WHERE f.family_id = (SELECT family_id FROM bench_pool_families ORDER BY n LIMIT 1 OFFSET floor(random()*(SELECT count(*) FROM bench_pool_families))::int);"

run_query "Sekretariats-Vollansicht: ein Kind komplett (Familie, Erziehungsberechtigte, Adressen, Telefon)" "E. Schwerer JOIN" \
  "SELECT c.*, p_kind.*, a_kind.*, g.guardian_id, p_g.last_name, a_g.street, ph.number FROM children c JOIN persons p_kind ON p_kind.person_id = c.child_id LEFT JOIN addresses a_kind ON a_kind.address_id = p_kind.address_id JOIN family_guardians fg ON fg.family_id = c.family_id JOIN guardians g ON g.guardian_id = fg.guardian_id JOIN persons p_g ON p_g.person_id = g.guardian_id LEFT JOIN addresses a_g ON a_g.address_id = p_g.address_id LEFT JOIN phone_numbers ph ON ph.person_id = p_g.person_id AND ph.is_primary WHERE c.child_id = (SELECT child_id FROM bench_pool_children ORDER BY n LIMIT 1 OFFSET floor(random()*(SELECT count(*) FROM bench_pool_children))::int);"

run_query "Admin-Klassenliste: alle Kinder einer Klasse mit Hauptkontakt" "E. Schwerer JOIN" \
  "SELECT c.child_id, p_kind.last_name, p_g.last_name, ph.number FROM children c JOIN persons p_kind ON p_kind.person_id = c.child_id LEFT JOIN family_guardians fg ON fg.family_id = c.family_id LEFT JOIN guardians g ON g.guardian_id = fg.guardian_id LEFT JOIN persons p_g ON p_g.person_id = g.guardian_id LEFT JOIN phone_numbers ph ON ph.person_id = p_g.person_id AND ph.is_primary WHERE c.class_id = (SELECT class_id FROM bench_pool_classes ORDER BY n LIMIT 1 OFFSET floor(random()*(SELECT count(*) FROM bench_pool_classes))::int);"

# F. Aggregationen / Dashboards ------------------------------------------------
run_query "Kinder je Klassenstufe (GROUP BY)" "F. Aggregation" \
  "SELECT gl.label, count(*) FROM children c JOIN classes cl ON cl.class_id = c.class_id JOIN grade_levels gl ON gl.grade_level_id = cl.grade_level_id GROUP BY gl.label;"

run_query "Familien ohne Erziehungsberechtigte-E-Mail (Datenqualitaet)" "F. Aggregation" \
  "SELECT count(*) FROM families f WHERE NOT EXISTS (SELECT 1 FROM family_guardians fg JOIN guardians g ON g.guardian_id = fg.guardian_id JOIN persons p ON p.person_id = g.guardian_id WHERE fg.family_id = f.family_id AND p.email IS NOT NULL);"

# G. Worst-Case / Volltabellen --------------------------------------------------
run_query "Volle Verwaltungsliste ohne Filter (alle Kinder+Hauptkontakt)" "G. Worst-Case" \
  "SELECT c.child_id, p_kind.last_name, p_g.last_name, ph.number FROM children c JOIN persons p_kind ON p_kind.person_id = c.child_id LEFT JOIN family_guardians fg ON fg.family_id = c.family_id LEFT JOIN guardians g ON g.guardian_id = fg.guardian_id LEFT JOIN persons p_g ON p_g.person_id = g.guardian_id LEFT JOIN phone_numbers ph ON ph.person_id = p_g.person_id AND ph.is_primary;"

run_query "Voller Export aller Kind+Person-Felder, alle Zeilen" "G. Worst-Case" \
  "SELECT c.*, p.* FROM children c JOIN persons p ON p.person_id = c.child_id;"

# H. Schreibpfad (Einzelzeile, mit ROLLBACK) ------------------------------------
run_query "Einzel-INSERT: neue Familie+Person+Kind" "H. Schreibpfad" \
  "INSERT INTO families (family_id) VALUES (gen_random_uuid());" "rollback"

run_query "Einzel-UPDATE: eine Telefonnummer aendern" "H. Schreibpfad" \
  "UPDATE phone_numbers SET number = '0000000' WHERE phone_number_id = (SELECT id FROM bench_pool_phones ORDER BY n LIMIT 1 OFFSET floor(random()*(SELECT count(*) FROM bench_pool_phones))::int);" "rollback"

# I. Batch/Administrativ ---------------------------------------------------------
run_query "Jahreslauf: eine Klassenstufe fuer die Realschule weitersetzen" "I. Batch" \
  "UPDATE classes SET grade_level_id = grade_level_id + 1 WHERE grade_level_id IN (SELECT grade_level_id FROM grade_levels WHERE school_branch_id = 2 AND sort_order < 10);" "rollback"

echo "fertig: $OUT"
