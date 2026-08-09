BEGIN;
SET LOCAL app.actor = 'system:benchmark';
INSERT INTO families (family_id) VALUES (gen_random_uuid());
ROLLBACK;
