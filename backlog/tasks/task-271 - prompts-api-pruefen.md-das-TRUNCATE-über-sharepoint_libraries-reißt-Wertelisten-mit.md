---
id: TASK-271
title: >-
  prompts/api-pruefen.md: das TRUNCATE über sharepoint_libraries reißt
  Wertelisten mit
status: Done
assignee: []
created_date: '2026-09-05 22:56'
updated_date: '2026-09-06 02:03'
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
- [x] #1 Das TRUNCATE in prompts/api-pruefen.md nimmt sharepoint_libraries nicht mehr mit
- [x] #2 Reste von sharepoint_libraries werden einzeln DELETEt statt über CASCADE, ohne referenzierende Wertelisten zu reißen
- [x] #3 Ein wiederholter Prüflauf nach einer roten Messung bleibt an Wertelisten wie holiday_session_types und holiday_modules stabil
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Bereits behoben, unabhängig von diesem Ticket bemerkt: prompts/api-pruefen.md nimmt sharepoint_libraries nicht mehr ins TRUNCATE, ein gezieltes DELETE räumt nur die Fixture-eigene Zeile (app_documents). contract_text_kinds und darüber holiday_session_types/holiday_modules bleiben damit stehen, weil kein CASCADE mehr bis zu ihnen reicht. Beim Reparaturlauf auth bemerkt (AUTH-R5), das dieselbe Zeile ein zweites Mal fand.
<!-- SECTION:NOTES:END -->
