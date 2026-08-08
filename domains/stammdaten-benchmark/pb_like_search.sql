\set n random(0, 9)
SELECT count(*) FROM persons WHERE lower(last_name) LIKE 'nachname' || :n || '%';
