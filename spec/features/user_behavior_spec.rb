require "rails_helper"

feature "user choices" do
  scenario "user logs in and all choices available in navbar" do
    visit home_path
    expect_non_signed_in_header_choices
    sign_in_user("Alice")
    expect_user_signed_in_header_choices(User.first)
  end

  scenario "user logs in and all home choices available" do
    visit home_path
    expect(page).to have_content "Add Question to Queue"
    expect(page).to have_content "See Users"

    sign_in_user("Alice")
    visit home_path
    expect(page).to have_content "Add Question to Queue"
    expect(page).to have_content "See Users"
  end

  scenario "user logs in, submits questions, and can only edit their own submitted questions" do

    create_baseline_users_and_questions
    
    sign_in_user("Alice")
    click_view_queue_link

    expect_questions_index_page(Question.all)

    # add a question
    perform_question_submission(Question.new(title: "My First Question", body: "This is detailed text for my first question.  Here is a second sentence."))
    expect_questions_index_page(Question.all)

    # confirm that you can edit and delete that question
    user = User.find_by(username: "Alice")
    expect_delete_link(user.questions)
    expect_edit_link(user.questions)

    # confirm you cannot edit and delete others
    expect_no_delete_link(Question.all.to_a - user.questions)
    expect_no_edit_link(Question.all.to_a - user.questions)
    expect_no_claim_link(Question.all)
  end
end
