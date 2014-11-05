require "rails_helper"

describe QuestionsController do
  describe "GET index" do
    context "no claimed question" do
      it "sets @active_question to nil" do
        get :index
        expect(assigns(:active_question)).to be_nil
      end

      it "sets @unclaimed_questions to set of all questions" do
        Fabricate(:question)

        get :index
        expect(assigns(:unclaimed_questions).size).to eq(1)
      end

    end

    context "claimed question exists" do
      before do
        @q1 = Fabricate(:question)
        @q2 = Fabricate(:question, claimed: true)
        @q3 = Fabricate(:question)
      end

      it "sets @active_question to the claimed question" do
        get :index
        expect(assigns(:active_question)).to eq(@q2)
      end

      it "sets @unclaimed_questions to set of all questions minus the claimed question" do
        get :index
        expect(assigns(:unclaimed_questions)).to eq([@q1, @q3])
      end

    end

    it "orders entries in @unclaimed_questions chronologically" do
      q1 = Fabricate(:question)
      q2 = Fabricate(:question)
      q3 = Fabricate(:question)

      q1.created_at = 1.days.ago
      q1.save

      q2.created_at = 3.days.ago
      q2.save

      q3.created_at = 2.days.ago
      q3.save

      get :index
      expect(assigns(:unclaimed_questions)).to eq([q2, q3, q1])

    end

  end

end