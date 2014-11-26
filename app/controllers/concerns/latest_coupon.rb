module LatestCoupon
  extend ActiveSupport::Concern

  def latest_coupon_date(category)
    last_coupon = category.coupons.order("created_at").last
    I18n.l(last_coupon.created_at, :format => :w3c)
  end
end