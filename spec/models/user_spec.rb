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

end
