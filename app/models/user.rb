class User < ActiveRecord::Base

  has_many :questions, dependent: :destroy
  validates :username, uniqueness: true, presence: true

end
