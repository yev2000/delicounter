require "rails_helper"

feature "admin choices" do
  scenario "admin logs in and no choice to submit a question from navbar" do
    admin = Fabricate(:admin)

    visit home_path
    expect_non_signed_in_header_choices
    sign_in_admin(admin)
    expect_admin_signed_in_header_choices(admin)

  end

  scenario "admin logs in and no choice to submit a question from front screen" do
    admin = Fabricate(:admin)

    visit home_path
    expect(page).to have_content "Add Question to Queue"
    expect(page).to have_content "See Users"

    sign_in_admin(admin)
    visit home_path

    expect(page).not_to have_content "Add Question to Queue"
    expect(page).to have_content "See Users"
  end

  scenario "admin logs in and all questions can be claimed if no question yet claimed" do
    create_baseline_users_and_questions
    admin = Fabricate(:admin)
    sign_in_admin(admin)
    expect_claim_link(Question.all)

    # now claim a question
    claim_question = Question.find(4)
    perform_question_claim(claim_question)

    expect_no_claim_link(Question.all)

  end

end
