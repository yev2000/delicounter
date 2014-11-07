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
      else
        oldest
      end
    end
  end # oldest_question_time

  def self.compare_by_oldest_question(user1, user2)
    u1_time = user1.oldest_question_time
    u2_time = user2.oldest_question_time
    
    case
    when u1_time == u2_time
      0
    when u1_time.nil?
      1
    when u2_time.nil?
      -1
    else
      u1_time <=> u2_time
    end

  end


end
