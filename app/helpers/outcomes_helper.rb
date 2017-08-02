module OutcomesHelper
  # ====================================================================
  # Public Functions
  # ====================================================================

  def check_objectives(objectives, objective_id)
    objectives.each do |sa|
      return true if sa.objective_id == objective_id
    end
    false
  end

  def class_for_main_block(outcome)
    if outcome.status == 'return'
      return 'outcome_block_pass' if outcome.score > 0
      'outcome_block_fail'
    else
      'outcome_block_' + outcome.status
    end
  end

  def get_filename(url)
    url =~ /([^\/]+?)([\?#].*)?$/
    $&
  end

  def lesson_menu_items(course, current_lesson)
    staff = course.staff? session[:id]
    if staff
      menu_items = course.lessons.map { |l| [l.display_order.to_s + '. ' + l.content.title, l.id] }
    else
      menu_items = Lesson.select_open(course.lessons).map { |l| [l.display_order.to_s + '. ' + l.content.title, l.id] }
    end

    menu_items.each do |mi|
      mi[0] = mi[1] == current_lesson.id ? '***** ' + t('views.content.current_lesson') + ' *****' : mi[0]
    end
    label = [t('views.content.messages_in_other_lesson'), -1]
    menu_items.unshift(label)
  end

  def link_to_outcome(title, id, crs, clss, id_title)
    if id_title != 'select'
      link_to(title, { action: 'ajax_show', id: id, crs: crs }, class: clss, remote: true)
    else
      title
    end
  end

  def show_outcome_form?(lesson_role, outcome_status)
    case lesson_role
    when 'observer'
      return true
    when 'learner'
      return true if outcome_status == 'draft'
      # return true if (outcome_status == 'draft') or (outcome_status == 'return')
    end
    false
  end

  def show_outcome_message_form?(lesson_role, outcome_status)
    case lesson_role
    when 'observer'
      return true
    when 'learner'
      return true if (outcome_status == 'draft') || (outcome_status == 'return')
    when 'evaluator', 'manager'
      return true if outcome_status == 'submit'
    end
    false
  end
end
