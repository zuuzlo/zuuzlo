class CreateCategoriesCoupons < ActiveRecord::Migration
  def change
    create_table :categories_coupons do |t|
      t.belongs_to :category, index: true
      t.belongs_to :coupon, index: true
    end
  end
end
