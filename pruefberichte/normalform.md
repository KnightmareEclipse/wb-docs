# Normalform-Prüflauf

Ein Durchgang über `schema/*.sql` mit genau einer Frage: Steht jedes Nicht-Schlüsselfeld voll und
unmittelbar an seinem Schlüssel? Auftrag: `prompts/schema-normalform.md`.

## Katalog

**Ladelauf.** Alle vierzehn `.sql` in eine Wegwerf-Datenbank (Postgres 18, `ON_ERROR_STOP=1`),
Rückgabewert je Datei 0, 99 Tabellen im Schema `public`. Vier Dateien ohne Tabellen: `ags`,
`klassenbildung`, `m365`, `selfservice`.

### Zusammengesetzte Fremdschlüssel — die entschiedene Liste

Was hier auftaucht, ist mitgeführte Redundanz mit dem Schlüssel, der sie zusammenhält
(`rules.md` §1); kein Fund.

| Tabelle | mitgeführte Spalten | hält fest an |
|---|---|---|
| `admission_days` | `school_branch_id,first_grade_level,final_grade_level` | `school_branches (school_branch_id,first_grade_level,final_grade_level)` |
| `applications` | `admission_day_id,school_branch_id,target_grade_level,target_school_year` | `admission_days (admission_day_id,school_branch_id,target_grade_level,target_school_year)` |
| `applications` | `school_branch_id,first_grade_level,final_grade_level` | `school_branches (school_branch_id,first_grade_level,final_grade_level)` |
| `applications` | `application_status_id,is_final` | `application_statuses (application_status_id,is_final)` |
| `children` | `school_branch_id,first_grade_level,final_grade_level` | `school_branches (school_branch_id,first_grade_level,final_grade_level)` |
| `children` | `class_id,school_branch_id` | `classes (class_id,school_branch_id)` |
| `cleaning_assignments` | `cleaning_slot_id,cleaning_slot_type_id` | `cleaning_slots (cleaning_slot_id,cleaning_slot_type_id)` |
| `cleaning_swap_acceptances` | `cleaning_swap_offer_id,cleaning_slot_type_id` | `cleaning_swap_offers (cleaning_swap_offer_id,cleaning_slot_type_id)` |
| `cleaning_swap_acceptances` | `cleaning_slot_id,cleaning_slot_type_id` | `cleaning_slots (cleaning_slot_id,cleaning_slot_type_id)` |
| `cleaning_swap_offers` | `cleaning_assignment_id,cleaning_slot_type_id` | `cleaning_assignments (cleaning_assignment_id,cleaning_slot_type_id)` |
| `consents` | `consent_purpose_id,requires_child` | `consent_purposes (consent_purpose_id,requires_child)` |
| `employee_roles` | `role_id,is_branch_bound` | `roles (role_id,is_branch_bound)` |
| `enrolment_windows` | `school_branch_id,first_grade_level,final_grade_level` | `school_branches (school_branch_id,first_grade_level,final_grade_level)` |
| `expense_claim_items` | `expense_claim_id,submitter_employee_id,claim_type,payment_route` | `expense_claims (expense_claim_id,submitter_employee_id,claim_type,payment_route)` |
| `health_traits` | `health_trait_type_id,needs_permission,is_medication,has_treatment_reason,is_emergency_medication` | `health_trait_types (health_trait_type_id,needs_permission,is_medication,has_treatment_reason,is_emergency_medication)` |
| `holiday_bookings` | `holiday_module_id,holiday_session_type_id` | `holiday_modules (holiday_module_id,holiday_session_type_id)` |
| `holiday_bookings` | `holiday_session_id,holiday_session_type_id` | `holiday_sessions (holiday_session_id,holiday_session_type_id)` |
| `payments` | `holiday_booking_id,amount_cents` | `holiday_bookings (holiday_booking_id,amount_cents)` |
| `travel_details` | `expense_claim_id,amount_cents` | `expense_claims (expense_claim_id,amount_cents)` |

### Kandidatenschlüssel je Tabelle

PK, dahinter die UNIQUE-Constraints (`;` trennt mehrere). Ein leeres Feld heißt: nur der
Surrogatschlüssel, kein zweiter Kandidat.

| Tabelle | PK | UNIQUE |
|---|---|---|
| `access_levels` | `access_level_id` | `code` |
| `addresses` | `address_id` | — |
| `admission_day_slots` | `admission_day_slot_id` | `admission_day_id,starts_at` |
| `admission_days` | `admission_day_id` | `admission_day_id,school_branch_id,target_grade_level,target_school_year` |
| `application_offers` | `application_offer_id` | `application_id,attended_offer_id` |
| `application_statuses` | `application_status_id` | `application_status_id,is_final ; code` |
| `application_unlocks` | `application_unlock_id` | — |
| `applications` | `application_id` | — |
| `attended_offers` | `attended_offer_id` | `code` |
| `care_module_agreements` | `care_module_agreement_id` | — |
| `care_module_bookings` | `care_module_booking_id` | `care_module_agreement_id,care_module_id,weekday` |
| `care_module_prices` | `care_module_price_id` | `care_module_id,weekday_count,valid_from` |
| `care_modules` | `care_module_id` | `code` |
| `care_need_levels` | `care_need_level_id` | `code` |
| `change_log` | `change_log_id` | — |
| `child_file_folders` | `child_file_folder_id` | `child_id` |
| `child_health_records` | `child_health_record_id` | `child_id` |
| `child_meal_profiles` | `child_meal_profile_id` | `child_id` |
| `children` | `child_id` | `person_id ; school_email` |
| `claim_template_shares` | `claim_template_share_id` | `claim_template_id,cost_project_id` |
| `claim_templates` | `claim_template_id` | `name` |
| `class_representatives` | `class_representative_id` | `class_id,school_year,person_id` |
| `classes` | `class_id` | `class_id,school_branch_id ; school_branch_id,start_school_year,stream` |
| `cleaning_assignments` | `cleaning_assignment_id` | `cleaning_assignment_id,cleaning_slot_type_id ; cleaning_slot_id,family_id` |
| `cleaning_buyouts` | `cleaning_buyout_id` | — |
| `cleaning_cycle_quotas` | `cleaning_cycle_quota_id` | `cleaning_cycle_id,cleaning_slot_type_id` |
| `cleaning_cycles` | `cleaning_cycle_id` | `start_year` |
| `cleaning_family_quotas` | `cleaning_family_quota_id` | `cleaning_cycle_id,family_id,cleaning_slot_type_id` |
| `cleaning_slot_buyouts` | `cleaning_slot_buyout_id` | `cleaning_assignment_id` |
| `cleaning_slot_types` | `cleaning_slot_type_id` | `code` |
| `cleaning_slots` | `cleaning_slot_id` | `cleaning_slot_id,cleaning_slot_type_id` |
| `cleaning_swap_acceptances` | `cleaning_swap_acceptance_id` | `cleaning_swap_offer_id,cleaning_slot_id` |
| `cleaning_swap_offers` | `cleaning_swap_offer_id` | `cleaning_swap_offer_id,cleaning_slot_type_id` |
| `configured_values` | `configured_value_id` | `code,valid_from` |
| `consent_purposes` | `consent_purpose_id` | `code ; consent_purpose_id,requires_child` |
| `consents` | `consent_id` | — |
| `contract_responses` | `contract_response_id` | `contract_id,person_id` |
| `contract_texts` | `contract_text_id` | `code,valid_from` |
| `contracts` | `contract_id` | — |
| `cost_projects` | `cost_project_id` | `code` |
| `countries` | `country_id` | `code` |
| `denominations` | `denomination_id` | `code` |
| `document_types` | `document_type_id` | `code` |
| `documents` | `document_id` | — |
| `employee_roles` | `employee_role_id` | `employee_id,role_id,school_branch_id` |
| `employees` | `employee_id` | `entra_object_id ; person_id ; work_email` |
| `enrolment_assessments` | `enrolment_assessment_id` | `code` |
| `enrolment_windows` | `enrolment_window_id` | `school_branch_id,target_grade_level,target_school_year` |
| `expense_claim_attachments` | `expense_claim_attachment_id` | `sharepoint_library_id,graph_item_id` |
| `expense_claim_items` | `expense_claim_item_id` | — |
| `expense_claims` | `expense_claim_id` | `calendar_year,claim_number ; expense_claim_id,amount_cents ; expense_claim_id,submitter_employee_id,claim_type,payment_route` |
| `families` | `family_id` | — |
| `family_contacts` | `family_contact_id` | `family_id,person_id` |
| `family_guardians` | `family_guardian_id` | `family_id,person_id` |
| `genders` | `gender_id` | `code` |
| `guardian_relations` | `guardian_relation_id` | `code` |
| `health_trait_types` | `health_trait_type_id` | `code ; health_trait_type_id,needs_permission,is_medication,has_treatment_reason,is_emergency_medication` |
| `health_traits` | `health_trait_id` | — |
| `holiday_bookings` | `holiday_booking_id` | `holiday_booking_id,amount_cents` |
| `holiday_care_notes` | `holiday_care_note_id` | `child_id,holiday_programme_id` |
| `holiday_cost_coverage_codes` | `holiday_cost_coverage_code_id` | — |
| `holiday_module_prices` | `holiday_module_price_id` | `holiday_module_id,valid_from` |
| `holiday_modules` | `holiday_module_id` | `code ; holiday_module_id,holiday_session_type_id` |
| `holiday_programmes` | `holiday_programme_id` | — |
| `holiday_session_days` | `holiday_session_day_id` | `holiday_session_id,day` |
| `holiday_session_surcharges` | `holiday_session_surcharge_id` | `holiday_session_id,holiday_module_id` |
| `holiday_session_types` | `holiday_session_type_id` | `code` |
| `holiday_sessions` | `holiday_session_id` | `holiday_session_id,holiday_session_type_id` |
| `houses` | `house_id` | `code` |
| `kindergarten_recommendations` | `kindergarten_recommendation_id` | `code` |
| `kindergartens` | `kindergarten_id` | `name` |
| `languages` | `language_id` | `code` |
| `ledger_accounts` | `ledger_account_id` | `code` |
| `login_codes` | `login_code_id` | — |
| `meal_prices` | `meal_price_id` | `weekday_count,valid_from` |
| `meal_subscription_days` | `meal_subscription_day_id` | — |
| `meal_subscriptions` | `meal_subscription_id` | — |
| `meal_variants` | `meal_variant_id` | `code` |
| `measles_presentation_types` | `measles_presentation_type_id` | `code` |
| `measles_proofs` | `measles_proof_id` | `child_id` |
| `outbound_emails` | `outbound_email_id` | — |
| `parent_work_entries` | `parent_work_entry_id` | — |
| `payees` | `payee_id` | `name` |
| `payments` | `payment_id` | — |
| `persons` | `person_id` | — |
| `phone_numbers` | `phone_number_id` | — |
| `phone_types` | `phone_type_id` | `code` |
| `previous_schools` | `previous_school_id` | `name` |
| `roles` | `role_id` | `code ; role_id,is_branch_bound` |
| `salutations` | `salutation_id` | `code` |
| `school_branches` | `school_branch_id` | `code ; school_branch_id,first_grade_level,final_grade_level` |
| `school_levels` | `school_level_id` | `code` |
| `sepa_mandates` | `sepa_mandate_id` | `mandate_reference` |
| `sharepoint_libraries` | `sharepoint_library_id` | `code` |
| `signatures` | `signature_id` | — |
| `sync_targets` | `sync_target_id` | `code` |
| `sync_tasks` | `sync_task_id` | — |
| `travel_details` | `travel_detail_id` | `expense_claim_id` |
| `tuition_fees` | `tuition_fee_id` | `school_branch_id,sibling_rank,valid_from` |

### Spaltennamen in mehr als einer Tabelle

109 Namen kommen mehrfach vor. Abgezogen sind die vier Namen, die in fast jeder Tabelle stehen
(`created_at`, `created_by`, `name`, `code`, `is_active` — Audit-Spalten und das Lookup-Muster) und
die reinen Fremdschlüsselnamen (`*_id`, wo die zweite Fundstelle die Zieltabelle selbst ist). Übrig
bleibt die Liste, die einzeln angesehen wurde:

`amount_cents`, `cancelled_at`, `claim_type`, `code_hash`, `confirmed_at`, `day`, `declined_at`,
`description`, `email`, `ends_at_time`, `final_grade_level`, `first_grade_level`, `graph_item_id`,
`has_treatment_reason`, `includes_lunch`, `is_branch_bound`, `is_emergency_medication`, `is_final`,
`is_medication`, `monthly_amount_cents`, `needs_permission`, `note`, `payment_route`, `purpose`,
`registration_closes_at`, `registration_opens_at`, `rejected_at`, `released_at`, `released_by`,
`required_count`, `requires_child`, `school_year`, `source`, `starts_at`, `starts_at_time`,
`target_grade_level`, `target_school_year`, `valid_from`, `valid_until`, `weekday`,
`weekday_count`.

## Der Lauf je Domäne

| Domäne | Tabellen | Funde |
|---|---|---|
| stammdaten | 24 | 2 — N1, N2 |
| querschnitt | 14 | 1 — N3 |
| anmeldung | 20 | 2 — N4, N5 |
| putzdienst | 10 | 0 |
| ferien | 10 | 0 |
| gesundheit | 5 | 0 |
| rechnungsfreigabe | 9 | 0 |
| mensa | 5 | 0 |
| klassenorganisation | 1 | 0 |
| elternbonus | 1 | 0 |
| ags, klassenbildung, m365, selfservice | 0 | 0 |

## Die Funde, nach Gewicht

```
[N4] 3NF · anmeldung · applications.admission_day_id
Folgt aus `admission_day_slot_id` — das Zeitfenster gehört genau einem Tag
(`admission_day_slots.admission_day_id`). Beide stehen nebeneinander an der
Bewerbung, und kein Fremdschlüssel hält sie zusammen: `fk_applications_slot`
greift nur auf das Zeitfenster, `fk_applications_admission_day` bindet den Tag
an *Schulart, Zielstufe und Zielschuljahr* — nicht an das Zeitfenster.
Realer Fall: Für dasselbe Ziel gibt es mehr als einen Anmeldetag — der
Sondertermin ist „der kleinste Anmeldetag" mit einem einzigen Zeitfenster (06).
Wird eine Familie vom regulären Tag auf den Sondertermin umgebucht und dabei nur
`admission_day_slot_id` gesetzt, passt der zusammengesetzte Fremdschlüssel
weiterhin — beide Tage tragen dasselbe Ziel. Die Bewerbung sitzt danach im
Zeitfenster des Sondertermins und zählt am regulären Tag mit: die Einladung
nennt den falschen Tag, `ix_applications_slot` zählt die Plätze des richtigen.
Vorschlag: `UNIQUE (admission_day_slot_id, admission_day_id)` an
`admission_day_slots` und `fk_applications_slot` auf beide Spalten erweitern.
Berührt Stammdaten: nein.
```

```
[N1] 2NF · stammdaten · family_guardians.occupation, .denomination_id, .nationality_country_id
Kandidatenschlüssel ist `(family_id, person_id)` (`uq_family_guardians`); Beruf,
Konfession und Staatsangehörigkeit folgen allein aus `person_id` — sie sind
Angaben über den Menschen, nicht über seine Sorgeberechtigung in dieser einen
Familie. Der halbe Schlüssel genügt, also gehören sie eine Tabelle höher.
Realer Fall: „Familie heißt die Eltern, nicht der Haushalt" (hebel.md) — ein
Vater mit Kindern aus zwei Beziehungen, beide an der Schule, ist Zeile in zwei
`families`. Sein Berufswechsel wird über den Selfservice an einer der beiden
Zeilen gepflegt; die andere trägt weiter den alten Beruf, und welche der beiden
Konfessionen an ASV-BW geht, entscheidet der Join.
Vorschlag: die drei Spalten an `persons` (bzw. an eine personenweite
Sorgeberechtigten-Zeile), `family_guardians` behält Verhältnis, Einsichtsstufe
und Postflag.
Berührt Stammdaten: ja.
```

```
[N5] 3NF · anmeldung · contracts.child_id (beim Schulvertrag)
Folgt aus `application_id` — `applications.child_id` ist NOT NULL, und ein
Schulvertrag hat immer eine Bewerbung (`ck_contracts_application`).
`fk_contracts_application` ist einspaltig und hält die beiden nicht zusammen,
obwohl dieselbe Datei denselben Fall zweimal ausdrücklich absichert
(`fk_children_class`, `fk_applications_admission_day`).
Realer Fall: Zwillinge sind zwei Bewerbungen und zwei Verträge mit demselben
Ziel, derselben Familie und demselben Vertragstext („Zwillinge sind zwei
Verträge"). Wird beim Erzeugen des zweiten Vertrags die Bewerbung des
Geschwisters verknüpft, geht das durch — und der Lösch-Lauf bleibt danach in
Stufe 1 an `fk_contracts_application` stehen, weil er den Vertrag beim einen
Kind sucht und die Bewerbung beim anderen hängt.
Vorschlag: `UNIQUE (application_id, child_id)` an `applications` und
`fk_contracts_application` auf beide Spalten erweitern; für den Hortvertrag
bleibt `child_id` allein stehen, wie heute.
Berührt Stammdaten: nein.
```

```
[N2] 3NF · stammdaten · sepa_mandates.credit_institution
Folgt aus `iban` — die Bankleitzahl in den Stellen 5–12 bestimmt das Institut;
die Spalte trägt keinen Kommentar, der sagt, dass hier bewusst der Name von
damals festgehalten wird.
Realer Fall: Zwei Kinder einer Familie ziehen vom selben Konto und haben je ein
eigenes Mandat (grenzkarte.md, „ein Mandat je Kind"). Beide werden von Hand
erfasst, das zweite ein Jahr später — dieselbe IBAN steht dann einmal unter
„Volksbank Musterstadt" und einmal unter „VoBa Musterstadt eG".
Vorschlag: den Satz ans Feld schreiben, dass der Name der zum
Unterschriftszeitpunkt genannte ist und nicht nachgeführt wird — dann ist er
eine festgehaltene Tatsache und keine vergessene Ableitung.
Berührt Stammdaten: ja.
```

```
[N3] 3NF · querschnitt · payments.amount_cents (drei der vier Anlässe)
Bei der Ferienbuchung hält `fk_payments_holiday_booking` den Betrag an seiner
Quelle fest (`holiday_bookings.amount_cents`) — bei den drei anderen Anlässen
hält ihn nichts, und die Spalte trägt keinen Kommentar. Der Freikauf folgt aus
`configured_values('cleaning_buyout_cents')`, die Bearbeitungsgebühr aus
`('application_fee_cents')`, beide je zum Gültigkeitstag. Ob der Betrag hier
bewusst der von damals ist oder eine vergessene Ableitung, ist an der Zeile
nicht ablesbar.
Realer Fall: kein Auseinanderlaufen — `configured_values` ist nach Erreichen des
Gültigkeitstags unveränderlich, und die drei Anlässe haben keinen zweiten Ort.
Der Fund ist die stumme Abweichung, nicht die Redundanz: die Asymmetrie zum
vierten Anlass liest sich wie ein vergessener Fremdschlüssel.
Vorschlag: ein Satz an `amount_cents`, dass der Betrag der zur Zahlung gültige
ist und für die Ferienbuchung zusätzlich am Buchungsbetrag hängt.
Berührt Stammdaten: nein.
```

## Angesehen, nicht als Fund gewertet

**stammdaten**

- `countries.nationality_name` folgt nicht aus `name`: „Deutschland" gäbe „deutschländisch", die
  Bezeichnung ist eine eigene Tatsache.
- `children.first_grade_level`/`.final_grade_level`, `employee_roles.is_branch_bound` — mitgeführt
  mit zusammengesetztem Fremdschlüssel (`fk_children_branch` MATCH FULL, `fk_employee_roles_role`),
  entschieden in `rules.md` §1.
- `children.grade_level` neben `class_id`: die Klasse trägt nur `start_school_year`, die Stufe wird
  aus ihr *und dem laufenden Datum* gerechnet — kein Bestimmungsmerkmal in derselben Zeile. Der
  Wiederholer (`repeats_grade_school_year`) macht die beiden zudem echt unabhängig.
- `login_codes.email` neben `persons.email`: bei `purpose = 'email_confirmation'` ist sie
  ausdrücklich die *neue*, noch nicht gültige Adresse — der Kommentar am Feld sagt es.
- `sepa_mandates.account_holder_name`/`_address_id`/`_email` neben `persons`:
  `ck_sepa_mandates_holder` und `ck_sepa_mandates_holder_contact` lassen die Spalten nur füllen, wo
  keine Person aus dem Bestand dahintersteht — es gibt keine Zeile mit beidem.
- `family_guardians.access_level_id` hängt wie N1 am halben Schlüssel („Die Stufe hängt an der
  Person", hebel.md), aber der Beschluss dahinter betrifft real die Kinder einer Familie und nicht
  den Menschen im Ganzen. Wird N1 umgesetzt, ist sie mitzuentscheiden.
- `children.exit_reason` als Freitext: 1NF-tauglich, weil nichts daraus ausgewertet wird — Block 03
  verlangt den Satz als Angabe, nicht als Verpackung. Ebenso `contracts.end_reason`,
  `holiday_sessions.cancellation_reason`, `expense_claims.voided_reason`.
- `family_contacts.relationship`, `.is_emergency_contact`, `.is_pickup_authorised` hängen an beiden
  Schlüsselteilen: „Oma" ist die Beziehung zu *diesen* Kindern, die Abholberechtigung gilt *dieser*
  Familie.

**querschnitt**

- `consents.requires_child` steht auch an `consent_purposes` — `fk_consents_purpose` hält beide
  zusammen, entschieden in `rules.md` §1.
- `consents.delivery_address` und `outbound_emails.recipient_email`: festgehaltene Tatsachen, beide
  mit dem Satz am Feld, der genau das sagt.
- `payments.status` folgt vollständig aus `confirmed_at` — `ck_payments_confirmed` bindet beide in
  derselben Zeile, und weiter als bis zur eigenen Zeile muss der CHECK hier nicht sehen. Dasselbe
  Muster an `sync_tasks` (`completed_at`/`outcome`/`completed_by`) und `documents`
  (`graph_item_id`/`filed_at`).
- `change_log.person_id`/`.child_id`/`.family_id` folgen aus `(table_name, row_id)` — aber genau
  dieses Paar trägt keinen Fremdschlüssel, mit dem der Lösch-Lauf die Zeile fände. Der Kommentar
  schreibt den Preis aus.
- `documents.sharepoint_library_id` neben `document_types`: bewusst an der Datei statt an ihrer Art,
  „käme die Trennung nach Bibliotheken je zurück, wäre das eine Datenänderung statt einer
  Migration".
- `signatures` trägt bewusst keine Fassungsspalte — sie steht an `contracts.contract_text_id`, der
  Kommentar nennt den ableitbaren Wert beim Namen.
- `configured_values` und `contract_texts`: Schlüssel ist `(code, valid_from)`, der Wert hängt an
  beiden Teilen — kein 2NF-Fall.

**anmeldung**

- `applications.is_final` (→ `application_statuses`), `applications`/`admission_days`/
  `enrolment_windows`.`first_grade_level`/`.final_grade_level` (→ `school_branches`),
  `applications.admission_day_id` samt Ziel (→ `admission_days`): alle mit zusammengesetztem
  Fremdschlüssel, entschieden in `rules.md` §1.
- `applications.school_branch_id` neben `children.school_branch_id`: das Ziel *dieser* Bewerbung
  gegen die heutige Schulart des Kindes — der Viertklässler in die eigene Realschule hat beide
  gleichzeitig verschieden (04).
- `applications.released_at` / `admission_days.released_at` / `contracts.released_at`: drei
  verschiedene Freigaben, gleicher Name.
- `applications.care_need_level_id` setzt `care_interest IS TRUE` voraus — der CHECK hält beide in
  derselben Zeile, „ein Umfang ohne Bedarf wäre der zweite Ort für dieselbe Tatsache".
- `admission_day_slots.places_override` leer = „es gilt die Zahl des Tages": genau die vermiedene
  Kopie.
- `contracts.contract_text_id` und `.document_checksum`: festgehaltene Tatsachen, beide mit dem Satz
  am Feld („Die Fassung friert mit der Zusage ein", „damit sich jede spätere Abweichung zeigt").
- `care_module_prices` und `tuition_fees`: der Betrag hängt an allen Schlüsselteilen
  (Modul × Tageszahl × Datum bzw. Schulart × Rang × Datum) — kein 2NF-Fall. Der Geschwisterrang
  steht bewusst nicht am Kind, er wird beim Lesen gerechnet.

**putzdienst**

- `cleaning_slot_type_id` steht an fünf Tabellen — an `cleaning_assignments`,
  `cleaning_swap_offers` und `cleaning_swap_acceptances` je mit zusammengesetztem
  Fremdschlüssel auf den Termin bzw. das Angebot; an `cleaning_cycle_quotas` und
  `cleaning_family_quotas` ist er Schlüsselteil und nicht mitgeführt.
- `cleaning_slots.capacity_override` und `cleaning_cycle_quotas.default_capacity`: die Ausnahme
  steht am Termin, der Standard am Zyklus — leer heißt „es gilt der Standard", keine Kopie.
- `cleaning_buyouts` trägt bewusst keinen Betrag („er steckt in der Zahlung … beides zweimal zu
  führen ließe sie auseinanderlaufen"), `cleaning_swap_offers` bewusst kein Ablaufdatum (folgt aus
  dem Termin), `cleaning_slot_buyouts` bewusst keine Frist (fest, drei Tage).
- `cleaning_assignments.no_show` folgt nicht aus `cleaning_slots.attendance_recorded_at`: das ist
  der dritte Zustand, ohne den „false" auch „noch nicht ausgewertet" hieße.
- Der Zyklus einer Zuteilung wird nicht mitgeführt — er hängt am Termin und wird von dort gelesen.

**ferien**

- `holiday_bookings.holiday_session_type_id` ist ausdrücklich nur zur Bindung da und hängt an zwei
  zusammengesetzten Fremdschlüsseln (`…_session`, `…_module`); `amount_cents` hängt zusätzlich am
  Zahlungs-Fremdschlüssel und trägt den Satz „was an diesem Tag galt".
- `holiday_care_notes` steht je Kind **und Programm** statt an der Buchung — der Kommentar rechnet
  den vermiedenen Fall vor: „ein Kind, das eine Ferienwoche bucht, trüge dieselbe Anmerkung
  fünfmal".
- `holiday_cost_coverage_codes` trägt bewusst weder `expires_at` noch `redeemed_at`: beides folgt
  aus `created_at` bzw. aus der Buchung, die auf den Code zeigt.

**gesundheit**

- `health_traits.needs_permission`, `.is_medication`, `.has_treatment_reason`,
  `.is_emergency_medication` stehen auch an `health_trait_types` — `fk_health_traits_type` hält alle
  fünf Spalten zusammen; die beiden Sicht-Flags (`is_everyday_relevant`, `is_kitchen_relevant`)
  stehen bewusst *nicht* im Schlüssel, weil sie keine Spalte steuern.
- `health_traits.has_certificate` folgt nicht aus `certificate_document_id`: „ob ein Attest vorlag"
  ist auch wahr, wo das Blatt gezeigt und wieder mitgenommen wurde. Die Gegenrichtung hält
  `ck_health_traits_certificate`.
- `measles_proofs` und `child_health_records` tragen je Kind eine Zeile (`uq_…`); alle
  Nicht-Schlüsselspalten hängen am Kind.

**rechnungsfreigabe**

- `expense_claim_items.submitter_employee_id`/`.claim_type`/`.payment_route` und
  `travel_details.amount_cents`: mitgeführt **mit** zusammengesetztem Fremdschlüssel — beide
  Kommentare rechnen vor, was ohne sie durchginge („9.999,99 € über 1 km").
- `expense_claims.calendar_year` folgt aus `created_at` — und `ck_expense_claims_calendar_year`
  bindet es daran, samt fest verdrahteter Zeitzone. Genau die Bauform, die dieser Lauf sucht.
- `expense_claims.submitter_employee_name` / `expense_claim_items.approver_employee_name`:
  festgehaltene Tatsachen mit dem Satz am Feld („Der Beleg überlebt seinen Einreicher"), und der
  CHECK erzwingt, dass immer genau eine der beiden Formen dasteht.
- `expense_claim_items.amount_cents` neben `expense_claims.amount_cents`: der Teilbetrag ist keine
  Kopie, sondern der Anteil — bei einem ungeteilten Beleg fallen sie zusammen, bei einer Aufteilung
  nicht. Dass die Summe trifft, prüft ausdrücklich die Anwendung.
- `expense_claim_items.cost_project_id`/`.ledger_account_id` sind der aus der Vorlage kopierte
  Stand, nicht die Vorlage selbst — „Eine geänderte Vorlage gilt ab dem nächsten Beleg", und die
  Führungskraft darf sie ändern.

**mensa**

- `meal_subscriptions` trägt bewusst kein Schuljahr — es folgt aus `starts_on`, und der EXCLUDE
  rechnet ohnehin über den Zeitraum.
- `meal_prices` hat den Schlüssel `(weekday_count, valid_from)`, der Betrag hängt an beiden;
  dieselbe Staffel trägt das Hortessen, ohne zweite Liste.
- `child_meal_profiles` je Kind eine Zeile, fehlende Zeile = „isst alles" — kein Vorgabewert, der
  neben der Werteliste stünde.
- `meal_subscription_days.valid_from`/`.valid_until` stehen am Tag und nicht am Abo, weil Tage im
  laufenden Jahr kommen und gehen; am Abo wäre es der falsche Schlüssel.

**elternbonus, klassenorganisation**

- `parent_work_entries.school_year` folgt aus `worked_on` — `ck_parent_work_entries_school_year`
  rechnet es nach; `confirming_employee_name` ist die festgehaltene Tatsache mit ihrem Satz am Feld.
- `class_representatives`: Schlüssel `(class_id, school_year, person_id)`, keine
  Nicht-Schlüsselspalte außer den Audit-Spalten. Nichts zu prüfen.

**Nicht diese Frage, aber beim Lesen aufgefallen** — gehört in `prompts/schema-pruefen.md`, nicht
hierher:

- `holiday_session_surcharges` bindet Modul und Termin **nicht** an dieselbe Terminart, obwohl
  `holiday_bookings` daneben genau dafür `holiday_session_type_id` mitführt.
- `holiday_session_types.cancellation_terms_code` verweist auf `contract_texts.code` ohne
  Fremdschlüssel — dort ist `code` allein nicht eindeutig, ein Fremdschlüssel wäre also erst nach
  einem zweiten Schlüssel möglich.

## Das Ganze

**Ja, mit einer Ausnahme: Das Schema ist in 3NF, sobald N1 geschlossen ist** — die einzige
Abweichung mit zwei Orten für dieselbe Tatsache, die im Betrieb auseinanderlaufen können.
N4 und N5 sind keine Redundanz, sondern zwei fehlende Bindungen: der Wert steht je einmal, aber
nichts hält ihn an seiner Quelle, und das Schema sichert denselben Fall an neunzehn anderen Stellen
ab. N2 und N3 sind stumme Abweichungen — richtig gebaut, aber ohne den Satz am Feld, der sagt,
dass sie Absicht sind.

Zehn Domänen mit Tabellen, sieben davon ohne Fund: putzdienst, ferien, gesundheit,
rechnungsfreigabe, mensa, klassenorganisation und elternbonus. Vier Dateien tragen keine Tabellen
und damit keine Frage.

1NF ist über alle 99 Tabellen erfüllt: kein Feld trägt eine Liste, und die vier Freitexte, aus
denen etwas herausgelesen werden könnte (`children.exit_reason`, `contracts.end_reason`,
`holiday_sessions.cancellation_reason`, `expense_claims.voided_reason`), werden von keinem Prozess
ausgewertet — der Block verlangt den Satz als Angabe. BCNF: keine Abweichung, die einen realen Fall
erzeugt; die Tabellen mit mehr als einem Kandidatenschlüssel (`children`, `employees`,
`expense_claims`, `school_branches`, `roles`, `classes`, `application_statuses`, `consent_purposes`,
`health_trait_types`, `holiday_modules`, `holiday_sessions`, `cleaning_slots`,
`cleaning_assignments`, `cleaning_swap_offers`) tragen ihren zweiten Schlüssel ausnahmslos als
Träger eines zusammengesetzten Fremdschlüssels, und der überlappt den Primärschlüssel vollständig
statt teilweise.
