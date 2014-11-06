class Admin < ActiveRecord::Base
  has_secure_password validations: false

  validates :username, uniqueness: true, presence: true
end
