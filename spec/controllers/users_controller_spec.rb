require 'rails_helper'

describe UsersController do
  
  describe "GET index" do
    context "basic behavior" do
      before do
        3.times { Fabricate(:user) }
        get :index
      end

      it("renders the index template") { expect(response).to render_template :index }

      it("sets @users to the set of logged in users") { expect(assigns(:users).size).to eq(3) }
    end

    context "each user has a single question" do
      it "orders the users in @users by oldest question" do
        3.times { Fabricate(:user) }

        User.all.each_with_index do |u, index|
          q = Fabricate(:question, user: u)
          q.created_at = index.days.ago
          q.save
        end

        get :index
        expect(assigns(:users)[0]).to eq(User.last)
      end
    end

    context "some users have missing questions" do
      it "orders the users in @users by oldest question" do
        5.times { Fabricate(:user) }
        User.all.each_with_index do |u, index|
          if (index != 3)
            q = Fabricate(:question, user: u)
            q.created_at = index.days.ago
            q.save
          end
        end

        get :index
        expect(assigns(:users)[0]).to eq(User.last)
      end

      it "orders the users in @users by oldest question if last user has no questions" do
        5.times { Fabricate(:user) }
        User.all.each_with_index do |u, index|
          if (index != 4)
            q = Fabricate(:question, user: u)
            q.created_at = index.days.ago
            q.save
          end
        end

        get :index
        expect(assigns(:users)[0]).to eq(User.find(4))
      end

      it "orders the users in @users by oldest question if first and last users has no questions" do
        5.times { Fabricate(:user) }
        User.all.each_with_index do |u, index|
          if (index != 0) && (index != 4)
            q = Fabricate(:question, user: u)
            q.created_at = index.days.ago
            q.save
          end
        end

        get :index
        expect(assigns(:users)[0]).to eq(User.find(4))
      end

      it "orders @users when each user has a variety of questions posted" do
        5.times { Fabricate(:user) }
        User.all.each_with_index do |u, index|
          q = Fabricate(:question, user: u)
          q.created_at = 2.days.ago
          q.save

          q = Fabricate(:question, user: u)
          q.created_at = 1.days.ago
          q.save
          
          q = Fabricate(:question, user: u)
          q.created_at = 3.days.ago
          q.save
        end

        forced_old_question = User.find(4).questions[2]
        forced_old_question.created_at = 4.days.ago
        forced_old_question.save

        get :index

        expect(assigns(:users)[0]).to eq(forced_old_question.user)
      end


    end


  end


  describe "GET new" do
    it "redirects to the home screen for already logged in user" do
      user = Fabricate(:user)
      session[:userid] = user.id

      get :new
      expect(response).to redirect_to home_path
    end

    it "renders new user template if user not already logged in" do
      get :new
      expect(response).to render_template :new
    end

    it "sets @user to a blank user" do
      get :new
      expect(assigns(:user)).to be_a(User)
    end

  end # GET new

  describe "POST create" do
    context "valid user creation" do
      before { post :create, user: { username: "Alice Doe" } }

      it("redirects to the home path") { expect(response).to redirect_to home_path }
      it("flashes a success message") { expect_success_flash }

      it "creates a new user" do
        expect(User.all.size).to eq(1)
        expect(User.first.username).to eq("Alice Doe")
      end

      it("logs the user in") { expect(session[:userid]).to eq(User.find_by(username: "Alice Doe").id) }

    end

    context "username already taken" do
      before do
        User.create(username: "Alice Doe")
        post :create, user: { username: "Alice Doe" }
      end

      it("renders the new template") { expect(response).to render_template :new }
      it("does not create a new user") { expect(User.all.size).to eq(1) }
      it("does not log in the user") { expect(session[:userid]).to be_nil }

    end

  end # POST create

  describe "GET destroy" do

    context "no signed in user" do
      before do
        Fabricate(:user)
        get :destroy
      end

      it("redirects to signin page") { expect(response).to redirect_to signin_path }
      it("flashes a danger message") { expect_danger_flash }
      it("does not destroy a user") { expect(User.all.size).to eq(1) }
    end

    context "signed in user" do
      context "basic behavior" do
        before do
          set_current_user
          get :destroy
        end

        it("redirects to signin page") { expect(response).to redirect_to root_path }
        it("flashes a success message") { expect_success_flash }
        it("logs out the current user") { expect(session[:userid]).to be_nil }
      end

      context "user and question destruction" do
        before do
          @user1 = Fabricate(:user)
          @user2 = Fabricate(:user)
          
          @question1 = Fabricate(:question, user: @user1)
          @question2 = Fabricate(:question, user: @user1)
          
          @question3 = Fabricate(:question, user: @user2)
          @question4 = Fabricate(:question, user: @user2)

          set_current_user
          @to_destroy_user = get_current_user
          @question5 = Fabricate(:question, user: @to_destroy_user)
          @question6 = Fabricate(:question, user: @to_destroy_user)
        end

        it "destroys the user record of the current user" do
          expect(User.all.size).to eq(3)
          get :destroy
          expect(User.all.size).to eq(2)
        end

        it "destroys all questions associated with the destroyed user" do
          expect(Question.all.size).to eq(6)
          get :destroy
          expect(Question.all.size).to eq(4)
        end


        it "the active question, if there was an active question by the destroyed user" do
          @question5.claimed = true
          @question5.reload

          expect(Question.all.size).to eq(6)
          get :destroy
          expect(Question.all.size).to eq(4)
        end


      end # user and question destruction

    end # signed in user

  end # GET destroy

end
