BEGIN;
SET LOCAL app.actor = 'system:benchmark';
INSERT INTO families (id) VALUES (gen_random_uuid());
ROLLBACK;
