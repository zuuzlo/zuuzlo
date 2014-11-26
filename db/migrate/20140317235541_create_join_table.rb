class CreateJoinTable < ActiveRecord::Migration
  def change
    create_join_table :stores, :users do |t|
      t.index :store_id
      t.index :user_id
    end
  end
end
