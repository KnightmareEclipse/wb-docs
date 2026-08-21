-- Prüfskript zu ags-schema.sql.
--
-- Sollstand: keine eigenen Tabellen und keine geliehene Struktur. Es gibt hier
-- keine Regel aus einem Block, die sich gegenprüfen ließe — geprüft wird
-- deshalb genau das Gegenteil: dass nichts auf Verdacht entstanden ist, weder
-- als eigene Tabelle noch als Spalte in einer fremden.
--
-- Setzt stammdaten-schema.sql, anmeldung-schema.sql und ferien-schema.sql
-- voraus:
--   psql -v ON_ERROR_STOP=1 -f ags-schema-check.sql

BEGIN;

DO $$
DECLARE unexpected text;
BEGIN
    SELECT string_agg(t, ', ') INTO unexpected
    FROM unnest(ARRAY['clubs', 'club_sessions', 'club_bookings', 'club_registrations',
                      'activity_groups', 'working_groups']) AS t
    WHERE to_regclass('public.' || t) IS NOT NULL;
    IF unexpected IS NOT NULL THEN
        RAISE EXCEPTION 'Für AGs sind Tabellen entstanden, obwohl nichts belegt ist: %',
                        unexpected;
    END IF;
    RAISE NOTICE 'ok: keine AG-Tabelle auf Verdacht';
END $$;

DO $$
DECLARE unexpected text;
BEGIN
    -- Auch keine geliehene Struktur: weder das Betreuungsmodul noch der
    -- Ferientermin haben ein AG-Feld bekommen.
    SELECT string_agg(table_name || '.' || column_name, ', ') INTO unexpected
    FROM information_schema.columns
    WHERE table_schema = 'public'
      -- „ag" als eigenes Wort, nicht als Silbe in „language" oder „agreement".
      AND (column_name ILIKE '%club%' OR column_name ~ '(^|_)ag(_|$)');
    IF unexpected IS NOT NULL THEN
        RAISE EXCEPTION 'Eine fremde Tabelle trägt ein AG-Feld: %', unexpected;
    END IF;

    -- Die beiden Strukturen, die man versucht wäre mitzubenutzen, stehen und
    -- gehören ihrer eigenen Domäne — das ist der Befund, nicht das Problem.
    IF to_regclass('public.care_modules') IS NULL
       OR to_regclass('public.holiday_session_types') IS NULL THEN
        RAISE EXCEPTION 'Betreuungsmodul oder Ferientermin fehlen — falsche Ladereihenfolge?';
    END IF;
    RAISE NOTICE 'ok: keine geliehene Struktur, die beiden Nachbarn bleiben unberührt';
END $$;

DO $$ BEGIN RAISE NOTICE 'ags-schema-check: nichts gebaut, und das ist das Ergebnis'; END $$;

ROLLBACK;
