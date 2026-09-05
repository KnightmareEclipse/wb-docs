---
id: TASK-271
title: >-
  prompts/api-pruefen.md: das TRUNCATE über sharepoint_libraries reißt
  Wertelisten mit
status: To Do
assignee: []
created_date: '2026-09-05 22:56'
labels:
  - wb-docs
  - pruefzyklus
dependencies:
  - TASK-203
references:
  - prompts/api-pruefen.md
ordinal: 284000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
TASK-203 hat sharepoint_libraries in die TRUNCATE-Zeile aufgenommen, um eine uq_sharepoint_libraries_code-Kollision nach einer roten Messung zu vermeiden. Der Prüflauf ferien (FERIEN-R13) hat gemessen, dass genau das eine neue Lücke aufreißt: contract_text_kinds.working_library_id zeigt auf sharepoint_libraries, und darüber reißt CASCADE auch contract_text_kinds mit — bei Ferien zusätzlich holiday_session_types und holiday_modules über cancellation_terms_code. Keine Migration legt diese Wertelisten neu an, sie kommen allein aus dem Seed. Nach dem ersten Aufruf des Rezepts lief jede weitere Messung mit 56 errors (KeyError: 'holiday_day') — der Nullpunkt sah rot aus, ohne dass eine Mutation im Spiel war; nur down -v samt neuem migrate gab die grünen Tests zurück.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Das TRUNCATE in prompts/api-pruefen.md nimmt sharepoint_libraries nicht mehr mit
- [ ] #2 Reste von sharepoint_libraries werden einzeln DELETEt statt über CASCADE, ohne referenzierende Wertelisten zu reißen
- [ ] #3 Ein wiederholter Prüflauf nach einer roten Messung bleibt an Wertelisten wie holiday_session_types und holiday_modules stabil
<!-- AC:END -->
