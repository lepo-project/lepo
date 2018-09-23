class OutcomesController < ApplicationController
  include ::StickiesController::AllActions
  # ====================================================================
  # Public Functions
  # ====================================================================
  def ajax_update
    @outcome = Outcome.find params[:id]
    @lesson = @outcome.lesson
    @content = @lesson.content

    outcome_manager = @outcome.manager_id == session[:id]
    outcome_status = outcome_manager ? 'submit' : 'return'
    outcome_status = 'self_submit' if @lesson.evaluator_id.zero?
    outcome_form = outcome_params
    outcome_form['status'] = outcome_status
    outcome_form['checked'] = ((outcome_status == 'self_submit') && outcome_manager)

    if (outcome_status != 'self_submit') || outcome_manager
      score = get_score outcome_form
      outcome_form['score'] = score if ((outcome_status == 'self_submit') && outcome_manager) || ((outcome_status == 'return') && !outcome_manager)
      outcome_form['outcome_messages_attributes']['0']['score'] = score
    end
    @outcome.update_attributes(outcome_form)

    # FIXME: PushNotification
    # if @lesson.user_role(session[:id]) == 'evaluator'
    # learner = User.find_by(id: @outcome.manager_id)
    # learner.devices.each do |device|
    #   send_push_notification(device.registration_id)
    # end
    # end

    pg = get_page(@lesson.id, @content)
    get_values
    @sticky = Sticky.new(content_id: @content.id, course_id: @course.id, target_id: pg['file_id'])
    @message_templates = get_message_templates(@course.manager?(session[:id]))

    render 'layouts/renders/main_nav_resource_with_pg', locals: { resource: 'layouts/assignment_page', pg: pg }
  end

  def get_score(outcome_form)
    # following return statement is for when lesson score is explicitly specified
    return outcome_form['score'] if outcome_form['score'] && !outcome_form['score'].empty?
    objectives = outcome_form['outcomes_objectives_attributes']
    score = 0
    achievement_name = @outcome.manager_id == session[:id] ? 'self_achievement' : 'eval_achievement'

    objectives.each do |_key, o|
      score += o[achievement_name].to_i
    end
    score
  end

  def ajax_previous_status
    @outcome = Outcome.find params[:id]
    @outcome.update_attributes(status: params[:previous_status], checked: true)
    @lesson = @outcome.lesson
    @content = @lesson.content

    pg = get_page(@lesson.id, @content)
    get_values
    @sticky = Sticky.new(content_id: @content.id, course_id: @course.id, target_id: pg['file_id'])
    @message_templates = get_message_templates(@course.manager?(session[:id]))

    # latest_item = @outcome.outcome_messages[0]
    # if (latest_item.manager_id == session[:id])
    #   @outcome_message = latest_item
    # else
    #   @outcome_message = OutcomeMessage.new()
    # end

    render 'layouts/renders/resource_with_pg', locals: { resource: 'layouts/assignment_page', pg: pg }
  end

  # Show messages specified by lesson_id and manager_id
  # call ajax
  # @param [String] lesson_id
  # @param [String] manager_id
  def ajax_show_previous_messages
    outcome = param_check_show_messages? ? outcome_by_lesson_id_and_manager_id : nil
    outcome = outcome.nil? ? Outcome.new : outcome
    render 'outcomes/renders/messages', locals: { current_outcome_id: params[:current_outcome_id].to_i, outcome: outcome }
  end

  # ====================================================================
  # Private Functions
  # ====================================================================

  private

  def get_values
    @course = @lesson.course
    get_outcome_resources @lesson, @content
    set_sticky_panel_session
  end

  def outcome_params
    params.require(:outcome).permit(:course_id, :manager_id, :lesson_id, :status, :score, :checked, :attendance, outcome_messages_attributes: %i[manager_id message id], outcome_text_attributes: %i[entry id], outcomes_objectives_attributes: %i[outcome_id objective_id eval_achievement self_achievement id])
  end

  def param_check_show_messages?
    !(params[:lesson_id].nil? || params[:manager_id].nil?)
  end

  def outcome_by_lesson_id_and_manager_id
    Outcome.find_by(manager_id: params[:manager_id], lesson_id: params[:lesson_id])
  end
end
