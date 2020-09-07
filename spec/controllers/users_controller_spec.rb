# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:risk_department) { create :department, name: 'risk' }
  let!(:user) { create :user, department: risk_department }
  let(:password) { Faker::Internet.password(min_length: 6) }

  let(:valid_attributes) do
    {
      name: Faker::Name.first_name,
      state: :active,
      department_id: risk_department.id,
      password: password,
      password_confirmation: password,
      email: Faker::Internet.email
    }
  end

  let(:invalid_attributes) do
    {
      name: Faker::Name.first_name,
      state: :active,
      department_id: risk_department.id,
      password: '',
      password_confirmation: password,
      email: ''
    }
  end

  before do
    allow_any_instance_of(described_class).to receive(:logged_in_user).and_return(true)
    allow_any_instance_of(described_class).to receive(:verify_role).and_return(true)
  end

  describe 'GET #index' do
    it 'assigns all users as @users' do
      get :index, params: {}

      expect(assigns(:users)).to eq([user])
    end
  end

  describe 'GET #show' do
    it 'assigns the requested user as @user' do
      get :show, params: { id: user.to_param }

      expect(assigns(:user)).to eq(user)
    end
  end

  describe 'ET #new' do
    it 'assigns a new user as @user' do
      get :new, params: {}

      expect(assigns(:user)).to be_a_new(User)
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested user as @user' do
      get :edit, params: { id: user.id }

      expect(assigns(:user)).to eq(user)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new user' do
        expect { post :create, params: { user: valid_attributes } }.to change(User, :count).by(1)
      end

      it 'assigns a newly created user as @user' do
        post :create, params: { user: valid_attributes }

        expect(assigns(:user)).to eq(User.last)
        expect(assigns(:user)).to be_persisted
      end

      it 'redirects to the created user' do
        post :create, params: { user: valid_attributes }

        expect(response).to redirect_to(User.last)
      end
    end

    context 'with invalid params' do
      it 'assigns a newly created but unsaved user as @user' do
        post :create, params: { user: invalid_attributes }

        expect(assigns(:user)).to be_a_new(User)
      end

      it 're-renders the new template' do
        post :create, params: { user: invalid_attributes }

        expect(response).to render_template('new')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) do
        valid_attributes.merge(email: 'test@example.com')
      end

      it 'updates the requested user' do
        put :update, params: { id: user.to_param, user: new_attributes }

        expect(user.reload.email).to eq('test@example.com')
      end

      it 'assigns the requested user as @user' do
        put :update, params: { id: user.to_param, user: valid_attributes }

        expect(assigns(:user)).to eq(user)
      end

      it 'redirects to the user' do
        put :update, params: { id: user.to_param, user: valid_attributes }

        expect(response).to redirect_to(user)
      end
    end

    context 'with invalid params' do
      it 'assigns the user as @user' do
        put :update, params: { id: user.to_param, user: invalid_attributes }

        expect(assigns(:user)).to eq(user)
      end

      it 're-renders the edit template' do
        put :update, params: { id: user.to_param, user: invalid_attributes }

        expect(response).to render_template('edit')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'does not destroy the requested user' do
      expect { delete :destroy, params: { id: user.to_param } }.to change(User, :count).by(-0)
    end

    it 'redirects to the user url' do
      delete :destroy, params: { id: user.to_param }

      expect(response).to redirect_to(user_url)
    end

    it 'deactivates user' do
      delete :destroy, params: { id: user.to_param }

      expect(user.reload.state).to eq('inactive')
    end
  end
end
