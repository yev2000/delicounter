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
    
    u1 = Fabricate(:user)
    u2 = Fabricate(:user)
    4.times.each { |i| Fabricate(:question, user: u1) }
    3.times.each { |i| Fabricate(:question, user: u2) }

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

def expect_questions_index_page(question_array)
  expect(page).to have_content "Active Question"
  question_array.each do |question|
    expect(page).to have_content question.title
    if question.claimed == false
      link = find_by_id("question-title-#{question.id}")
      expect(link.text).to eq(question.title)
    end
  end

  if Question.active_question
    title_em = find_by_id("active-question-title-#{Question.active_question.id}")
    expect(title_em.text).to eq(Question.active_question.title)
  end

end

def expect_question_edit_page(question)
  expect(page).to have_content "Enter Your Question"
  expect(page).to have_button "Update Question"

  field = find_by_id("question_title")
  expect(field.value).to eq(question.title)
  field = find_by_id("question_body")
  expect(field.value).to eq(question.body)
end


def perform_question_submission(ref_question)
  click_new_question_button

  expect(page).to have_content "Enter Your Question"
  expect(page).to have_button "Submit New Question"

  fill_in "question_title", with: ref_question.title
  fill_in "question_body", with: ref_question.body

  click_button "Submit New Question"
end

def perform_question_delete(ref_question)
  click_delete_question_link(ref_question)
end

def perform_question_claim(ref_question)
  click_claim_question_link(ref_question)
end

def perform_question_unclaim
  click_unclaim_question_link
end

def perform_question_complete
  click_complete_question_link
end

def perform_question_edit(new_title, new_body)
  fill_in "question_title", with: new_title
  fill_in "question_body", with: new_body
  click_button "Update Question"
end

def click_new_question_button
  new_question_button = find_by_id("new-question-button")
  new_question_button.click
end

def click_claim_question_link(ref_question)
  claim_question_link = find_by_id("claim-question-#{ref_question.id}")
  claim_question_link.click
end

def click_unclaim_question_link
  unclaim_question_link = find_by_id("unclaim-question-id")
  unclaim_question_link.click
end

def click_complete_question_link
  complete_question_link = find_by_id("complete-question-id")
  complete_question_link.click
end

def click_delete_question_link(ref_question)
  delete_question_link = find_by_id("delete-question-#{ref_question.id}")
  delete_question_link.click
end

def click_edit_question_link(question)
  edit_question_link = find_by_id("edit-question-#{question.id}")
  edit_question_link.click
end

def click_view_queue_link
  view_queue_link = find_by_id("view-queue")
  view_queue_link.click
end


def expect_user_name_on_page(username)
  expect(page).to have_content username
end

def expect_button_exists(button_text)
  expect(page).to have_button button_text
end
