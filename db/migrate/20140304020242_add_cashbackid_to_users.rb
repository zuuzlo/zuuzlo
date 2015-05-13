class AddCashbackidToUsers < ActiveRecord::Migration
  def change
    add_column :users, :cashback_id, :string
  end
end
