\set n random(0, 999)
SELECT * FROM persons WHERE id = (SELECT person_id FROM bench_pool_guardian_persons ORDER BY n LIMIT 1 OFFSET :n);
