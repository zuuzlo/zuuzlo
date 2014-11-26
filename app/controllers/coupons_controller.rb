class CouponsController < ApplicationController
  include CouponCodesOffers
  
  def index
  end

  def search
    @coupons = Coupon.search_by_title(params[:search_term])
    @term = params[:search_term]
    @coupon_codes = coupon_codes(@coupons)
    @coupon_offers = coupon_offers(@coupons)
  end

  def toggle_favorite
    @coupon = Coupon.find_by_id(params[:coupon_id])
    @refer_controller =  Rails.application.routes.recognize_path(request.referrer)[:controller]
    if current_user.coupon_ids.include?(@coupon.id)
      current_user.coupons.delete(@coupon)
      flash[:success] = "Coupon has been removed from your favorites."
    else
      current_user.coupons << @coupon
      flash[:success] = "Coupon has been added to your favorites."
    end
    
    respond_to do |format|
      format.html do  
        redirect_to :back
      end
      format.js
    end
  end

  def tab_all
    respond_to do |format|
      format.html do  
        redirect_to :back
      end
      format.js
    end
  end

  def tab_coupon_codes
    respond_to do |format|
      format.html do  
        redirect_to :back
      end
      format.js
    end
  end

  def tab_offers
    respond_to do |format|
      format.html do  
        redirect_to :back
      end
      format.js
    end
  end

  def coupon_link
    coupon = Coupon.find_by_id(params[:id])
    if logged_in?
      if coupon.coupon_source_id == 1
        link = coupon.link + "&u1=" + current_user.cashback_id
      else
        link = coupon.link + "?sid=" + current_user.cashback_id
      end
    else
      if coupon.coupon_source_id == 1
        link = coupon.link + "&u1=zuuzlo"
      else
        link = coupon.link + "?sid=zuuzlo"
      end
    end
    
    redirect_to link
  end
end
