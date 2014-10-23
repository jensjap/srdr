FactoryGirl.define do
    factory :user do
        login                 "testerbot"
        email                 "testerbot@factory.com"
        fname                 "tester"
        lname                 "bot"
        organization          "tester corp"
        user_type             "member"
        password              "foobar"
        password_confirmation "foobar"
    end

    factory :user_organization_role do
        user_id               1
        role                  "contributor"
        status                "VALID"
    end

    factory :user_project_role do
        user_id               1
        project_id            1
        role                  "lead"
    end

    factory :project do
        title                 "rspec test project 1"
        description           "This is a description of the test project"
        notes                 "Some notes for the test project"
        funding_source        "The funding source of the test project"
        creator_id            1
        is_public             0
        contributors          "jstesterbot"
        methodology           "Test project methodology"
    end

    factory :key_question do
        project_id            1
        question_number       1
        question              "Why is the world round?"
    end

    factory :extraction_form do
        title                 "Extraction Form for rspec test project 1"
        creator_id            1
        notes                 "Extraction Form notes"
        project_id            1
    end

    factory :study do
        project_id            1
        creator_id            1
    end

    factory :study_extraction_form do
        study_id              1
        extraction_form_id    1
    end

    factory :extraction_form_section do
        section_name          "design"
        included              1
    end

    factory :extraction_form_key_question do
        extraction_form_id    1
        key_question_id       1
    end
end
