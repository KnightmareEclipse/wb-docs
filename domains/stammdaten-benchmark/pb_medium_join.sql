SELECT c.id, ph.number
FROM children c
JOIN persons p ON p.id = c.id
LEFT JOIN phone_numbers ph ON ph.person_id = p.id AND ph.is_primary
WHERE c.id = (SELECT child_id FROM bench_pool_children ORDER BY n LIMIT 1 OFFSET floor(random()*(SELECT count(*) FROM bench_pool_children))::int);
