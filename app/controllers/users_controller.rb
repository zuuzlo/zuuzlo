class UsersController < ApplicationController
  include CouponCodesOffers
  before_filter :authenticate_user!, only:[:show]
  
  def show
    @user = current_user
    @stores = @user.stores
    @coupons = @user.coupons
    @codes_count = coupon_codes(@coupons)
    @offers_count = coupon_offers(@coupons)
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end