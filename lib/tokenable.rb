module Tokenable
  extend ActiveSupport::Concern

  included do
    before_create :generate_token, :generate_cashback_id

    def generate_token
      self.token = SecureRandom.urlsafe_base64
    end

    def generate_cashback_id
      self.cashback_id = generate_token.slice(1..8)
    end
  end
end