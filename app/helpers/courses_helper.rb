module CoursesHelper
  # ====================================================================
  # Public Functions
  # ====================================================================

  def course_combined_title(course)
    return course.title if (course.weekday == 9) || (course.period == 0)
    course.title + ' [' + course_period(course) + ']'
  end

  def course_crumbs(course_id, lesson_num, lesson_status, nav_section, _page_num)
    crumb_title = lesson_status == 'draft' ? "<i class='fa fa-lock'></i> " : ''
    crumb_title += t('activerecord.models.lesson') + lesson_num.to_s
    c1 = ['', { action: 'ajax_index', nav_section: nav_section, nav_id: course_id }]
    c2 = [crumb_title]
    [c1, c2]
  end

  def course_disabled_status_hash(current_status)
    current_status == 'draft' ? {} : { disabled: 'draft' }
  end

  def course_period(course, abbr = true)
    return '' if (course.weekday == 9) || (course.period == 0)
    if abbr
      day_names = I18n.t 'date.abbr_day_names'
      day_names[course.weekday % 7] + course.period.to_s
    else
      day_names = I18n.t 'date.day_names'
      day_names[course.weekday % 7] + t('helpers.course_period', period: course.period)
    end
  end

  def course_status_array
    array = [[t('helpers.select_draft_course'), 'draft']]
    array.push [t('helpers.select_open_course'), 'open']
    array.push [t('helpers.select_archived_course'), 'archived']
  end

  def lesson_icon(status, marked_lessons, lesson_id, lesson_role, learner_size)
    return { class: 'fa fa-lock fa-lg', text: '非公開' } if status == 'draft'
    return { class: 'fa fa-comment fa-lg icon-red', text: '未確認' } if marked_lessons && marked_lessons[lesson_id] && (marked_lessons[lesson_id] > 0)

    case lesson_role
    when 'learner'
      outcome = Outcome.find_by(manager_id: session[:id], lesson_id: lesson_id)
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
    [[t('activerecord.others.course.status_draft'), 'draft'], [t('activerecord.others.course.status_open'), 'open'], [t('activerecord.others.course.status_archived'), 'archive']]
  end

  def course_managers_display_list(course)
    managers = []
    course.managers.each do |manager|
      managers.push(manager.full_name)
    end
    managers.join(',')
  end

  def periods
    periods = [[t('helpers.course_not_periodically'), 0]]
    (1..COURSE_PERIOD_MAX_SIZE).each {|p| periods.push([p, p])}
    periods
  end

  def weekdays
    weekdays = [[t('helpers.course_not_weekly'), 9]]
    day_names = I18n.t 'date.day_names'
    (1..7).each {|p| weekdays.push([day_names[p % 7], p])}
    weekdays
  end
end
