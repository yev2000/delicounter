shared_examples "require_sign_in" do
  it "redirects to the sign in page" do
    clear_current_user
    action
    expect(response).to redirect_to signin_path
  end
end

shared_examples "ordinal_position_strings" do
  it "returns 'next in the queue' if the question is the only question in the queue" do
    input_question = Fabricate(:question)
    retval = Question.get_order_position_string(input_question)
    expect(retval).to eq("next in the queue")
  end

  it "returns 'not in the queue' if the question is not part of the saved questions" do
    Fabricate(:question)
    Fabricate(:question)
    input_question = Fabricate.build(:question)
    retval = Question.get_order_position_string(input_question)
    expect(retval).to eq("not in the queue")
  end

  it "returns the position of the question within the question set that is ordered by time" do
    question_set = create_reversed_age_questions

    retval = Question.get_order_position_string(question_set[2])
    expect(retval).to eq("2nd")
  end
end

shared_examples "invalid_question_show_or_edit" do
  it "flashes danger message" do
    action
    expect_danger_flash
  end

  it "redirects to questions index" do
    action
    expect(response).to redirect_to questions_path
  end
end

shared_examples "valid_question_missing_data_edit" do
  it "renders the edit template" do
    action
    expect(response).to render_template :edit
  end
end
