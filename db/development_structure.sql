CREATE TABLE "adverse_event_columns" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "header" varchar(255), "name" varchar(255), "description" varchar(255), "extraction_form_id" integer, "study_id" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "adverse_event_results" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "column_id" integer, "value" varchar(255), "notes" varchar(255), "adverse_event_id" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "adverse_event_template_settings" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "extraction_form_id" integer, "display_arms" boolean, "display_total" boolean, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "adverse_events" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "study_id" integer, "extraction_form_id" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "arms" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "study_id" integer, "title" varchar(255), "description" text, "num_participants" integer, "display_number" integer, "extraction_form_id" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "baseline_characteristic_data_points" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "baseline_characteristic_field_id" integer, "value" varchar(255), "notes" text, "study_id" integer, "extraction_form_id" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "baseline_characteristic_fields" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "baseline_characteristic_id" integer, "option_text" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE TABLE "baseline_characteristics" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "question" varchar(255), "field_type" varchar(255), "extraction_form_id" integer, "field_notes" varchar(255), "question_number" integer, "study_id" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "default_adverse_event_columns" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "header" varchar(255), "name" varchar(255), "description" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE TABLE "default_design_details" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "title" varchar(255), "notes" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE TABLE "default_outcome_columns" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "column_name" varchar(255), "column_description" text, "column_header" varchar(255), "outcome_type" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE TABLE "default_outcome_comparison_columns" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "column_name" varchar(255), "column_description" varchar(255), "column_header" varchar(255), "outcome_type" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE TABLE "default_quality_rating_fields" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "rating_item" varchar(255), "display_number" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "design_detail_data_points" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "design_detail_field_id" integer, "value" varchar(255), "notes" varchar(255), "study_id" integer, "extraction_form_id" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "design_detail_fields" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "design_detail_id" integer, "option_text" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE TABLE "design_details" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "question" varchar(255), "extraction_form_id" integer, "field_type" varchar(255), "field_note" varchar(255), "question_number" integer, "study_id" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "extraction_form_outcome_names" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "title" varchar(255), "note" varchar(255), "extraction_form_id" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "extraction_form_sections" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "extraction_form_id" integer, "section_name" varchar(255), "included" boolean, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "extraction_forms" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "title" varchar(255), "creator_id" integer, "notes" text, "adverse_event_display_arms" boolean DEFAULT 't', "adverse_event_display_total" boolean DEFAULT 't', "created_at" datetime, "updated_at" datetime);
CREATE TABLE "feedback_items" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "url" varchar(255), "page" varchar(255), "description" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE TABLE "footnote_fields" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "study_id" integer, "footnote_number" integer, "field_name" varchar(255), "page_name" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE TABLE "footnotes" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "note_number" integer, "study_id" integer, "page_name" varchar(255), "data_type" varchar(255), "note_text" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE TABLE "key_questions" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "project_id" integer, "question_number" integer, "question" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE TABLE "locked_extraction_form_sections" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "extraction_form_id" integer, "study_id" integer, "section_name" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE TABLE "notifiers" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "outcome_columns" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "column_header" varchar(255), "outcome_type" varchar(255), "column_name" varchar(255), "column_description" varchar(255), "extraction_form_id" integer, "study_id" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "outcome_comparison_columns" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "column_header" varchar(255), "outcome_type" varchar(255), "column_name" varchar(255), "column_description" varchar(255), "extraction_form_id" integer, "study_id" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "outcome_comparison_results" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "arm_id" integer, "outcome_id" integer, "timepoint_id" integer, "outcome_comparison_column_id" integer, "is_calculated" boolean, "value" varchar(255), "extraction_form_id" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "outcome_comparisons" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "arm_id" integer, "outcome_id" integer, "timepoint_id" integer, "outcome_comparison_column_id" integer, "is_calculated" boolean, "value" varchar(255), "extraction_form_id" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "outcome_results" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "arm_id" integer, "outcome_id" integer, "timepoint_id" integer, "outcome_column_id" integer, "is_calculated" boolean, "value" varchar(255), "extraction_form_id" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "outcome_timepoints" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "outcome_id" integer, "number" integer, "time_unit" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE TABLE "outcomes" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "study_id" integer, "title" varchar(255), "is_primary" boolean, "units" varchar(255), "description" text, "notes" text, "outcome_type" varchar(255), "extraction_form_id" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "primary_publication_numbers" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "primary_publication_id" integer, "number" varchar(255), "number_type" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE TABLE "primary_publications" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "study_id" integer, "title" varchar(255), "author" varchar(255), "country" varchar(255), "year" varchar(255), "pmid" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE TABLE "projects" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "title" varchar(255), "description" text, "notes" text, "funding_source" varchar(255), "creator_id" integer, "is_public" boolean DEFAULT 'f', "created_at" datetime, "updated_at" datetime);
CREATE TABLE "publication_numbers" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "publication_id" integer, "number" varchar(255), "number_type" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE TABLE "publications" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "study_id" integer, "title" varchar(255), "author" varchar(255), "country" varchar(255), "year" varchar(255), "association" varchar(255), "display_number" integer, "extraction_form_id" integer, "pmid" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE TABLE "quality_dimension_data_points" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "quality_dimension_field_id" integer, "value" varchar(255), "notes" text, "study_id" integer, "field_type" varchar(255), "extraction_form_id" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "quality_dimension_fields" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "title" varchar(255), "field_notes" text, "extraction_form_id" integer, "study_id" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "quality_rating_data_points" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "study_id" integer, "guideline_used" varchar(255), "current_overall_rating" varchar(255), "notes" text, "extraction_form_id" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "quality_rating_fields" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "extraction_form_id" integer, "rating_item" varchar(255), "display_number" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "quality_ratings" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "study_id" integer, "guideline_used" varchar(255), "current_overall_rating" varchar(255), "notes" text, "extraction_form_id" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "schema_migrations" ("version" varchar(255) NOT NULL);
CREATE TABLE "secondary_publication_numbers" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "secondary_publication_id" integer, "number" varchar(255), "number_type" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE TABLE "secondary_publications" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "study_id" integer, "title" varchar(255), "author" varchar(255), "country" varchar(255), "year" varchar(255), "association" varchar(255), "display_number" integer, "extraction_form_id" integer, "pmid" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE TABLE "sticky_note_replies" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "note_id" integer, "user_id" integer, "note_text" varchar(255), "is_public" boolean DEFAULT 'f', "created_at" datetime, "updated_at" datetime);
CREATE TABLE "sticky_notes" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "project_id" integer, "study_id" integer, "extraction_form_id" integer, "user_id" integer, "note_text" text, "page_name" varchar(255), "is_public" boolean, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "studies" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "title" varchar(255), "project_id" integer, "study_type" varchar(255), "creator_id" integer, "extraction_form_id" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "studies_key_questions" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "study_id" integer, "key_question_id" integer, "extraction_form_id" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "study_extraction_form_sections" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "study_id" integer, "extraction_form_id" integer, "section_name" varchar(255), "progress" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE TABLE "study_extraction_forms" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "study_id" integer, "extraction_form_id" integer, "notes" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE TABLE "study_key_questions" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "study_id" integer, "key_question_id" integer, "extraction_form_id" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "user_project_roles" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "project_id" integer, "role" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE TABLE "users" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "login" varchar(255) NOT NULL, "email" varchar(255) NOT NULL, "fname" varchar(255) NOT NULL, "lname" varchar(255) NOT NULL, "organization" varchar(255) NOT NULL, "user_type" varchar(255) NOT NULL, "crypted_password" varchar(255) NOT NULL, "password_salt" varchar(255) NOT NULL, "persistence_token" varchar(255) NOT NULL, "login_count" integer DEFAULT 0 NOT NULL, "failed_login_count" integer DEFAULT 0 NOT NULL, "last_request_at" datetime, "current_login_at" datetime, "last_login_at" datetime, "current_login_ip" varchar(255), "last_login_ip" varchar(255), "perishable_token" varchar(255) DEFAULT '' NOT NULL, "created_at" datetime, "updated_at" datetime);
CREATE UNIQUE INDEX "index_users_on_email" ON "users" ("email");
CREATE UNIQUE INDEX "index_users_on_login" ON "users" ("login");
CREATE INDEX "index_users_on_perishable_token" ON "users" ("perishable_token");
CREATE UNIQUE INDEX "index_users_on_persistence_token" ON "users" ("persistence_token");
CREATE UNIQUE INDEX "unique_schema_migrations" ON "schema_migrations" ("version");
INSERT INTO schema_migrations (version) VALUES ('20110323190423');

INSERT INTO schema_migrations (version) VALUES ('20110131144325');

INSERT INTO schema_migrations (version) VALUES ('20110131144754');

INSERT INTO schema_migrations (version) VALUES ('20110131183845');

INSERT INTO schema_migrations (version) VALUES ('20110201180515');

INSERT INTO schema_migrations (version) VALUES ('20110201180544');

INSERT INTO schema_migrations (version) VALUES ('20110208154234');

INSERT INTO schema_migrations (version) VALUES ('20110211211053');

INSERT INTO schema_migrations (version) VALUES ('20110211212017');

INSERT INTO schema_migrations (version) VALUES ('20110211213319');

INSERT INTO schema_migrations (version) VALUES ('20110211220148');

INSERT INTO schema_migrations (version) VALUES ('20110214182336');

INSERT INTO schema_migrations (version) VALUES ('20110216185746');

INSERT INTO schema_migrations (version) VALUES ('20110217173503');

INSERT INTO schema_migrations (version) VALUES ('20110217212926');

INSERT INTO schema_migrations (version) VALUES ('20110218185723');

INSERT INTO schema_migrations (version) VALUES ('20110218210409');

INSERT INTO schema_migrations (version) VALUES ('20110218211614');

INSERT INTO schema_migrations (version) VALUES ('20110218211901');

INSERT INTO schema_migrations (version) VALUES ('20110222153916');

INSERT INTO schema_migrations (version) VALUES ('20110303175227');

INSERT INTO schema_migrations (version) VALUES ('20110303184236');

INSERT INTO schema_migrations (version) VALUES ('20110314201039');

INSERT INTO schema_migrations (version) VALUES ('20110314201713');

INSERT INTO schema_migrations (version) VALUES ('20110317190611');

INSERT INTO schema_migrations (version) VALUES ('20110321171647');

INSERT INTO schema_migrations (version) VALUES ('20110323172046');

INSERT INTO schema_migrations (version) VALUES ('20110323182930');