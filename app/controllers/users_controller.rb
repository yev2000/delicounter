class UsersController < ApplicationController

  def new
    redirect_to home_path if logged_in?
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if (@user.save)
      session[:userid] = @user.id
      flash[:success] = "You have been logged in, #{@user.username}"
      redirect_to_original_action
    else
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit(:username)
  end

end
