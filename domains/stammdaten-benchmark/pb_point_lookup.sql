SELECT * FROM persons WHERE person_id = (SELECT person_id FROM bench_pool_guardian_persons ORDER BY n LIMIT 1 OFFSET floor(random()*(SELECT count(*) FROM bench_pool_guardian_persons))::int);
