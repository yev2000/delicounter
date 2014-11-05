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

  end # GET index

  describe "GET new" do

    context "user not signed in" do
      it_behaves_like("require_sign_in") { let(:action) { get :new } }
    end

    context "user signed in" do
      before { set_current_user }

      it "renders the new question template" do
        get :new
        expect(response).to render_template :new
      end

      it "sets @question to a blank question" do
        get :new
        expect(assigns(:question)).to be_a(Question)
      end
    end

  end # GET new

  describe "POST create" do
    context "no signed in user" do
      before { post :create, question: { title: "A title", body: "A body" } }

      it("redirects to signin page") { expect(response).to redirect_to signin_path }
      it("flashes an error message") { expect_error_flash }
      it("does not create a question") { expect(Question.all.size).to eq(0) }
    end

    context "signed in user" do
      before { set_current_user }

      context "contains title and body" do

        context "no claimed question" do
          before { post :create, question: { title: "A title", body: "A body" } }

          it("creates a new question") { expect(Question.all.size).to eq(1) }
          it("adds the question to the set of questions associated with the signed in user") { expect(get_current_user.questions).to include(Question.first) }
          it("does not result in a claimed question") { expect(Question.all.where("claimed = 't'")).to eq([]) }
          it("redirects to the questions index") { expect(response).to redirect_to questions_path }
        end

        it "does not change a claimed question if one is already claimed" do
          u = Fabricate(:user)
          q = Fabricate(:question, claimed: true, user: u)
          post :create, question: { title: "A title", body: "A body" }

          expect(Question.all.where("claimed = 't'")).to eq([q])
          expect(Question.all.size).to eq(2)
        end

      end

      context "missing title" do
        before { post :create, question: { body: "A body" } }
        
        it("does not create a question") { expect(Question.all.size).to eq(0) }
        it("renders new template") { expect(response).to render_template :new }
      end

      context "missing body" do
        before { post :create, question: { title: "A title" } }

        it("does not create a question") { expect(Question.all.size).to eq(0) }
        it("renders new template") { expect(response).to render_template :new }
      end


    end # signed in user

  end # POST create

end