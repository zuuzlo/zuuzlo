module CouponCodesOffers
  extend ActiveSupport::Concern

  def coupon_codes(coupons)
    codes = 0
    coupons.each do | coupon |
      codes = codes + 1 if coupon.code
    end
    codes
  end

  def coupon_offers(coupons)
    offers = 0
    coupons.each do | coupon |
      offers = offers + 1 unless coupon.code
    end
    offers
  end
end