#!/usr/bin/env bash
# Stresstest-Suite zu domains/stammdaten-schema.sql — erzeugt Testdaten weit
# ueber der realen Schulgroesse (~500 Schueler), misst eine breite Auswahl an
# Einzelqueries (Punkt-Lookups, LIKE-Suchen, JOINs, Aggregationen, Worst-Case,
# Schreibpfad) sowie parallele Last per pgbench. Bewusst kein Testframework,
# reine Wegwerf-Infrastruktur gegen eine Wegwerf-Datenbank (rules.md Abschnitt 8).
#
# Aufruf (auf einer Maschine mit Docker, lokal oder auf der VPS):
#   mkdir -p /tmp/wbstress && cd /tmp/wbstress
#   cp <dieses-verzeichnis>/*.sql <dieses-verzeichnis>/*.sh ../stammdaten-schema.sql .
#   bash run-all.sh
#   Ergebnisse liegen danach in ./results/ (04-suite.tsv, 05-pgbench.log)
#
# Vorsicht bei Ausfuehrung auf einer produktiv genutzten Maschine: legt einen
# eigenen, isolierten Docker-Container "wbstress" an (kein Port-Publish, nur
# per "docker exec" erreichbar) und entfernt ihn nicht automatisch wieder —
# danach von Hand: docker rm -f wbstress && rm -rf /tmp/wbstress.
set -uo pipefail
cd /tmp/wbstress

docker rm -f wbstress >/dev/null 2>&1
# --shm-size: Dockers Default (64 MB) reicht nicht fuer Postgres' parallele
# Worker unter gleichzeitiger Last (pgbench zeigte "No space left on device"
# fuer Shared-Memory-Segmente bei Standardgroesse) — relevant auch fuer das
# spaetere wb-backend-docker-compose.yml, nicht nur fuer diesen Test.
docker run --rm -d --name wbstress --shm-size=1024m -e POSTGRES_PASSWORD=$(openssl rand -hex 20) postgres:16 >/dev/null
sleep 5
docker exec wbstress pg_isready -U postgres

rm -rf results
mkdir -p results
docker cp stammdaten-schema.sql wbstress:/tmp/schema.sql
docker exec wbstress psql -U postgres -v ON_ERROR_STOP=1 -f /tmp/schema.sql > results/01-schema.log 2>&1
echo "SCHEMA_EXIT:$?"

docker cp generate.sql wbstress:/tmp/gen.sql
docker exec wbstress psql -U postgres -v ON_ERROR_STOP=1 -f /tmp/gen.sql > results/02-generate.log 2>&1
echo "GENERATE_EXIT:$?"
tail -20 results/02-generate.log

docker cp seed.sql wbstress:/tmp/seed.sql
docker exec wbstress psql -U postgres -v ON_ERROR_STOP=1 -f /tmp/seed.sql > results/03-seed.log 2>&1
echo "SEED_EXIT:$?"

chmod +x run-suite.sh
bash run-suite.sh "docker exec wbstress" 5 results/04-suite.tsv
echo "SUITE_EXIT:$?"

for f in pb_point_lookup pb_medium_join pb_heavy_join pb_like_search pb_write pb_worst_case; do
  docker cp $f.sql wbstress:/tmp/$f.sql
done

for CLIENTS in 5 20 50; do
  echo "=== pgbench mit $CLIENTS parallelen Clients ===" | tee -a results/05-pgbench.log
  docker exec wbstress pgbench -U postgres -n \
    -f /tmp/pb_point_lookup.sql@40 \
    -f /tmp/pb_medium_join.sql@25 \
    -f /tmp/pb_heavy_join.sql@15 \
    -f /tmp/pb_like_search.sql@10 \
    -f /tmp/pb_write.sql@8 \
    -f /tmp/pb_worst_case.sql@2 \
    -c "$CLIENTS" -j 4 -T 20 -P 5 postgres >> results/05-pgbench.log 2>&1
done

docker exec wbstress psql -U postgres -c "SELECT relname, n_live_tup FROM pg_stat_user_tables ORDER BY n_live_tup DESC;" > results/06-final-counts.log 2>&1

echo "ALLES_FERTIG"
