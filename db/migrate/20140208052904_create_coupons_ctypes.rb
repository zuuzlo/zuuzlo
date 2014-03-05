class CreateCouponsCtypes < ActiveRecord::Migration
  def change
    create_table :coupons_ctypes do |t|
      t.belongs_to :coupon, index: true
      t.belongs_to :ctype, index: true
    end
  end
end
