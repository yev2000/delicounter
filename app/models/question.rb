class Question < ActiveRecord::Base
  include ActionView::Helpers::DateHelper
  include DeliSupport
  
  belongs_to :user
  
  validates :title, :body, presence: true

  def age_string
    time_ago_in_words(self.created_at) + " ago"
  end

  def posted_on_string
    " on " + pretty_time_string(created_at) + " (#{time_ago_in_words(created_at)} ago)"
  end


  def self.active_question
    Question.find_by(claimed: true)
  end

  def self.unclaimed_questions
    return_set = Question.all.where("claimed = 'f'").order(created_at: :asc)
    return_set.size == 0 ? nil : return_set
  end

  def self.get_order_position_string(question)
    question_list = unclaimed_questions

    return "not in the queue" unless question_list

    index = question_list.find_index(question)
    case index
    when nil
      return "not in the queue"
    when 0
      return "next in the queue"
    else
      return (index + 1).ordinalize
    end
  end

end
