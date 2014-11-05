class Question < ActiveRecord::Base
  include ActionView::Helpers::DateHelper

  belongs_to :user
  
  validates :title, :body, presence: true

  def age_string
    time_ago_in_words(self.created_at) + " ago"
  end
end
