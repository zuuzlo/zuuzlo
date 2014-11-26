class Activity < ActiveRecord::Base

  validates :user_id, presence: true
  validates :store_id, presence: true  
end
