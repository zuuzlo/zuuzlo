class User < ActiveRecord::Base
  include Tokenable

  has_secure_password
  VALID_EMAIL_REGEX =  /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: true
  validates :full_name, presence: true
  validates :password, presence: true, on: :create, length: {minimum: 6}

  extend FriendlyId
  friendly_id :email, use: :slugged

  has_and_belongs_to_many :stores
  has_and_belongs_to_many :coupons

  has_many :activities
end
