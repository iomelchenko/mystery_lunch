# frozen_string_literal: true

class SessionsController < ApplicationController
  def new; end

  def create
    user =
      User.where(role: :admin).find_by(email: params[:session][:email].downcase)

    if user&.authenticate(params[:session][:password])
      log_in user

      redirect_back_or users_url
    else
      flash.now[:danger] = 'Invalid email/password combination'

      render 'new'
    end
  end

  def destroy
    log_out

    redirect_to root_url
  end
end
