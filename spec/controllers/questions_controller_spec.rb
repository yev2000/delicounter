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
      it("flashes a danger message") { expect_danger_flash }
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

  describe "GET edit" do
    context "user not signed in" do
      it_behaves_like("require_sign_in") { let(:action) { get :new } }
    end

    context "user signed in" do
      before { set_current_user }

      context "id does not identify a question" do
        before { Fabricate(:question) }

        it_behaves_like("invalid_question_show_or_edit") { let(:action) { get :edit, id: 3 } }
      end

      context "user owns the question being edited" do
        before do
          question = Fabricate(:question, user: get_current_user)
          get :edit, id: question.id
        end

        it("renders the edit template") { expect(response).to render_template :edit }
        it("sets the @question instance variable") { expect(assigns(:question)).to be_a(Question) }
      end

      context "question is already claimed" do
        before do
          @question = Fabricate(:question, claimed: true, user: get_current_user)
        end

        it_behaves_like("invalid_question_show_or_edit") { let(:action) { get :edit, id: @question.id} }
      end

      context "user does not own the question being edited" do
        before do
          user = Fabricate(:user)
          @question = Fabricate(:question, user: user)
        end

        it_behaves_like("invalid_question_show_or_edit") { let(:action) { get :edit, id: @question.id} }
      end
    end # user signed in

  end # GET edit

  describe "POST update" do
    context "user not signed in" do
      before do
        user = Fabricate(:user)
        @question = Fabricate(:question, user: user)
      end

      it_behaves_like("require_sign_in") { let(:action) { post :update, id: @question.id, question: { title: "New Title", body: "New Body" } } }
    end

    context "user signed in" do
      before { set_current_user }

      context "id does not identify a question" do
        before { Fabricate(:question) }

        it_behaves_like("invalid_question_show_or_edit") { let(:action) { post :update, id: 3, question: { title: "New Title", body: "New Body" } } }
      end

      context "user owns the question being edited" do
        before do
          @question = Fabricate(:question, user: get_current_user)
          post :update, id: @question.id, question: { title: "New Title", body: "New Body" }
          @question.reload
        end

        it("updates the title of the question") { expect(@question.title).to eq("New Title") }
        it("updates the body of the question")  { expect(@question.body).to eq("New Body") }
        it("renders the questions index") { expect(response).to redirect_to questions_path }
      end

      context "body is blank" do
        before { @question = Fabricate(:question, user: get_current_user) }

        it_behaves_like("valid_question_missing_data_edit") { let(:action) { post :update, id: @question.id, question: { title: "New Title", body: "" }}}
      end

      context "title is blank" do
        before { @question = Fabricate(:question, user: get_current_user) }

        it_behaves_like("valid_question_missing_data_edit") { let(:action) { post :update, id: @question.id, question: { title: "", body: "New Body" }}}
      end



      context "question is already claimed" do
        before { @question = Fabricate(:question, claimed: true, user: get_current_user) }

        it_behaves_like("invalid_question_show_or_edit") { let(:action) { post :update, id: @question.id, question: { title: "New Title", body: "New Body" }} }
      end

      context "user does not own the question being edited" do
        before do
          user = Fabricate(:user)
          @question = Fabricate(:question, user: user)
        end

        it_behaves_like("invalid_question_show_or_edit") { let(:action) { post :update, id: @question.id, question: { title: "New Title", body: "New Body" }} }
      end
    end # user signed in

  end # POST update

  describe "GET show" do

    context "user not signed in" do
      before do
        user = Fabricate(:user)
        @question = Fabricate(:question, user: user)
      end

      it "renders the show question template" do
        get :show, id: @question.id
        expect(response).to render_template :show
      end

      it "sets @question to the question identified by the id" do
        get :show, id: @question.id
        expect(assigns(:question)).to eq(@question)
      end
    end

    context "user signed in" do
      before do
        set_current_user
        @question = Fabricate(:question, user: get_current_user)
      end

      it "renders the show question template" do
        get :show, id: @question.id
        expect(response).to render_template :show
      end

      it "sets @question to the question identified by the id" do
        get :show, id: @question.id
        expect(assigns(:question)).to eq(@question)
      end
    end

    context "id does not identify a question" do
      before { Fabricate(:question) }

      it_behaves_like("invalid_question_show_or_edit") { let(:action) { get :show, id: 3 } }
    end

  end # GET show

  describe "DELETE destroy" do
    context "user not signed in" do
      before do
        user = Fabricate(:user)
        @question = Fabricate(:question, user: user)
      end

      it_behaves_like("require_sign_in") { let(:action) { delete :destroy, id: @question.id } }

      it "does not destroy the question" do
        delete :destroy, id: @question.id
        expect(Question.all.size).to eq(1)
      end

    end

    context "user signed in" do
      before { set_current_user }

      context "id does not identify a question" do
        before { @question = Fabricate(:question) }

        it_behaves_like("invalid_question_show_or_edit") { let(:action) { delete :destroy, id: 3 } }

        it "does not destroy the question" do
          delete :destroy, id: @question.id
          expect(Question.all.size).to eq(1)
        end
      end

      context "user owns the question being edited" do
        before do
          @question = Fabricate(:question, user: get_current_user)
          delete :destroy, id: @question.id
        end

        it("destroys the question") { expect(Question.all.size).to eq(0) }
        it("renders the questions index") { expect(response).to redirect_to questions_path }
        it("flashes success") { expect_success_flash }

      end

      context "question is already claimed" do
        before { @question = Fabricate(:question, claimed: true, user: get_current_user) }

        it_behaves_like("invalid_question_show_or_edit") { let(:action) { delete :destroy, id: @question.id } }

        it "does not destroy the question" do
          delete :destroy, id: @question.id
          expect(Question.all.size).to eq(1)
        end

      end

      context "user does not own the question being edited" do
        before do
          user = Fabricate(:user)
          @question = Fabricate(:question, user: user)
        end

        it_behaves_like("invalid_question_show_or_edit") { let(:action) { delete :destroy, id: @question.id } }

        it "does not destroy the question" do
          delete :destroy, id: @question.id
          expect(Question.all.size).to eq(1)
        end
      end
    end # user signed in

  end # DELETE destroy


end