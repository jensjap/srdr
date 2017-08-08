Srdr::Application.routes.draw do

  get "search_registry" => "registry_usage#search_registry"

    root :to => 'home#index'

    resources :ef_instructions

    resources :comments

    resources :extraction_forms, :study_extraction_forms, :extraction_form_arms, :extraction_form_diagnostic_tests, :extraction_form_adverse_events
    resources :extraction_form_sections, :study_extraction_form_sections
    resources :users, :password_resets,  :user_project_roles, :user_sessions
    resources :quality_rating_fields, :quality_rating_data_points
    resources :adverse_events, :adverse_event_results, :adverse_event_columns
    resources :design_details, :design_detail_fields, :design_detail_data_points
    resources :primary_publications, :primary_publication_numbers, :secondary_publications, :secondary_publication_numbers
    resources :outcome_comparison_results, :outcome_comparison_columns
    resources :quality_dimension_fields, :quality_dimension_data_points
    resources :baseline_characteristics, :baseline_characteristic_fields, :baseline_characteristic_data_points
    resources :arm_details, :arm_detail_fields, :arm_detail_data_points
    resources :outcome_details, :outcome_detail_fields, :outcome_detail_data_points
    resources :quality_details, :quality_detail_fields, :quality_detail_data_points
    resources :diagnostic_test_details, :diagnostic_test_detail_fields, :diagnostic_test_detail_data_points
    resources :arms, :diagnostic_tests
    resources :outcomes, :outcome_columns, :outcome_results, :outcome_timepoints, :extraction_form_outcome_names
    resources :key_questions, :studies_key_questions
    resources :outcome_measures, :outcome_data_points
    resources :comparisons

    resources :studies do
        resources :arms
        get 'data'
        get 'edit_split' => 'studies#edit_split'
    end

    resources :feedback_items

    get "home/index"
    get "user_sessions/new"
    get "primary_publications/get_pubmed_data"
    # ---------- not sure if needed [MK] ---------------
    #get "adv_search/index"

    resource :account, :controller => "users"

    # ---------- New Audit trail support ---------------
    get "audit_trails/new"

    # ---------- DAA Info page ------------
    get  "daa/info"                => "daa_info#info"
    get  "daa/eligibility"         => "daa_info#eligibility"
    get  "daa/not_eligible"        => "daa_info#not_eligible"
    post "daa/eligible"            => "daa_info#eligible"
    post "daa/create_participant"  => "daa_info#create"

    # --------- DAA Consent form ----------
    get  "daa/consent"      => "daa_info#consent"
    get  "daa/thanks"       => "daa_info#consent_thanks"
    get  "daa/consent_form" => "daa_info#consent_form"
    post "daa/consent"      => "daa_info#consent_submit"

    # ---------- EPC Questionnaire ----------
    get "questionnaire/form" => "bryant_form#form"
    post "questionnaire/save" => "bryant_form#save"

    # hiding the ahrq header
    match '/application/go_full_screen' => 'application#toggle_ahrq_header'

    # used for adding and removing extraction forms to and from studies
    match 'projects/published' => 'projects#published'
    match 'home/quarterly_training'
    match 'home/external_resources'
    match 'register' => 'users#new'
    # MK Registration confirmation re-directs -----------------------------------------------
    match 'register/confirmation' => 'users#confirmation'
    match 'register/reviewconfirmation' => 'users#reviewconfirmation'
    match 'register/error' => 'users#error'
    match 'register/agreement_error' => 'users#agreement_error'
    match 'account/validation.html' => 'users#validateuser'
    # MK Registration confirmation re-directs -----------------------------------------------
    match 'projects/:project_id/studies/extraction_form_add' => 'studies#extraction_form_add'
    match 'projects/:project_id/studies/extraction_form_remove' => 'studies#extraction_form_remove'
    match 'projects/:project_id/studies/:id/extraction_form_add' => 'studies#extraction_form_add_edit'
    match 'projects/:project_id/studies/:id/extraction_form_remove' => 'studies#extraction_form_remove_edit'
    match 'projects/:id/extraction_forms' => 'projects#extractionforms'
    match 'projects/:project_id/extraction_forms/new' => 'extraction_forms#new'
    match 'projects/:project_id/extraction_forms/arms' => 'extraction_forms#new'
    match 'projects/:project_id/extraction_forms/:id' => 'extraction_forms#show'
    match 'projects/:project_id/extraction_forms/:extraction_form_id/import' => 'extraction_form_section_copies#import_from_previous_forms'
    match 'extraction_form_section_copies/save_import_request'

    match 'projects/:id/studies' => 'projects#studies'
    match 'projects/:id/users' => 'projects#users'
    match 'projects/:id/review' => 'projects#review'
    match 'projects/:id/publish' => 'projects#publish'
    #------------------------------------------------------------------------------------------------------------------------------------
    # [MK] 20120204 - added support for table creator
    #------------------------------------------------------------------------------------------------------------------------------------
    match 'projects/tablecreator' => 'tablecreator#index'
    match 'tablecreator/buildtable' => 'tablecreator#buildtable'
    match 'tablecreator/templatemanager' => 'tablecreator#templatemanager'
    match 'projects/tablecreator/templatemanager' => 'tablecreator#templatemanager'
    #------------------------------------------------------------------------------------------------------------------------------------
    # [MK] 20121004 - added support for export tools
    #------------------------------------------------------------------------------------------------------------------------------------
    match 'projects/exporttools' => 'exporttools#index'
    match 'projects/exporttools/simpleexport' => 'exporttools#simpleexport'
    match 'projects/exporttools/advexport' => 'exporttools#advexport'
    match 'projects/exporttools/reportbuilder' => 'exporttools#reportbuilder'
    #------------------------------------------------------------------------------------------------------------------------------------
    # [MK] 20120316 - added support for comparing studies - aka double extraction
    #------------------------------------------------------------------------------------------------------------------------------------
    match 'projects/:id/create_consensus' => 'studyconsensus#createconsensus'
    match 'comparestudies/create_consensus' => 'studyconsensus#createconsensus'
    match '/compexporter/saveas_excel/:project_id'=>'studyconsensus#export_to_excel'

    # used for adding extraction forms to project key questions
    #match 'extraction_forms/assign_key_questions' => 'extraction_forms#assign_key_questions'
    resources :projects do
        resources :studies do
            resources :arms, :secondary_publications, :primary_publications
            resources :extraction_forms do
                resources :outcome_measures do
                    post :edit, :save, :cancel
                    delete :destroy
                end
                resources :outcome_timepoints do
                    post :edit, :save, :cancel
                    delete :destroy_modal
                    delete :destroy
                end
            end
        end
        resources :extraction_forms
        resources :key_questions
    end

    match 'forgot_password' => 'password_resets#new'

    match 'projects/cancel_new' => 'projects#cancel_new'
    # match 'projects/:id/studies' => 'studies#index'

    match 'projects/:project_id/extraction_forms/:extraction_form_id/preview' => 'extraction_forms#preview'

    # copy a project
    match 'projects/show_copy_form'
    match 'projects/show_copy_request_form'
    match 'projects/request_a_copy'
    match 'projects/copy'
    match 'projects/:project_id/remove_parent_association' => 'projects#remove_parent_association'

    # key questions routes
    match 'key_questions/new' => 'key_questions#new'
    match 'key_questions/show' => 'key_questions#show'
    match 'key_questions/hide' => 'key_questions#hide'
    match 'projects/new/key_questions/show' => 'key_questions#show'
    match 'projects/new/key_questions/new' => 'key_questions#new'
    match 'projects/:project_id/key_questions/show' => 'key_questions#show'
    match 'projects/new/key_questions/:key_question_id/edit' => 'key_questions#edit'

    # getting comment content for all pages
    match 'projects/get_comment_content' => 'comments#show'
    match 'projects/:project_id/get_comment_content' => 'comments#show'
    match 'projects/:project_id/studies/:study_id/get_comment_content' => 'comments#show'
    match 'projects/:project_id/studies/:study_id/extraction_forms/:extraction_form_id/get_comment_content' => 'comments#show'

    match 'projects/get_comment_summary' => 'comments#show_summary'
    match 'get_comment_summary' => 'comments#show_summary'

    # getting comment form from all pages
    match 'projects/get_comment_form' => 'comments#new'
    match 'projects/:project_id/get_comment_form' => 'comments#new'
    match 'projects/:project_id/studies/:study_id/get_comment_form' => 'comments#new'
    match 'projects/:project_id/studies/:study_id/extraction_forms/:extraction_form_id/get_comment_form' => 'comments#new'

    # getting flag form from all pages
    match 'projects/get_flag_form' => 'comments#new_flag'
    match 'projects/:project_id/get_flag_form' => 'comments#new_flag'
    match 'projects/:project_id/studies/:study_id/get_flag_form' => 'comments#new_flag'
    match 'projects/:project_id/studies/:study_id/extraction_forms/:extraction_form_id/get_flag_form' => 'comments#new_flag'

    # showing reply form from all pages
    match 'projects/show_reply_form' => 'comments#show_reply_form'
    match 'projects/:project_id/show_reply_form' => 'comments#show_reply_form'
    match 'projects/:project_id/studies/:study_id/show_reply_form' => 'comments#show_reply_form'
    match 'projects/:project_id/studies/:study_id/extraction_forms/:extraction_form_id/show_reply_form' => 'comments#show_reply_form'

    # deleting comment from all pages
    match 'projects/delete_comment' => 'comments#remove'
    match 'projects/:project_id/delete_comment' => 'comments#remove'
    match 'projects/:project_id/studies/:study_id/delete_comment' => 'comments#remove'
    match 'projects/:project_id/studies/:study_id/extraction_forms/:extraction_form_id/delete_comment' => 'comments#remove'

    match 'sort_comments' => 'comments#sort'
    match 'sort_summary_comments' => 'comments#summary_sort'
    match 'projects/sort_summary_comments' => 'comments#summary_sort'
    match 'go_to_edit_section' => 'comments#go_to_edit_section'
    match 'go_to_view_section' => 'comments#go_to_view_section'
    match 'projects/go_to_edit_section' => 'comments#go_to_edit_section'
    match 'projects/go_to_view_section' => 'comments#go_to_view_section'

    # THESE ARE PART OF TESTING THE COMPARISON SETUP
    match 'projects/:project_id/studies/:study_id/extraction_forms/:extraction_form_id/update_partial' => 'studies#update_partial'
    match 'projects/:project_id/studies/:study_id/extraction_forms/:extraction_form_id/clear_table' => 'outcome_results#clear_table'
    match 'projects/:project_id/studies/:study_id/extraction_forms/:extraction_form_id/comparisons/clear_table' => 'outcome_comparison_results#clear_table'
    match 'projects/:project_id/moveup' => 'projects#moveup'
    match 'projects/:project_id/render_new_partial' => 'application#render_new_partial'

    match 'primary_publications/get_pubmed_data' => 'primary_publications#get_pubmed_data'
    # MK ----------- new Primary Publication Identifiers form --------------------
    match 'primary_publications/update_ppi' => 'primary_publications#update_ppi'
    # MK ----------- new Primary Publication Identifiers form --------------------

    match 'secondary_publications/get_pubmed_data' => 'secondary_publications#get_pubmed_data'
    match 'primary_publications/show_other' => 'primary_publications#show_other'
    match 'application/show_other' => 'application#show_other'
    match 'projects/:project_id/studies/:study_id/extraction_forms/:extraction_form_id/outcomesetup/show_other' => 'application#show_other'

    # project study sections
    match 'projects/:project_id/search'=>'projects#study_search'
    match 'projects/:project_id/studies/:id/extraction_form/:extraction_form_id/edit' => 'studies#edit'
    match 'projects/:project_id/studies/:study_id/questions' => 'studies#questions'
    match 'projects/:project_id/studies/:study_id/publications' => 'studies#publications'
    match 'projects/:project_id/studies/:study_id/extraction_forms/:extraction_form_id/arms' => 'studies#arms'
    match 'projects/:project_id/studies/:study_id/extraction_forms/:extraction_form_id/arm_details' => 'studies#arm_details'
    match 'projects/:project_id/studies/:study_id/extraction_forms/:extraction_form_id/diagnostics' => 'studies#diagnostics'
    match 'projects/:project_id/studies/:study_id/extraction_forms/:extraction_form_id/design' => 'studies#design'

    match 'projects/:project_id/studies/:study_id/extraction_forms/:extraction_form_id/baselines' => 'studies#baselines'
    match 'projects/:project_id/studies/:study_id/extraction_forms/:extraction_form_id/outcomes' => 'studies#outcomes'
    match 'projects/:project_id/studies/:study_id/extraction_forms/:extraction_form_id/outcome_details' => 'studies#outcome_details'
    match 'projects/:project_id/studies/:study_id/extraction_forms/:extraction_form_id/quality_details' => 'studies#quality_details'
    match 'projects/:project_id/studies/:study_id/extraction_forms/:extraction_form_id/diagnostic_test_details' => 'studies#diagnostic_test_details'
    match 'projects/:project_id/studies/:study_id/extraction_forms/:extraction_form_id/outcomes/new/outcome_timepoints/new' => 'outcome_timepoints#new'
    match 'projects/:project_id/studies/:study_id/extraction_forms/:extraction_form_id/outcomes/new/outcome_timepoints/destroy' => 'outcome_timepoints#destroy'
    match 'projects/:project_id/studies/:study_id/primary_publication_numbers/new' => 'primary_publication_numbers#new'
    match 'projects/:project_id/studies/:study_id/primary_publication_numbers/destroy' => 'primary_publication_numbers#destroy'
    match 'projects/:project_id/studies/:study_id/secondary_publication_numbers/new' => 'secondary_publication_numbers#new'
    match 'projects/:project_id/studies/:study_id/secondary_publication_numbers/destroy' => 'secondary_publication_numbers#destroy'
    match 'projects/:project_id/studies/:study_id/extraction_forms/:extraction_form_id/results' => 'studies#results'
    match 'projects/:project_id/studies/:study_id/extraction_forms/:extraction_form_id/comparisons' => 'studies#comparisons'
    match 'projects/:project_id/studies/:study_id/extraction_forms/:extraction_form_id/adverse' => 'studies#adverse'
    match 'projects/:project_id/studies/:study_id/extraction_forms/:extraction_form_id/quality' => 'studies#quality'
    match 'projects/:project_id/studies/:study_id/extraction_forms/:extraction_form_id/finalize' => 'studies#finalize'
    match 'projects/:project_id/studies/:study_id/extraction_forms/:extraction_form_id/adverse/savedata' => 'adverse_events#savedata'
    match 'projects/:project_id/studies/:study_id/extraction_forms/:extraction_form_id/results/show_table' => 'outcome_data_points#show_table'
    match '/*section/study/toggle_section_completion' => 'studies#toggle_section_complete'
    match '/*section/study/save_study_status_note' => 'studies#save_status_note'
    match '/*section/results/show_timepoints' => 'outcome_data_entries#show_timepoints'
    match '/projects/:project_id/studies/:study_id/results/refresh_existing' => 'outcome_data_entries#refresh_existing_results'
    match '/*section/results/show_entry_table' => 'outcome_data_entries#show_entry_table'
    match '/*section/results/show_measures_form' => 'outcome_data_entries#show_measures_form'
    match '/*section/results/update_measures' => 'outcome_data_entries#update_measures'
    match '/*section/results/show_between_arm_comparison_table' => 'outcome_data_entries#show_between_arm_comparison_table'
    match '/*section/results/create_between_arm_comparisons' => 'outcome_data_entries#create_between_arm_table'
    match '/*section/results/create_within_arm_comparisons' => 'outcome_data_entries#create_within_arm_table'
    match '/*section/results/show_comparison_measures' => 'outcome_data_entries#show_comparison_measures_form'
    match '/*section/results/update_comparison_measures' => 'outcome_data_entries#update_comparison_measures'
    match '/*section/results/clear_comparisons' => 'outcome_data_entries#clear_comparisons'
    match '/*section/results/remove_data_entry' => 'outcome_data_entries#destroy'
    match '/*section/results/remove_comparison_entry' => 'comparisons#destroy'
    match '/*section/results/remove_data_entries' => 'outcome_data_entries#destroy_for_outcome_and_subgroup'
    match '/*section/results/update_table_rows' => 'outcome_data_entries#update_table_rows'
    match '/*section/results/add_within_arm_comparison_row' => 'outcome_data_entries#add_within_arm_comparison_row'
    match '/*section/results/remove_within_arm_comparison_row' => 'outcome_data_entries#remove_within_arm_comparison_row'
    match '/*section/results/show_within_arm_comparison_measures' => 'outcome_data_entries#show_within_arm_comparison_measures_form'
    match '/*section/results/update_footnote_order' => 'outcome_data_entries#update_footnote_order'
    match '/*section/results/order_results_rows' => 'outcome_data_entries#order_results_rows'
    match '/*section/results/show_data_point_options_form' => 'outcome_data_entries#show_data_point_options_form'
    match '/*section/results/assign_data_point_attributes' => 'outcome_data_entries#assign_data_point_attributes'
    match 'projects/:project_id/studies/:study_id/extraction_forms/:extraction_form_id/results/setup_arms' => 'outcome_data_points#setup_arms'
    match 'projects/:project_id/studies/:study_id/extraction_forms/:extraction_form_id/results/saved_results' => 'outcome_data_points#saved_results'


    match '/*section/outcome_data_points/cancel_results_creation' => 'outcome_data_points#cancel_results_creation'
    match '/*section/outcome_data_points/edit_results_table' => 'outcome_data_points#edit_results_table'
    match '/*section/outcome_measures/update_measure_window' => 'outcome_measures#update_measure_window'

    match "projects/:project_id/index_pdf" => "projects#index_pdf", :method => :get, :as=>:projects_index_pdf
    match "studies/:study_id/index_pdf" => "studies#index_pdf", :method => :get, :as=>:studies_index_pdf
    match "extraction_forms/:extraction_form_id/index_pdf" => "extraction_forms#index_pdf", :method => :get, :as=>:extractionforms_index_pdf

    # user roles
    match 'projects/:project_id/manage/saveinfo' => 'user_project_roles#saveinfo'
    match 'projects/:project_id/manage/adduser' => 'user_project_roles#add_new_user'

    # requests to publish projects (user)
    match 'projects/:project_id/publish' => 'projects#publish'
    match 'projects/request_publication' => 'projects#request_publication'
    match '/projects/:project_id/confirm_publication' => 'projects#confirm_publication_request'

    # publishing projects (admin)
    match '/home/publication_requests' => 'projects#show_publication_requests'
    match '/projects/:project_id/make_public' => 'projects#make_public'

    # requests to download project data
    match 'projects/:project_id/request_data' => 'projects#data_request_form'
    match 'projects/:project_id/extraction_forms/:extraction_form_id/download'=>'projects#download'
    match 'projects/:project_id/downloads/download'=>'projects#download'
    match '/home/data_requests' => 'projects#show_data_requests'

    # extraction form sections
    match '/*section/extraction_forms/toggle_section_inclusion' => 'extraction_forms#toggle_section_inclusion'
    match 'projects/:project_id/close_editor' => 'projects#close_editor'
    match 'projects/:project_id/extraction_forms/:extraction_form_id/publications' => 'extraction_forms#publications'
    match 'projects/:project_id/extraction_forms/:extraction_form_id/arms' => 'extraction_forms#arms'
    match 'projects/:project_id/extraction_forms/:extraction_form_id/diagnostics' => 'extraction_forms#diagnostic_tests'
    match 'projects/:project_id/extraction_forms/:extraction_form_id/design' => 'extraction_forms#design'
    match 'projects/:project_id/extraction_forms/:extraction_form_id/baselines' => 'extraction_forms#baselines'
    match 'projects/:project_id/extraction_forms/:extraction_form_id/outcomes' => 'extraction_forms#outcomes'
    match 'projects/:project_id/extraction_forms/:extraction_form_id/results' => 'extraction_forms#results'
    match 'projects/:project_id/extraction_forms/:extraction_form_id/comparisons' => 'extraction_forms#comparisons'
    match 'projects/:project_id/extraction_forms/:extraction_form_id/adverse' => 'extraction_forms#adverse'
    match 'projects/:project_id/extraction_forms/:extraction_form_id/quality' => 'extraction_forms#quality'
    match 'projects/:project_id/extraction_forms/:extraction_form_id/finalize' => 'extraction_forms#finalize'
    match 'projects/:project_id/extraction_forms/:extraction_form_id/toggle_finalized' => 'extraction_forms#toggle_finalized'
    match 'projects/:project_id/extraction_forms/:extraction_form_id/send_to_bank' => 'extraction_forms#send_to_bank'
    match 'projects/:project_id/extraction_forms/:extraction_form_id/update_bank' => 'extraction_forms#update_bank'
    match '/projects/:project_id/extraction_forms/:extraction_form_id/create_default_dimensions' => 'quality_dimension_fields#create_from_defaults'

    # question builder for extraction form
    match 'projects/:project_id/extraction_forms/:extraction_form_id/question_builder' => 'extraction_forms#question_builder'
    match '/projects/:project_id/extraction_forms/:extraction_form_id/question_builder/new' => "question_builder#new"
    match '/*section/question_builder/create'=>'question_builder#create'
    match '/*section/question_builder/update'=>'question_builder#update'
    # extraction form other routes
    match 'projects/:project_id/extraction_forms/:extraction_form_id/results/delete_column' => 'extraction_forms#delete_column'
    match 'projects/:project_id/extraction_forms/:extraction_form_id/comparisons/delete_comparison_column' => 'extraction_forms#delete_comparison_column'
    match 'projects/:project_id/extraction_forms/:extraction_form_id/extraction_form_outcome_names/new' => 'extraction_form_outcome_names#new'
    match 'projects/:project_id/extraction_forms/:extraction_form_id/adverse_event_columns/new' => 'adverse_event_columns#new'
    match 'projects/:project_id/extraction_forms/:extraction_form_id/design_details/new' => 'design_details#new'
    match 'projects/:project_id/extraction_forms/:extraction_form_id/diagnostic_test_details/new' => 'diagnostic_test_details#new'
    match 'projects/:project_id/extraction_forms/:extraction_form_id/baseline_characteristics/new' => 'baseline_characteristics#new'
    match 'projects/:project_id/extraction_forms/:extraction_form_id/extraction_form_arms/new' => 'extraction_form_arms#new'
    match 'projects/:project_id/extraction_forms/:extraction_form_id/extraction_form_adverse_events/new' => 'extraction_form_adverse_events#new'
    match 'projects/:project_id/extraction_forms/:extraction_form_id/extraction_form_diagnostic_tests/new' => 'extraction_form_diagnostic_tests#new'
    match 'projects/:project_id/extraction_forms/:extraction_form_id/extraction_form_diagnostic_tests/new_instr' => 'extraction_form_diagnostic_tests#new_instr'
    match 'projects/:project_id/extraction_forms/:extraction_form_id/extraction_form_arms/new_instr' => 'extraction_form_arms#new_instr'
    match 'projects/:project_id/extraction_forms/:extraction_form_id/extraction_form_design/add_instr' => 'extraction_form_design#add_instr'
    match 'projects/:project_id/extraction_forms/:extraction_form_id/extraction_form_baselines/add_instr' => 'extraction_form_baselines#add_instr'
    match 'projects/:project_id/extraction_forms/:extraction_form_id/extraction_form_outcome/add_instr' => 'extraction_form_outcome#add_instr'
    match 'projects/:project_id/extraction_forms/:extraction_form_id/extraction_form_adverse/add_instr' => 'extraction_form_adverse#add_instr'
    match 'projects/:project_id/extraction_forms/:extraction_form_id/extraction_form_quality/add_instr' => 'extraction_form_quality#add_instr'
    match 'projects/:project_id/extraction_forms/:extraction_form_id/add_instr' => 'question_builder#add_instr'
    match 'projects/:project_id/extraction_forms/:extraction_form_id/extraction_form_section_save' => 'extraction_forms#extraction_form_section_save'
    match 'projects/:project_id/extraction_forms/:extraction_form_id/update_adverse_event_settings' => 'extraction_forms#update_adverse_event_settings'
    match 'projects/:project_id/key_questions/new' => "key_questions#new"
    match 'projects/key_questions/new' => "key_questions#new"
    match 'projects/:project_id/extraction_forms/:extraction_form_id/quality_dimension_fields/new' => 'quality_dimension_fields#new'
    match 'projects/:project_id/extraction_forms/:extraction_form_id/quality_rating_fields/new' => 'quality_rating_fields#new'

    # extraction form templates (FORM BANK)
    match 'extraction_form_templates/index' => 'extraction_form_templates#index'
    match '/*section/preview_form_template' => 'extraction_form_templates#preview'
    match '/*section/extraction_form_templates/remove' => 'extraction_form_templates#remove_from_bank'
    match 'extraction_forms/add_from_bank' => 'extraction_form_templates#show_bank_modal'
    match '/*section/project_setup_form' => 'extraction_form_templates#project_setup_form'
    match '/*section/extraction_form_templates/assign_to_project' => 'extraction_form_templates#assign_to_project'

    # other extraction form stuff
    match 'outcome_comparison_columns/:outcome_comparison_column_id/delete' => 'outcome_comparison_columns#delete'
    match 'outcome_columns/:outcome_column_id/delete' => 'outcome_columns#delete'
    match 'adverse_event_columns/:adverse_event_column_id/delete' => 'adverse_event_columns#delete'
    match 'quality_dimension_fields/:id/confirm_delete' => 'quality_dimension_fields#confirm_delete'
    match 'quality_dimension_fields/:id/edit' => 'quality_dimension_fields#edit'
    match 'quality_dimension_fields/:id/destroy' => 'quality_dimension_fields#destroy'
    match '/*section/quality_dimension_fields/reorder' => 'quality_dimension_fields#reorder'
    match 'quality_rating_fields/:id/confirm_delete' => 'quality_rating_fields#confirm_delete'
    match '/*section/quality_rating_fields/:id/destroy' => 'quality_rating_fields#destroy'
    match 'quality_rating_fields/:id/edit' => 'quality_rating_fields#edit'
    match '/*sections/extraction_forms/toggle_by_category' => 'extraction_forms#toggle_by_category'

    # CREATING BATCHES OF STUDIES AND MANAGING USER ASSIGNMENTS
    match 'studies/create_for_pmid_list' => 'studies#create_for_pmid_list'
    match 'projects/:project_id/studies/upload' => 'studies#batch_assignment'
    match 'projects/:project_id/studies/show_assignment' => 'study_assignments#show'
    match 'projects/:project_id/studies/:study_id/reassign' => 'study_assignments#update'

    # SIMPLE IMPORT OF STUDIES INTO DESIGN DETAILS TAB ONLY
    match 'projects/:project_id/studies/simport' => 'studies#simport'

    # other study routes
    match 'secondary_publications/:secondary_publication_id/moveup' => 'secondary_publications#moveup'
    match 'projects/:project_id/studies/:study_id/extraction_forms/:extraction_form_id/arms/:arm_id/moveup'  => 'arms#moveup'
    match 'key_questions/:id/moveup' => 'key_questions#moveup'
    match 'adverse_events/:adverse_event_id/moveup' => 'adverse_events#moveup'
    match '/*section/quality_rating_fields/:quality_rating_field_id/moveup' => 'quality_rating_fields#moveup'
    match 'projects/:project_id/studies/:study_id/secondary_publications/new' => 'secondary_publications#new'
    match '/*section/adverse_events/create_row'=>'adverse_events#create'
    # -- study arms
    match 'projects/:project_id/studies/:study_id/extraction_form/:extraction_form_id/arms/new' => 'arms#new'
    match 'projects/:project_id/studies/:study_id/arms/new' => 'arms#new'

    match 'projects/:project_id/studies/:study_id/extraction_forms/:extraction_form_id/diagnostic_tests/new' => 'diagnostic_tests#new'
    match 'projects/:project_id/studies/:study_id/extraction_forms/:extraction_form_id/design_details/new' => 'design_details#new'

    #match 'projects/:project_id/studies/:study_id/extraction_forms/:extraction_form_id/baseline_characteristics/new' => 'baseline_characteristics#new'

    # -- study outcomes
    match 'projects/:project_id/studies/:study_id/extraction_form/:extraction_form_id/outcomes/new' => 'outcomes#new'
    match 'projects/:project_id/studies/:study_id/outcomes/new' => 'outcomes#new'

    match 'projects/:project_id/studies/:study_id/extraction_forms/:extraction_form_id/quality_dimensions/new' => 'quality_dimension_fields#new'
    match '/exporter/full_proj_human/:project_id'=>'projects#export_human_readable'
    match '/exporter/full_proj_machine/:project_id'=>'projects#export_machine_readable'
    match '/tcexporter/saveas_excel/:project_id'=>'tablecreator#export_to_excel'
    match 'projects/:project_id/comparestudies'=>'compare_studies#comparestudies'

    # COMPARISONS ROUTES
    resources :comparison_data_points, :comparison_measures
    match '/*section/comparison_data_points/show_group_selector' => 'comparison_data_points#show_group_selector'
    match '/*section/comparison_data_points/show_comparison_selector' => 'comparison_data_points#show_comparison_selector'
    match '/*section/comparison_data_points/show_comparison_table' => 'comparison_data_points#show_comparison_table'
    match '/*section/comparison_data_points/cancel_comparison_creation' => 'comparison_data_points#cancel_comparison_creation'
    match '/*section/comparison_measures/import_measures' => 'comparison_measures#import_measures'
    match '/*section/comparison_measures/edit'=>'comparison_measures#edit'
    match '/*section/comparison_measures/cancel_edit'=>'comparison_measures#cancel_edit'
    match '/*section/comparison_data_points/edit_comparison'=>'comparison_data_points#edit_comparison'

    # FEEDBACK FORM ROUTES
    match 'home/feedback' => 'home#feedback'
    match 'home/user_list' => 'home#user_list'
    match 'home/send_feedback' => 'home#send_feedback'
    match 'home/policies'
    match 'home/citing_srdr'
    match 'home/training_sessions'

    # TEMPLATE QUESTION/ANSWER CREATION ROUTES
    match '/*section/question_builder/show_input_options' => 'question_builder#show_input_options'
    match '/*section/question_builder/show_matrix_options' => 'question_builder#show_matrix_options'
    match '/*section/question_builder/add_choice' => 'question_builder#add_choice'
    match '/*section/question_builder/remove_choice' => 'question_builder#remove_choice'
    match '/*section/question_builder/add_column' => 'question_builder#add_column'
    match '/*section/question_builder/remove_column' => 'question_builder#remove_column'
    match 'question_builder/remove_choice' => 'question_builder#remove_choice'
    match 'question_builder/destroy' => 'question_builder#remove_question'
    match '/*section/question_builder/shift_numbers' => 'question_builder#shift_numbers'
    match '/*section/question_builder/cancel_editing' => 'question_builder#cancel_editing'
    match 'question_builder/edit_question'  => 'question_builder#edit_question'
    match 'question_builder/copy_question'  => 'question_builder#copy_question'
    match '/*section/question_builder/show_input_options_during_edit' => 'question_builder#show_input_options_during_edit'
    match "/*section/question_builder/show_subquestion_assignment"=>"question_builder#show_subquestion_assignment"
    match "/*section/question_builder/show_subquestion"=>"question_builder#show_subquestion"

    # TEMPLATE OPTION FOR SECTIONS USERS CAN EDIT
    match '/projects/:project_id/extraction_forms/:extraction_form_id/save_section_edit_capability' => 'extraction_forms#save_section_edit_capability'

    # ROUTES FOR THE 'OTHER' SELECTOR
    match 'primary_publications/show_other' => 'primary_publications#show_other'
    match 'projects/:project_id/studies/:study_id/extraction_forms/:extraction_form_id/application/show_other' => 'application#show_other'
    match 'projects/:project_id/extraction_forms/:extraction_form_id/application/show_other' => 'application#show_other'
    match 'home/application/show_other' => 'application#show_other'
    match '/application/show_other_filled' => 'application#show_other_filled'
    match 'userprojects' => 'users#userprojects'
    match 'projects/:project_id/manage' => 'projects#manage'
    match 'projects/:project_id/progress' => 'projects#show_progress'
    match 'projects/:project_id/import_new_data' => 'projects#import_new_data'
    match 'projects/:project_id/update_existing_data' => 'projects#update_existing_data'

    match 'search' => 'search#index'
    match 'adv_search' => 'adv_search#index'

    match 'search/results' => 'search#results'
    match 'search/filter' => 'search#filter'
    match 'adv_search/adv_results' => 'adv_search#adv_results'
    match 'adv_search/advfilter' => 'adv_search#advfilter'

    match 'login' => "user_sessions#new",      :as => :login
    match 'logout' => "user_sessions#destroy", :as => :logout
    match 'register' => "users#new", :as => :register

    # ROUTES FOR THE TUTORIAL VIDEOS
    match 'home/demo1' => 'home#demo1'
    match 'home/demo2' => 'home#demo2'
    match 'home/demo3' => 'home#demo3'
    # [MK] Adding users guide and FAQ links
    match 'home/faq' => 'home#faq'
    match 'home/user_manual'
    match 'home/training_materials'
    match 'home/cochrane_2012'
    #match 'home/usersguide' => 'home#usersguide'
    match 'home/commentpolicy' => 'home#commentpolicy'
    match 'home/datasharingpolicy' => 'home#datasharingpolicy'
    match 'test' => 'home#test'
    match 'about' => 'home#about'
    match 'help' => 'home#help'
    match 'css_markup' => 'home#css_markup'
    match 'css_markup_home' => 'home#css_markup_home'
    match '/home/coming_soon'
    get   'announcement' => 'home#announcement'

    # User account review and management
    match '/accountsmanager/delete/:user_id' => 'accountsmanager#delete'
    match '/accountsmanager/approve_request/:user_id' => 'accountsmanager#approve_request'

    match '*a', :to => 'errors#routing'
end
