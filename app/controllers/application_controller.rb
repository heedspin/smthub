class ApplicationController < ActionController::Base
  helper_method :current_user_session, :current_user
  before_filter :set_current_user

  def current_user_session
    @current_user_session ||= UserSession.find
  end

  def current_user
    @current_user ||= current_user_session.try(:record)
  end

  def set_current_user
    Authorization.current_user = current_user
  end
end
