class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery #with: :exception

  after_filter :flash_to_headers
  helper_method :current_user, :logged_in?, :require_user

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def logged_in?
    !!current_user #!! maks's sure you return bool will not return nil
  end

  def require_user
    unless logged_in?
      flash[:danger] = "You must be logged in to perform that action!"
      redirect_to sign_in_path
    end
  end

 
  private
 
  def flash_to_headers
    return unless request.xhr?
    msg = flash_message
    #replace german umlaute encoded in utf-8 to html escaped ones
    #msg = msg.gsub("ä","&auml;").gsub("ü","&uuml;").gsub("ö","&ouml;").gsub("Ä","&Auml;").gsub("Ü","&Uuml;").gsub("Ö","&Ouml;").gsub("ß","&szlig;")
    response.headers['X-Message'] = msg
    response.headers["X-Message-Type"] = flash_type.to_s

    flash.discard # don't want the flash to appear when you reload page
  end

  def flash_message
    [:error, :warning, :notice, :success, :danger].each do |type|
      return flash[type] unless flash[type].blank?
    end
    # if we don't return something here, the above code will return "error, warning, notice"
    return ''
  end

  def flash_type
    #:keep will instruct the js to not update or remove the shown message.
    #just write flash[:keep] = true (or any other value) in your controller code
    [:error, :warning, :notice, :success, :keep, :danger].each do |type|
      return type unless flash[type].blank?
    end
    #don't return the array from above which would happen if we don't have an explicit return statement
    #returning :empty will also allow you to easily know that no flash message was transmitted
    return :empty
  end
end
