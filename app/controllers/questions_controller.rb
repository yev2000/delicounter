class QuestionsController < ApplicationController

  before_action :require_user, except: [:index, :show, :claim, :unclaim, :destroy]
  before_action :require_user_or_admin, only: [:destroy]
  before_action :require_admin_user, only: [:claim, :unclaim]

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
    @question = verify_question_id(params[:id], (admin_logged_in? ? false : true))
    return unless @question    
    
    username = @question.user.username
    @question.destroy

    if (admin_logged_in?)
      flash[:success] = "User #{username}'s question (#{@question.title}) was deleted"
    else
      flash[:success] = "Your question (#{@question.title}) was deleted"
    end

    redirect_to questions_path
  
  end

  def unclaim
    question = verify_question_id(params[:id], false)
    return unless question

    if (question != Question.active_question)
      flash[:danger] = "You can only unclaim an already claimed question"
      redirect_to questions_path
    else
      question.claimed = false
      question.save
      flash[:success] = "You have unclaimed the question (#{question.title})."
      redirect_to questions_path
    end
  end

  def claim
    question = verify_question_id(params[:id], false)
    return unless question

    if (Question.active_question && (question != Question.active_question))
      flash[:danger] = "There is already claimed question."
      redirect_to questions_path
    else
      question.claimed = true
      question.save
      flash[:success] = "You have claimed the question (#{question.title})."
      redirect_to questions_path
    end

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
      flash[:danger] = "You cannot edit or delete another user's question"
      redirect_to questions_path
      return nil
    when (question == Question.active_question) && for_edit_or_destroy
      flash[:danger] = "You cannot edit or delete a question that has already been claimed by a TA"
      redirect_to questions_path
      return nil
    else
      return question
    end
  end

end
