module OutcomesHelper
  # ====================================================================
  # Public Functions
  # ====================================================================

  def demerit_class(achievement, allocation)
    achievement < allocation ? 'demerit' : ''
  end

  def lesson_menu_items(course, current_lesson)
    staff = course.staff? session[:id]
    if staff
      menu_items = course.lessons.map { |l| [l.display_order.to_s + '. ' + l.content.title, l.id] }
    else
      menu_items = Lesson.select_open(course.lessons).map { |l| [l.display_order.to_s + '. ' + l.content.title, l.id] }
    end

    menu_items.each do |mi|
      mi[0] = mi[1] == current_lesson.id ? '***** ' + t('helpers.current_lesson') + ' *****' : mi[0]
    end
    label = [t('helpers.messages_in_other_lesson'), -1]
    menu_items.unshift(label)
  end

  def outcome_message_text(evaluator_id)
    case evaluator_id
    when 0
      'コメント'
    else
      'メッセージ'
    end
  end

  def outcome_score_text(evaluator_id, score)
    case evaluator_id
    when 0
      '目標達成率 ' + (score * 10).to_s + '%'
    else
      '得点 ' + score.to_s + '点'
    end
  end

  def outcome_status_text(outcome_status, score)
    case outcome_status
    when 'draft'
      return t('activerecord.others.outcome.status.fix') if score && score > 0
      t('activerecord.others.outcome.status.draft')
    when 'submit', 'self_submit', 'return'
      t('activerecord.others.outcome.status.' + outcome_status)
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
end
