class Store < ActiveRecord::Base

  validates :name, presence: true
  validates :id_of_store, presence: true, uniqueness: true
  has_many :coupons, -> { order "end_date ASC" }
  has_and_belongs_to_many :users

  has_many :activities
  
  extend FriendlyId
  friendly_id :name, use: :slugged

  def self.with_coupons
    Store.where(active_commission: true).joins(:coupons).where(["end_date >= :time ", { :time => DateTime.current }]).uniq
  end
end