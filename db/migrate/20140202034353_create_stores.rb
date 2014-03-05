class CreateStores < ActiveRecord::Migration
  def change
    create_table :stores do |t|
      t.string :name
      t.integer :id_of_store
      t.text :description
      t.text :home_page_url
      t.boolean :active_commission
      t.string :store_img
      t.float :commission
      t.timestamps
    end
  end
end
