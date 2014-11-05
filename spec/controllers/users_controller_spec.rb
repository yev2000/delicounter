require 'rails_helper'

describe UsersController do
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

  end

end
