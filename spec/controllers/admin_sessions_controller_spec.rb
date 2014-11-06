require "rails_helper"

describe AdminSessionsController do
  describe "GET new" do
    
    it "redirects to the home screen for already logged in admin user" do
      admin = Fabricate(:admin)
      session[:adminid] = admin.id

      get :new
      expect(response).to redirect_to home_path
    end

    it "renders new admin session template if user not already logged in" do
      get :new
      expect(response).to render_template :new
    end

    it "sets @admin_username to nil" do
      get :new
      expect(assigns(:admin_username)).to be_nil
    end

  end

  describe "POST create" do
    let(:the_admin) { Fabricate(:admin) }

    context "invalid username" do
      before { post :create, username: (the_admin.username + "XX"), password: the_admin.password }

      it("renders new session template") { expect(response).to render_template :new }
      it("sets a danger flash") { expect_danger_flash }
      it("sets @admin_username to user username entered in form") { expect(assigns(:admin_username)).to eq(the_admin.username + "XX") }
    end

    context "invalid password" do
      before { post :create, username: the_admin.username, password: (the_admin.password + "XX") }

      it("renders new session template") { expect(response).to render_template :new }
      it("sets a danger flash") { expect_danger_flash }
      it("sets @admin_username to user username entered in form") { expect(assigns(:admin_username)).to eq(the_admin.username) }
      it("leaves session key for admin_id as nil") { expect(session[:adminid]).to eq(nil) }
    end

    context "valid credentials" do
      before { post :create, username: the_admin.username, password: the_admin.password }

      it("sets admin session ID if admin authenticated") { expect(session[:adminid]).to eq(the_admin.id) }
      it("redirects to questions index if admin authenticated") { expect(response).to redirect_to questions_path }
    end

  end


  describe "GET destroy" do
    context "no logged in user" do
      before { get :destroy }

      it("clears out session information") { expect(session[:adminid]).to eq(nil) }
      it("redirects to application root path") { expect(response).to redirect_to root_path }
    end

    context "logged in user" do
      before do
        admin = Fabricate(:admin)
        session[:adminid] = admin.id
        get :destroy
      end

      it("clears out session information") { expect(session[:adminid]).to eq(nil) }
      it("redirects to application root path") { expect(response).to redirect_to root_path }
      it("sets a success notice") { expect_success_flash }
    end

  end # GET destroy

end

