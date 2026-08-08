-- Pool-Tabellen für die Benchmark-Queries: je 1000 zufällig gezogene, echte
-- IDs aus den Massendaten. Zweck: jede Benchmark-Query braucht einen
-- zufälligen, aber realistischen Parameter (ein Kind, eine Familie, ...),
-- ohne bei jedem einzelnen Aufruf selbst über 500.000+ Zeilen zu sortieren
-- (ORDER BY random() LIMIT 1 direkt auf children wäre schon selbst die
-- teuerste Operation im ganzen Benchmark). Nicht Teil des Schemas — reine
-- Testinfrastruktur, am Ende mit DROP wieder entfernt.
DROP TABLE IF EXISTS bench_pool_children, bench_pool_families, bench_pool_classes,
                      bench_pool_guardian_persons, bench_pool_emails, bench_pool_addresses,
                      bench_pool_phones;

CREATE TABLE bench_pool_children AS
    SELECT row_number() OVER () AS n, id AS child_id FROM (
        SELECT id FROM children ORDER BY random() LIMIT 1000
    ) s;
CREATE TABLE bench_pool_families AS
    SELECT row_number() OVER () AS n, id AS family_id FROM (
        SELECT id FROM families ORDER BY random() LIMIT 1000
    ) s;
CREATE TABLE bench_pool_classes AS
    SELECT row_number() OVER () AS n, id AS class_id FROM (
        SELECT id FROM classes ORDER BY random() LIMIT 1000
    ) s;
CREATE TABLE bench_pool_guardian_persons AS
    SELECT row_number() OVER () AS n, p.id AS person_id FROM (
        SELECT p.id FROM persons p JOIN guardians g ON g.person_id = p.id ORDER BY random() LIMIT 1000
    ) s JOIN persons p ON p.id = s.id;
CREATE TABLE bench_pool_emails AS
    SELECT row_number() OVER () AS n, email FROM (
        SELECT email FROM persons WHERE email IS NOT NULL ORDER BY random() LIMIT 1000
    ) s;
CREATE TABLE bench_pool_addresses AS
    SELECT row_number() OVER () AS n, postal_code, street, house_number FROM (
        SELECT postal_code, street, house_number FROM addresses ORDER BY random() LIMIT 1000
    ) s;
CREATE TABLE bench_pool_phones AS
    SELECT row_number() OVER () AS n, id FROM (
        SELECT id FROM phone_numbers ORDER BY random() LIMIT 1000
    ) s;

CREATE INDEX ON bench_pool_children (n);
CREATE INDEX ON bench_pool_families (n);
CREATE INDEX ON bench_pool_classes (n);
CREATE INDEX ON bench_pool_guardian_persons (n);
CREATE INDEX ON bench_pool_emails (n);
CREATE INDEX ON bench_pool_addresses (n);
CREATE INDEX ON bench_pool_phones (n);
ANALYZE bench_pool_children, bench_pool_families, bench_pool_classes,
        bench_pool_guardian_persons, bench_pool_emails, bench_pool_addresses, bench_pool_phones;
