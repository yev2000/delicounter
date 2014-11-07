def set_current_user(user=nil)
  if user.nil?
    user = Fabricate(:user)
  end

  session[:userid] = user.id
end

def set_current_admin_user(admin=nil)
  if admin.nil?
    admin = Fabricate(:admin)
  end

  session[:adminid] = admin.id
end

def get_current_user
  session[:userid] ? User.find_by(id: session[:userid]) : nil
end

def clear_current_user
  session[:userid] = nil
end

def clear_current_admin_user
  session[:adminid] = nil
end

def sign_in_user(username)
  visit signin_path
  fill_in "Your Name", with: username
  click_button "Sign In"
end

def sign_in_admin(admin_user)
  visit admin_signin_path
  fill_in "Username", with: admin_user.username
  fill_in "Password", with: admin_user.password
  click_button "Admin Sign In"
end


def expect_success_flash
  expect(flash[:success]).not_to be_blank
end

def expect_danger_flash
  expect(flash[:danger]).not_to be_blank
end

##################
#
# Features
#
##################

def create_baseline_users_and_questions
  u1 = Fabricate(:user)
  u2 = Fabricate(:user)
  4.times.each { |i| Fabricate(:question, user: u1) }
  3.times.each { |i| Fabricate(:question, user: u2) }
end

def expect_non_signed_in_header_choices
  expect(page).to have_content "View Queue"
  expect(page).to have_content "Enter Question"
  expect(page).to have_content "View Participants"
  expect(page).to have_content "Sign In"
end

def expect_admin_signed_in_header_choices(admin)
  expect(page).to have_content "View Queue"
  expect(page).not_to have_content "Enter Question"
  expect(page).to have_content "View Participants"
  expect(page).not_to have_content "Sign In"
  expect(page).to have_content admin.username
end

def expect_user_signed_in_header_choices(user)
  expect(page).to have_content "View Queue"
  expect(page).to have_content "Enter Question"
  expect(page).to have_content "View Participants"
  expect(page).not_to have_content "Sign In"
  expect(page).to have_content user.username
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

def expect_delete_link(question_array)
  question_array.each do |question|
    expect(page).to have_selector("#delete-question-#{question.id}")
  end
end  

def expect_no_delete_link(question_array)
  question_array.each do |question|
    expect(page).not_to have_selector("#delete-question-#{question.id}")
  end
end  

def expect_claim_link(question_array)
  question_array.each do |question|
    expect(page).to have_selector("#claim-question-#{question.id}")
  end
end  

def expect_no_claim_link(question_array)
  question_array.each do |question|
    expect(page).not_to have_selector("#claim-question-#{question.id}")
  end
end  

def expect_edit_link(question_array)
  question_array.each do |question|
    expect(page).to have_selector("#edit-question-#{question.id}")
  end
end  

def expect_no_edit_link(question_array)
  question_array.each do |question|
    expect(page).not_to have_selector("#edit-question-#{question.id}")
  end
end  


def perform_question_submission(ref_question)
  click_new_question_button

  expect(page).to have_content "Enter Your Question"
  expect(page).to have_button "Submit New Question"

  fill_in "question_title", with: ref_question.title
  fill_in "question_body", with: ref_question.body
  question_count = Question.all.size
  click_button "Submit New Question"
  expect(Question.all.size).to eq(question_count + 1)

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
