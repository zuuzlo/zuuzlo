require 'spec_helper'

describe SessionsController do

  describe "GET 'new'" do
    
    it "redirects to user page for logged in user" do
      session[:user_id] = Fabricate(:user).id
      get :new
      expect(response).to redirect_to user_path(session[:user_id])
    end

    it "renders new for unathenticated users" do
      get :new
      expect(response).to render_template :new
    end
  end

  describe "Post 'create'" do
    context "with valid credials" do
      let(:kirk) { kirk = Fabricate(:user, verified_email: TRUE) }
      before do
        post :create, { email: kirk.email, password: kirk.password }
      end

      it "puts user in session" do
        expect(session[:user_id]).to eq(kirk.id)
      end

      it "sets the notice" do
        flash[:success] = "You successfully signed in."
      end

      it "redirects to user page" do
        expect(response).to redirect_to user_path(kirk.id)
      end
    end

    context "without verified email" do
      let(:kirk) { kirk = Fabricate(:user) }
      before do
        post :create, { email: kirk.email, password: kirk.password }
      end

      it "does not put user in session" do
        expect(session[:user_id]).to eq(nil)
      end

      it "redirects to sign in path" do
        expect(response).to redirect_to sign_in_path
      end

      it "sets danger notice" do
        expect(flash[:danger]).to be_present
      end
    end

    context "with invalid credentials" do
      let(:kirk) { kirk = Fabricate(:user) }
      before do
        post :create, { email: kirk.email, password: '123456' }
      end

      it "rediret to sign_in path" do
        expect(flash[:danger]).to be_present
      end

      it "sets danger notice" do
        expect(flash[:danger]).to be_present
      end
    end
  end

  describe "Get destroy" do

    let(:kirk) { Fabricate(:user) }

    before do
      get :destroy
    end
    it "sets session user to nil" do
      expect(session[:user_id]).to eq(nil)
    end
    it "flashes alert" do
      expect(flash[:alert]).not_to be_blank
    end
    it "redirects to root path" do
      expect(response).to redirect_to root_path
    end
  end
end
