require 'spec_helper'

describe UsersController do

  describe "GET 'new'" do
    it "returns http success" do
      get 'new'
      response.should be_success
    end

    it "sets @user to User new" do
      get :new
      expect(assigns(:user)).to be_instance_of(User)
    end
  end

  describe "POST 'create'" do
    context "signup successful" do
      before do
        post :create, user: { email: 'test@test.com', password: 'password', password_confirmation: 'password', full_name: 'Test Test'}
      end

      it "creates a new @user" do
        expect(assigns(:user)).to be_instance_of(User)
      end

      it "should save new user" do
        expect(User.count).to eq(1)
      end

      it "should send an email" do
        ActionMailer::Base.deliveries.should_not be_empty
      end

      it "email to right recipient" do
        message = ActionMailer::Base.deliveries.last
        message.to.should == [User.find(1).email]
      end

      it "email has right content" do
        message = ActionMailer::Base.deliveries.last
        message.body.should include(User.find(1).full_name)
      end

      it "the flash success is set" do
        expect(flash[:success]).to be_present
      end

      it "redirects to static page Welcome"

    end
    context "signup fails" do
      before do
        post :create, user: { email: 'test@test.com', full_name: 'Test Test'}
      end

      it "the flash danger is set" do
        expect(flash[:danger]).to be_present
      end

      it "renders new template" do
        expect(response).to render_template :new
      end
    end
  end

  describe "GET 'register_confirmation'" do
    context "users token matches" do
      let(:user1) { Fabricate(:user, email: 'test@test.com', password: 'password', password_confirmation: 'password', full_name: 'Test Test') }
      before do
        get :register_confirmation, token: user1.token
      end
      
      it "finds user from token" do
        expect(assigns(:user).token).to eq(user1.token)
      end

      it "sets verified_token to true" do
        expect(assigns(:user).verified_email).to be_true
      end

      it "sets flash success" do
        expect(flash[:success]).to be_present
      end

      it "redirects to sign in" do
        expect(response).to redirect_to sign_in_path
      end
    end

    context "users token doesn't match" do
      let(:user1) { Fabricate(:user, email: 'test@test.com', password: 'password', password_confirmation: 'password', full_name: 'Test Test') }
      before do
        get :register_confirmation, token: '123434'
      end

      it "sets flash danger" do
        expect(flash[:danger]).to be_present
      end

      it "redirects to expired token"
    end
  end

  describe "GET 'show'" do
    let(:other_user) { Fabricate(:user, verified_email: TRUE) }

    context "with authenticated user" do
      before do
        set_current_user
      end

      it "load @user for other user not in session" do
        get :show, { id: other_user.id }
        expect(assigns(:user)).to eq(other_user)
      end

      it "load @user favorite coupons"

      it "loads @user favorite stores"

      it "loads @user clicks"

      it "loads @user transaction summary"
    end

    context "user email not verified" do
      let(:bad_user) { Fabricate(:user) }
      it "doesn't load @user" do
        get :show,  { id: bad_user.id }
        expect(assigns(:user)).to eq(nil)
      end
    end
  end
end
