class CategoriesController < ApplicationController
  include CouponCodesOffers
  def show
    @category = Category.friendly.find(params[:id])
    @coupons = @category.coupons.where(["end_date >= :time ", { :time => DateTime.current }]).order( 'end_date ASC' )
    
    @coupon_codes = coupon_codes(@coupons)
    @coupon_offers = coupon_offers(@coupons)
  end
end