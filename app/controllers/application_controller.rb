class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :icon_action_link
  
  ########################
  #
  # Links
  #
  ########################

  def icon_action_link(icon_name, action_name, url_path="")
    link_to_string = '<span class="pull-right" style="margin-right: 5px; font-size:12px;"><span class="glyphicon glyphicon-' + icon_name + '"></span> ' + action_name + "</span>"

    # learned about view_context from the following stack overflow article
    # http://stackoverflow.com/questions/3843509/how-to-mixin-and-call-link-to-from-controller-in-rails
    view_context.link_to link_to_string.html_safe, url_path
  end

end
