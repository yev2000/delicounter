class QuestionsController < ApplicationController

  before_action :require_user, except: [:index]

  def index
    @unclaimed_questions = Question.all.where("claimed = 'f'").order(created_at: :asc)
    @active_question = Question.find_by(claimed: true)
  end

  def new
    @question = Question.new
  end

  def create
    @question = Question.new(question_params)
    @question.user = current_user_get
    if (@question.save)
      flash[:success] = "Your question is now in #{Question.get_order_position_string(@question)} place"
      redirect_to questions_path
    else
      render :new
    end
  end

  private

  def question_params
    params.require(:question).permit(:title, :body)
  end

end
