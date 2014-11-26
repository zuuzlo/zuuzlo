class CreateJoinTableCouponUser < ActiveRecord::Migration
  def change
    create_join_table :coupons, :users do |t|
      t.index :coupon_id
      t.index :user_id
    end
  end
end
