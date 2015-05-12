class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  before_validation :generate_cashback_id, on: [:create]

  validates :cashback_id, presence: true, uniqueness: true

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable
  extend FriendlyId
  friendly_id :email, use: :slugged

  has_and_belongs_to_many :stores
  has_and_belongs_to_many :coupons 
  has_many :activities

  private
    def generate_cashback_id
      self.cashback_id = Devise.friendly_token.first(8)
    end
end
