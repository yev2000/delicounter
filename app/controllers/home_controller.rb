class HomeController < ApplicationController
  def home
  end

  def front
    redirect_to home_path if (logged_in? || admin_logged_in?)
  end

end
