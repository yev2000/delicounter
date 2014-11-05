require "rails_helper"

describe Question do
  it { should belong_to(:user) }
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:body) }

  describe "#age_string" do
    it "returns the string representation of how long ago the question was created" do
      q = Fabricate(:question)
      q.created_at = 2.days.ago
      q.save

      expect(q.age_string).to eq("2 days ago")
    end
  end

end
