# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  let(:hr_department) { create :department, name: 'hr' }
  let(:user) { create :user, department: hr_department }

  describe 'DELETE #destroy' do
    it 'redirects to the root' do
      @request.session[:user_id] = user.id

      delete :destroy, params: { id: user.id }

      expect(response).to redirect_to(root_path)
    end
  end

  describe 'POST #create' do
    context 'with correct email and password' do
      it 'redirects to users path' do
        @request.session[:email] = user.email

        post :create, params: { session: { email: user.email, password: user.password } }

        expect(response).to redirect_to(users_path)
      end

      it 'set user_id to the session' do
        @request.session[:email] = user.email

        post :create, params: { session: { email: user.email, password: user.password } }

        expect(@request.session[:user_id]).to eq(user.id)
      end
    end

    context 'with incorrect password' do
      it 'redirects to login page' do
        @request.session[:email] = user.email

        post :create, params: { session: { email: user.email, password: 'wrong password' } }

        expect(response).to render_template('new')
      end

      it 'doe not set user_id to the session' do
        @request.session[:email] = user.email

        post :create, params: { session: { email: user.email, password: 'wrong password' } }

        expect(@request.session[:user_id]).to be_nil
      end
    end
  end
end
