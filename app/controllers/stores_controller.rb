class StoresController < ApplicationController
  include CouponCodesOffers

  def index
    @stores = Store.friendly.to_a
    @stores_featured = Store.with_coupons.limit(12)

    @store_array = []
    @stores.each do | store |
      @store_array << store.name
    end
  end

  def show
    @store = Store.friendly.find(params[:id])
    @coupons = Coupon.where(["store_id = :store AND end_date >= :time ", { :store => @store.id, :time => DateTime.current }]).order( 'end_date ASC' )

    @coupon_codes = coupon_codes(@coupons)
    @coupon_offers = coupon_offers(@coupons)
  end

end
