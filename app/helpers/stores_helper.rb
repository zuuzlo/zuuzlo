module StoresHelper

  def number_of_coupons(store)
    Coupon.where(["store_id = :store AND end_date >= :time ", { :store => store.id, :time => DateTime.current }]).count
  end

end
