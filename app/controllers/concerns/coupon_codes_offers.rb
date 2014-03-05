module CouponCodesOffers
  extend ActiveSupport::Concern

  def coupon_codes(coupons)
    codes = []
    coupons.each do | coupon |
      codes << coupon if coupon.code
    end
    codes
  end

  def coupon_offers(coupons)
    offers = []
    coupons.each do | coupon |
      offers << coupon unless coupon.code
    end
    offers
  end
end