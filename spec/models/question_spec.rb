require "rails_helper"

def create_reversed_age_questions
  q1 = Fabricate(:question)
  q2 = Fabricate(:question)
  q3 = Fabricate(:question)
  q4 = Fabricate(:question)

  q1.created_at = 1.days.ago
  q1.save

  q2.created_at = 2.days.ago
  q2.save

  q3.created_at = 3.days.ago
  q3.save

  q4.created_at = 4.days.ago
  q4.save

  return [q1, q2, q3, q4]
end

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

  describe "#active_question" do

    it "returns nil if there is no claimed question" do
      q = Fabricate(:question)
      expect(Question.active_question).to be_nil
    end

    it "returns nil if there are no questions" do
      expect(Question.active_question).to be_nil
    end

    it "returns the claimed question" do
      q1 = Fabricate(:question)
      q2 = Fabricate(:question, claimed: true)
      q3 = Fabricate(:question)

      expect(Question.active_question).to eq(q2)
    end
  end #active_question

  describe "#unclaimed_questions" do

    it "returns nil if there are no questions" do
      expect(Question.unclaimed_questions).to be_nil
    end

    context "no claimed question" do

      it "returns the set of unclaimed questions" do
        created_array = create_reversed_age_questions

        expect(Question.unclaimed_questions).to match_array(created_array)
      end

      it "returns the set of unclaimed questions in order from oldest to newest" do
        created_array = create_reversed_age_questions

        expect(Question.unclaimed_questions).to eq(created_array.reverse)
      end
    end # no claimed question

    context "a question is claimed" do
      it "returns the set of unclaimed questions" do
        created_array = create_reversed_age_questions

        claimed_one = created_array[2]
        claimed_one.claimed = true
        claimed_one.save

        expect(Question.unclaimed_questions).to match_array(created_array - [claimed_one])
      end
    end # claimed question

  end #active_question

  describe "#get_order_position_string" do
    it "returns 'not in the queue' if there are no questions" do
      input_question = Fabricate.build(:question)
      retval = Question.get_order_position_string(input_question)
      expect(retval).to eq('not in the queue')
    end

    context "no claimed questions" do
      it_behaves_like("ordinal_position_strings")
    end # no claimed questions

    context "claimed questions" do
      before { Fabricate(:question, claimed: true) }

      it_behaves_like("ordinal_position_strings")
    end

  end #get_order_position_string

end
