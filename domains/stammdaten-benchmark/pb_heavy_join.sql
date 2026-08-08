\set n random(0, 999)
SELECT c.id, p_kind.last_name, g.id, p_g.last_name, ph.number
FROM families f
JOIN children c ON c.family_id = f.id
JOIN persons p_kind ON p_kind.id = c.id
JOIN family_guardians fg ON fg.family_id = f.id
JOIN guardians g ON g.id = fg.guardian_id
JOIN persons p_g ON p_g.id = g.person_id
LEFT JOIN phone_numbers ph ON ph.person_id = p_g.id AND ph.is_primary
WHERE f.id = (SELECT family_id FROM bench_pool_families ORDER BY n LIMIT 1 OFFSET :n);
