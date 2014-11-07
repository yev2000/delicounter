class UsersController < ApplicationController

  before_action :require_user, only: [:destroy]

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

  def destroy
    current_user_get.destroy
    session[:userid] = nil
    current_user_clear
    clear_original_action
    flash[:success] = "You have logged out"
    redirect_to root_path
  end

  def index
    @users = User.all.to_a
    @users.sort! { |x,y| User.compare_by_oldest_question(x,y) }
  end

  private

  def user_params
    params.require(:user).permit(:username)
  end

end
