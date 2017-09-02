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

  def demerit_class(achievement, allocation)
    achievement < allocation ? 'demerit' : ''
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

  def outcome_message_text(evaluator_id)
    case evaluator_id
    when 0
      'コメント'
    else
      'メッセージ'
    end
  end

  def outcome_num_text(past_messages_num)
    submit_num = ((past_messages_num + 1) / 2)
    return '(' + submit_num.to_s + '回目の提出)' if submit_num > 0
    ''
  end

  def outcome_score_text(evaluator_id, score)
    case evaluator_id
    when 0
      '目標達成率 ' + (score * 10).to_s + '%'
    else
      '得点 ' + score.to_s + '点'
    end
  end

  def outcome_status_icon(outcome_status, score)
    case outcome_status
    when 'draft', 'self_submit', 'return'
      'fa fa-check' if score && score > 0
    when 'submit'
      'fa fa-comment'
    end
  end

  def outcome_status_text(outcome_status, score)
    case outcome_status
    when 'draft'
      return '修正中' if score && score > 0
      '未提出'
    when 'submit'
      '評価依頼中'
    when 'self_submit'
      '自己評価完了'
    when 'return'
      '評価完了'
    end
  end

  def outcome_submit_text(evaluator_id, role)
    case role
    when 'learner'
      case evaluator_id
      when 0
        '自己評価を保存'
      else
        '課題を提出'
      end
    when 'evaluator'
      case evaluator_id
      when 0
        'メッセージを送信'
      else
        '評価を確定'
      end
    when 'manager'
      'メッセージを送信'
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
