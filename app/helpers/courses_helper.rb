module CoursesHelper
  # ====================================================================
  # Public Functions
  # ====================================================================

  def course_crumbs(course_id, lesson_num, lesson_status, nav_section, _page_num)
    crumb_title = t('activerecord.models.lesson') + ' ' + lesson_num.to_s
    crumb_title += '（非公開）' if lesson_status == 'draft'
    c1 = [t('views.navs.top'), { action: 'ajax_index', nav_section: nav_section, nav_id: course_id }]
    c2 = [crumb_title]
    [c1, c2]
  end

  def course_disabled_status_hash(current_status)
    current_status == 'draft' ? {} : { disabled: 'draft' }
  end

  def course_status_array
    array = [[t('views.system_messages.courses.select_draft_status'), 'draft']]
    array.push [t('views.system_messages.courses.select_open_status'), 'open']
    array.push [t('views.system_messages.courses.select_archived_status'), 'archived']
  end

  def lesson_icon(status, marked_lessons, lesson_id, lesson_role, learner_size)
    return { class: 'fa fa-lock fa-lg', text: '非公開' } if status == 'draft'
    return { class: 'fa fa-comment fa-lg icon-red', text: '未確認' } if marked_lessons && marked_lessons[lesson_id] && (marked_lessons[lesson_id] > 0)

    case lesson_role
    when 'learner'
      outcome = Outcome.find_by_manager_id_and_lesson_id session[:id], lesson_id
      if outcome && outcome.score && (outcome.status != 'draft')
        return { class: 'fa fa-check fa-lg', text: '評価済み[満点]' } if outcome.score == 10
        return { class: 'fa fa-check fa-lg icon-gray', text: '評価済み' }
      end
    when 'evaluator', 'manager', 'assistant'
      outcomes = Outcome.where(lesson_id: lesson_id).to_a
      outcomes.delete_if { |oc| oc.status == 'draft' || !oc.score }
      return { class: 'fa fa-check fa-lg', text: '評価済み[全員]' } if outcomes.size == learner_size
      return { class: 'fa fa-check fa-lg icon-gray', text: '評価済み[一部]' } unless outcomes.empty?
    end
    { class: 'no-icon', text: '' }
  end

  def message_side(message_manager_id, outcome_manager_id)
    # messages in the assignment page are limited for learner and managers
    message_manager_id == outcome_manager_id ? 'left' : 'right'
  end

  def status_select_options
    [[t('activerecord.attributes.course.status_draft'),'draft'], [t('activerecord.attributes.course.status_open'),'open'],[t('activerecord.attributes.course.status_archived'),'archive']]
  end

  def course_managers_display_list(course)
    managers = []
    course.managers.each do |manager|
      managers.push(manager.full_name)
    end
    managers.join(',')
  end
end
