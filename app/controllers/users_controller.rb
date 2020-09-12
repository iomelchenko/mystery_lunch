# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :logged_in_user, :verify_role

  def index
    @users =
      User
      .all
      .includes(:department, avatar_attachment: :blob)
      .order(id: :desc)
      .paginate(page: params[:page], per_page: 10)
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def edit
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(user_params)

    if @user.save
      # allocate new user to the existing pair
      flash[:success] = 'User was successfully created.' # Nice to tmplement it with i18n
      redirect_to @user
    else
      render 'new'
    end
  end

  def update
    @user = User.find(params[:id])

    if @user.update(user_params)
      flash[:success] = 'User was successfully updated.'

      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    @user = User.find(params[:id])

    if @user.update(state: :inactive)
      UsersManager.new.delete_from_meeting(@user.id)

      flash[:success] = 'User was deactivated.'
    end

    redirect_to @user
  end

  private

  def user_params
    params
      .require(:user)
      .permit(:name, :email, :password, :password_confirmation, :department_id, :role, :state, :avatar)
      .then do |permitted|
        permitted.delete(:password) unless permitted[:password].present?
        permitted.delete(:password_confirmation) unless permitted[:password_confirm].present?

        permitted
      end
  end

  def verify_role
    return if current_user.admin?

    flash[:alert] = 'You cannot access this resource.'

    redirect_to root_url
  end
end
