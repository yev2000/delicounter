require "rails_helper"

describe User do
  it { should have_many(:questions) }
  it { should validate_presence_of(:username) }
  it { should validate_uniqueness_of(:username) }

  it "should destroy associated questions when destroyed" do
    user = Fabricate(:user)
    question1 = Fabricate(:question, user: user)
    question2 = Fabricate(:question, user: user)

    expect(Question.all.size).to eq(2)
    
    user.destroy

    expect(Question.all.size).to eq(0)
  end

  describe "#oldest_question_time" do
    before { @user = Fabricate(:user) }

    it("returns nil if there are no questions associated with the user") { expect(@user.oldest_question_time).to eq(nil) }

    it "returns the creation time a question if the user only has one question" do
      question = Fabricate(:question, user: @user)

      ## somehow eq of the objects themselves does not work
      expect(@user.oldest_question_time.to_i).to eq(question.created_at.to_i)
    end

    it "returns the earliest creation time of the questions that belong to the user" do
      q_array = []
      [1,2,3,4,5].each do |i|
        question = Fabricate(:question, user: @user)
        question.created_at = i.minutes.ago
        question.save 
        q_array << question
      end

      expect(@user.oldest_question_time.to_i).to eq(q_array[4].created_at.to_i)
    end
    
  end


end
