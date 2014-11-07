require "rails_helper"

feature "question processing" do
  scenario "user adds and edits their question" do
    sign_in_user("Alice")
    expect_user_name_on_page("Alice")

    # visit the page to post a question
    perform_question_submission(Question.new(title: "My First Question", body: "This is detailed text for my first question.  Here is a second sentence 111."))
    expect_questions_index_page(Question.all)

    perform_question_submission(Question.new(title: "My Second Question", body: "This is detailed text for my second question.  Here is a second sentence 222."))
    expect_questions_index_page(Question.all)

    perform_question_submission(Question.new(title: "My Third Question", body: "This is detailed text for my third question.  Here is a second sentence 333."))
    expect_questions_index_page(Question.all)

    # find and click on the second question
    edited_question = Question.find(2)
    click_edit_question_link(edited_question)
    expect_question_edit_page(edited_question)
    perform_question_edit(edited_question.title + "XX", edited_question.body + "YY")

    edited_question = Question.find(2)
    expect(edited_question.title).to include("XX")
    expect(edited_question.body).to include("YY")
    
    click_view_queue_link

    edited_question = Question.find(3)
    click_edit_question_link(edited_question)
    expect_question_edit_page(edited_question)
    perform_question_edit(edited_question.title + "AA", edited_question.body + "BB")

    edited_question = Question.find(3)
    expect(edited_question.title).to include("AA")
    expect(edited_question.body).to include("BB")

    click_view_queue_link
    expect_questions_index_page(Question.all)
  end

  scenario "user adds some questions and deletes some" do
    sign_in_user("Alice")
    expect_user_name_on_page("Alice")

    # visit the page to post a question
    perform_question_submission(Question.new(title: "My First Question", body: "This is detailed text for my first question.  Here is a second sentence 111."))
    expect_questions_index_page(Question.all)

    perform_question_submission(Question.new(title: "My Second Question", body: "This is detailed text for my second question.  Here is a second sentence 222."))
    expect_questions_index_page(Question.all)

    perform_question_submission(Question.new(title: "My Third Question", body: "This is detailed text for my third question.  Here is a second sentence 333."))
    expect_questions_index_page(Question.all)
    expect(Question.all.size).to eq(3)

    # now delete the middle question
    perform_question_delete(Question.find(2))
    expect_questions_index_page(Question.all)
    expect(Question.all.size).to eq(2)

    perform_question_delete(Question.find(3))
    expect_questions_index_page(Question.all)
    expect(Question.all.size).to eq(1)
  end
  
  scenario "admin signs in and claims and unclaims and completes some questions" do
    admin = Fabricate(:admin)

    create_baseline_users_and_questions    

    sign_in_admin(admin)
    expect(page).to have_content admin.username
    expect_questions_index_page(Question.all)

    # now start claiming and unclaiming questions
    expect(Question.active_question).to be_nil

    claim_question = Question.find(5)
    perform_question_claim(claim_question)
    expect(Question.active_question).to eq(claim_question)
    expect_questions_index_page(Question.all)

    perform_question_unclaim
    expect(Question.active_question).to be_nil
    expect_questions_index_page(Question.all)

    claim_question = Question.find(2)
    perform_question_claim(claim_question)
    expect(Question.active_question).to eq(claim_question)
    perform_question_complete
    expect(Question.active_question).to be_nil
    expect_questions_index_page(Question.all)
    expect(Question.all.size).to eq(6)

    claim_question = Question.find(4)
    perform_question_claim(claim_question)
    expect(Question.active_question).to eq(claim_question)
    perform_question_complete
    expect(Question.active_question).to be_nil
    expect_questions_index_page(Question.all)
    expect(Question.all.size).to eq(5)

  end

end

