class QuestionsController < ApplicationController

  before_action :require_user, except: [:index, :show]

  def index
    @unclaimed_questions = Question.all.where("claimed = 'f'").order(created_at: :asc)
    @active_question = Question.find_by(claimed: true)
  end

  def show
    @question = verify_question_id(params[:id], false)
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

  def edit
    @question = verify_question_id(params[:id])
  end

  def update
    @question = verify_question_id(params[:id])
    return unless @question

    if (@question.update(question_params))
      flash[:success] = "Your question has been updated."
      redirect_to questions_path
    else
      render :edit
    end
  end

  def destroy
    @question = verify_question_id(params[:id])
    return unless @question    
    
    @question.destroy
    flash[:success] = "Your question (#{@question.title}) was deleted"
    redirect_to questions_path
  
  end

  private

  def question_params
    params.require(:question).permit(:title, :body)
  end

  def verify_question_id(id_string, for_edit_or_destroy=true)
    question = Question.find_by(id: id_string)
    
    case
    when question.nil?
      flash[:danger] = "There is no such question in the system"
      redirect_to questions_path
      return nil
    when (question.user != current_user_get) && for_edit_or_destroy
      flash[:danger] = "You cannot edit another user's question"
      redirect_to questions_path
      return nil
    when (question == Question.active_question) && for_edit_or_destroy
      flash[:danger] = "You cannot edit a question that has already been claimed by a TA"
      redirect_to questions_path
      return nil
    else
      return question
    end
  end

end
