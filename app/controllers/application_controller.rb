# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include SessionHelper

  private

  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = 'Please log in.'

    redirect_to login_url
  end
end
