SELECT c.child_id, p_kind.last_name, g.guardian_id, p_g.last_name, ph.number
FROM families f
JOIN children c ON c.family_id = f.family_id
JOIN persons p_kind ON p_kind.person_id = c.child_id
JOIN family_guardians fg ON fg.family_id = f.family_id
JOIN guardians g ON g.guardian_id = fg.guardian_id
JOIN persons p_g ON p_g.person_id = g.guardian_id
LEFT JOIN phone_numbers ph ON ph.person_id = p_g.person_id AND ph.is_primary
WHERE f.family_id = (SELECT family_id FROM bench_pool_families ORDER BY n LIMIT 1 OFFSET floor(random()*(SELECT count(*) FROM bench_pool_families))::int);
