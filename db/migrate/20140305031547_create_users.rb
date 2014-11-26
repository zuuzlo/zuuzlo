class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :password_digest
      t.string :full_name
      t.string :token
      t.boolean :admin
      t.string :cashback_id
      t.string :paypal_email
      t.string :slug
      t.boolean :verified_email
      t.timestamps
    end
    add_index :users, :slug
  end
end
