class User < ActiveRecord::Base

  has_many :questions, dependent: :destroy
  validates :username, uniqueness: true, presence: true

  def oldest_question_time
    return nil unless questions.size > 0

    return questions.inject(-1) do |oldest, question|
      if (oldest == -1)
        oldest = question.created_at
      elsif (oldest > question.created_at)
        oldest = question.created_at
      end
    end
  end # oldest_question_time

end
