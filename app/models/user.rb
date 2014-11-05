class User < ActiveRecord::Base

  has_many :questions
  validates :username, uniqueness: true, presence: true

end
