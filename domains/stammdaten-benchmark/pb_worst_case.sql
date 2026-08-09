SELECT c.child_id, p_kind.last_name, p_g.last_name, ph.number
FROM children c
JOIN persons p_kind ON p_kind.person_id = c.child_id
LEFT JOIN family_guardians fg ON fg.family_id = c.family_id
LEFT JOIN guardians g ON g.guardian_id = fg.guardian_id
LEFT JOIN persons p_g ON p_g.person_id = g.guardian_id
LEFT JOIN phone_numbers ph ON ph.person_id = p_g.person_id AND ph.is_primary;
