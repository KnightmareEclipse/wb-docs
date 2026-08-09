SELECT c.child_id, ph.number
FROM children c
JOIN persons p ON p.person_id = c.child_id
LEFT JOIN phone_numbers ph ON ph.person_id = p.person_id AND ph.is_primary
WHERE c.child_id = (SELECT child_id FROM bench_pool_children ORDER BY n LIMIT 1 OFFSET floor(random()*(SELECT count(*) FROM bench_pool_children))::int);
