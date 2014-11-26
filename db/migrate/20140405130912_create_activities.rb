class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      
      t.belongs_to :user
      t.belongs_to :store
      t.integer :clicks
      t.integer :sales_cents
      t.integer :commission_cents
      t.timestamps
    end
  end
end
