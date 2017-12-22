class MessageTemplatesController < ApplicationController
  # ====================================================================
  # Public Functions
  # ====================================================================
  def ajax_create
    message_template = MessageTemplate.new(message: params[:message], manager_id: session[:id], content_id: params[:content_id].to_i, objective_id: params[:objective_id].to_i)
    message_template.save
    set_message_templates
  end

  def ajax_count
    message_template = MessageTemplate.find params[:id]
    updated_counter = (message_template.counter + 1) % 100_000
    message_template.update_attributes(counter: updated_counter) if message_template && (message_template.content_id > 0)
    set_message_templates
  end

  def ajax_destroy
    message_template = MessageTemplate.find params[:id]
    message_template.destroy if message_template && (message_template.manager_id == session[:id])
    set_message_templates
  end

  def ajax_toggle_contents
    message_template = MessageTemplate.find params[:id]
    message_template.update_attributes(content_id: params[:toggled_content_id].to_i, objective_id: 0)
    set_message_templates
  end

  def ajax_toggle_objective
    message_template = MessageTemplate.find params[:id]
    objective_id = message_template.objective_id == params[:objective_id].to_i ? 0 : params[:objective_id].to_i
    message_template.update_attributes(content_id: session[:content_id], objective_id: objective_id)
    set_message_templates
  end

  # ====================================================================
  # Private Functions
  # ====================================================================

  private

  def set_message_templates
    @content = Content.find session[:content_id]
    @message_templates = get_message_templates(true)

    # outcomes are needed to refresh all outcome insert_btn in assignment_page
    lesson_id = params[:lesson_id]
    lesson = Lesson.find lesson_id
    evaluator_id = lesson.evaluator_id
    outcomes = Outcome.all_by_lesson_id_and_lesson_role_and_manager_id session[:nav_id], lesson_id, 'evaluator', session[:id]
    render 'layouts/renders/message_templates', locals: { lesson_id: lesson_id, evaluator_id: evaluator_id, outcomes: outcomes }
  end
end
