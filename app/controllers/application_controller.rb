class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :timeago, :icon_action_link, :icon_action_link_large, :current_user_get, :current_admin_user_get, :current_user_clear, :logged_in?, :admin_logged_in?, :clear_original_action
  
  ########################
  #
  # Links
  #
  ########################
  
  def timeago(time, options = {})
    options[:class] ||= "timeago"
    view_context.content_tag(:abbr, time.to_s, options.merge(:title => time.getutc.iso8601)) if time
  end


  def icon_action_link(icon_name, action_name, url_path="", html_options={})
    link_to_string = '<span class="pull-right" style="margin-right: 5px; font-size:12px;">' + action_name + '&nbsp;&nbsp;<span class="glyphicon glyphicon-' + icon_name + '"></span></span>'

    # learned about view_context from the following stack overflow article
    # http://stackoverflow.com/questions/3843509/how-to-mixin-and-call-link-to-from-controller-in-rails
    view_context.link_to link_to_string.html_safe, url_path, html_options
  end

  def icon_action_link_large(icon_name, action_name, url_path="", html_options={})
    link_to_string = '<span class="pull-left" style="margin-right: 5px; font-size:22px;">' + action_name + '&nbsp;&nbsp;<span class="glyphicon glyphicon-' + icon_name + '"></span></span>'

    # learned about view_context from the following stack overflow article
    # http://stackoverflow.com/questions/3843509/how-to-mixin-and-call-link-to-from-controller-in-rails
    view_context.link_to link_to_string.html_safe, url_path, html_options
  end

  ########################
  #
  # Redirection
  #
  ########################

  def clear_original_action
    session[:prior_url] = nil
  end

  def redirect_to_original_action
    # the user was going somewhere before being intercepted,
    # then send them there now.  Otherwise, we direct to the
    # home path.
    if session[:prior_url]
      redirect_to session[:prior_url]
      clear_original_action
    else
      redirect_to home_path
    end
  end

  ########################
  #
  # User Management
  #
  ########################

  def current_user_get
    @current_user ||= User.find_by(id: session[:userid]) if session[:userid]
  end

  def current_admin_user_get
    @current_admin_user ||= Admin.find_by(id: session[:adminid]) if session[:adminid]
  end

  def logged_in?
    !!(current_user_get)
  end

  def admin_logged_in?
    !!(current_admin_user_get)
  end

  def current_user_clear
    @current_user = nil
  end

  def current_admin_user_clear
    @current_admin_user = nil
  end

  def require_user
    if !logged_in?
      flash[:danger] = "Must be logged in to do this"

      ## is there a way to know what the current path is, so
      ## that once we've logged in we can redirect to there?
      ## after having been redirecte to the login?
      session[:prior_url] = request.get? ? request.path : nil

      redirect_to signin_path
    else
      clear_original_action
    end
  end

  def require_user_or_admin
    if !logged_in? && !admin_logged_in?
      flash[:danger] = "Must be logged in or an admin to do this"

      ## is there a way to know what the current path is, so
      ## that once we've logged in we can redirect to there?
      ## after having been redirecte to the login?
      session[:prior_url] = request.get? ? request.path : nil

      redirect_to signin_path
    else
      clear_original_action
    end
  end

  def require_admin_user
    if !admin_logged_in?
      flash[:danger] = "Must be an admin to do this"

      ## is there a way to know what the current path is, so
      ## that once we've logged in we can redirect to there?
      ## after having been redirecte to the login?
      session[:prior_url] = request.get? ? request.path : nil

      redirect_to root_path
    else
      clear_original_action
    end
  end

end
