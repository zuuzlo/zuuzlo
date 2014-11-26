class SessionsController < ApplicationController
  
  def new
    redirect_to user_path(session[:user_id]) if current_user
  end

  def create
    user = User.find_by_email(params[:email])

    if user && user.authenticate(params[:password])
      if user.verified_email == TRUE
        session[:user_id] = user.id
        flash[:success] = "You are now signed in!"
        redirect_to user_path(user.slug)
      else
        flash[:danger] = "Please confirm your email!"
        redirect_to sign_in_path
      end
    else
      flash[:danger] = "There is an error with your sign in!"
      redirect_to sign_in_path
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:danger] = "You have signed out."
    redirect_to stores_path
  end
end
