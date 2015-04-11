module LoadCoupons
  extend ActiveSupport::Concern
  include CouponCodesOffers

  def load_coupons(title)
    @offers_count = title.coupons.where(["end_date >= :time", { :time => DateTime.current}]).where(code: nil).count
    total_count = title.coupons.where(["end_date >= :time", { :time => DateTime.current }]).count
    @codes_count = total_count - @offers_count
    @coupons = title.coupons.where(["end_date >= :time", { :time => DateTime.current }]).paginate(:page => params[:page]).order( 'end_date ASC' )
  end

  def load_cal_picts(coupons)
    cals = coupons.collect(&:id).sample(5)
    @cal_coupons = Coupon.find(cals)
  end

  def load_all_coupons(title)
    load_coupons(title)
    load_cal_picts(@coupons)
  end
end