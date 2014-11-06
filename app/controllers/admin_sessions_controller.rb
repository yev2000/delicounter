class AdminSessionsController < ApplicationController

  def new
    redirect_to home_path if admin_logged_in?
  end

  def create
    admin = Admin.find_by(username: params[:username]) if params[:username]

    if (admin && admin.authenticate(params[:password]))
      # the user was found so set the current user to this and
      # create the session
      session[:adminid] = admin.id

      flash[:success] = "Welcome, administrator #{admin.username}!"

      redirect_to questions_path
    else
      flash[:danger] = "Invalid email or password"

      # save away the username that was entered so that when we
      # render the form again, we will preserve the contents of
      # the username entry field.  Saves the user time if they simply
      # mistyped their password or had a minor type in email.
      @admin_username = params[:username]

      # re-render the login form so that they can re-enter the data.
      render :new
    end
  end # create

  def destroy
    flash[:success] = "Administrator #{current_admin_user_get.username} logged out" if current_admin_user_get
    session[:adminid] = nil

    current_admin_user_clear
    redirect_to root_path
  end


end
