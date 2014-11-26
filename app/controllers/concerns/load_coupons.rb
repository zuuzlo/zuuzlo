module LoadCoupons
  extend ActiveSupport::Concern
  include CouponCodesOffers

  def load_coupons(title)
    @coupons = title.coupons.where(["end_date >= :time", { :time => DateTime.current }]).paginate(:page => params[:page]).order( 'end_date ASC' )
  end

  def load_coupon_offer_code(coupons)
    @codes_count = coupon_codes(coupons)
    @offers_count = coupon_offers(coupons)
  end

  def load_cal_picts(coupons)
    cals = coupons.collect(&:id).sample(5)
    @cal_coupons = Coupon.find(cals)
  end

  def load_all_coupons(title)
    load_coupons(title)
    load_coupon_offer_code(@coupons)
    load_cal_picts(@coupons)
  end
end