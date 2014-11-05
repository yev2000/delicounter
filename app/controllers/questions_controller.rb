class QuestionsController < ApplicationController

  def index
    @unclaimed_questions = Question.all.where("claimed = 'f'").order(created_at: :asc)
    @active_question = Question.find_by(claimed: true)
  end


end
