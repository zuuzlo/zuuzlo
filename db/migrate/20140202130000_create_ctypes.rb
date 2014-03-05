class CreateCtypes < ActiveRecord::Migration
  def change
    create_table :ctypes do |t|
      t.string :name
      t.integer :ls_id
      t.timestamps
    end
  end
end
