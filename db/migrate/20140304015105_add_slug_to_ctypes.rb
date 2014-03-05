class AddSlugToCtypes < ActiveRecord::Migration
  def change
    add_column :ctypes, :slug, :string
    add_index :ctypes, :slug
  end
end
