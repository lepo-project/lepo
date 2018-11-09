# 0. for general
# 1. for html id / class
# 2. for text
# 3. for card
# 4. for others

module ApplicationHelper
  # 0. for general ============================================================================
  def add_br(txt)
    txt = html_escape(txt)
    txt.gsub(/\r\n|\r|\n/, '<br />')
  end

  def average(value, data_num, decimal_num)
    return if data_num.zero?
    (value.to_f / data_num).round(decimal_num)
  end

  def get_summary(txt)
    double_return_index = txt.index('<br /><br />')
    if double_return_index
      summary = txt[0..(double_return_index - 1)]
      rest = txt[(double_return_index + 12)..txt.size]
      return [summary, rest]
    end
    [txt]
  end

  def get_short_string(original_string, max_length)
    original_string_array = original_string.split(//u)
    return original_string_array[0..(max_length - 2)].join + '...' if original_string_array.size > max_length
    original_string
  end

  def ratio(value1, value2, decimal_num)
    return if value2.zero?
    ((value1 * 100).to_f / value2.to_f).round(decimal_num)
  end

  def system_url
    protocol = SYSTEM_SSL_FLAG ? 'https://' : 'http://'
    return protocol + request.host_with_port + Rails.application.config.relative_url_root if Rails.application.config.relative_url_root
    protocol + request.host_with_port
  end

  # 1. for html id / class  ===================================================================
  def selected_id(identical)
    identical ? 'selected' : ''
  end

  def required_class(required)
    required ? 'required' : 'optional'
  end

  # 2. for text ===============================================================================
  def display_title(obj)
    obj.title.size.nonzero? ? obj.title : t('helpers.no_title')
  end

  def last_signin_at_text(date_at)
    return t('helpers.not_using_lepo') unless date_at
    l(date_at, format: :long)
  end

  def member_role_text(model_category, member_role)
    return if member_role.empty?
    case model_category
    when 'content'
      t("activerecord.others.content_member.role.#{member_role}")
    when 'course'
      t('activerecord.attributes.course.' + member_role + 's')
    when 'system'
      t('activerecord.others.user.role.' + member_role)
    end
  end

  def lesson_evaluation_text(evaluator_id)
    return '' unless evaluator_id
    return t('helpers.self_evaluation') if evaluator_id.zero?
    t('helpers.teacher_evaluation')
  end

  def lesson_evaluator_text(evaluator_id)
    return '' unless evaluator_id
    return t('helpers.self_evaluation') if evaluator_id.zero?
    t('helpers.evaluator') + ' : ' + User.find(evaluator_id).full_name
  end

  def page_num_text(page_num, max_page_num)
    case page_num
    when 0 then
      t('helpers.cover_page')
    when max_page_num then
      t('helpers.assignment_page')
    else
      'p' + page_num.to_s
    end
  end

  def page_num_text_by_id(content, page_id)
    page_ids = content.page_ids
    page_num = page_ids.index(page_id)
    max_page_num = page_ids.size - 1
    case page_num
    when 0
      return t('helpers.cover_page')
    when max_page_num
      return t('helpers.assignment_page')
    else
      return 'p.' + page_num.to_s
    end
  end

  def preference_icon(controller_name, action_name)
    case controller_name
    when 'courses'
      case action_name
      when 'ajax_new'
        %w[fa-flag fa-plus-circle]
      when 'ajax_course_pref'
        %w[fa-flag fa-pencil]
      end
    when 'devices'
      # FIXME: PushNotification
      'fa-mobile'
    when 'bookmarks'
      'fa-bookmark'
    when 'preferences'
      case action_name
      when 'ajax_account_pref'
        'fa-key'
      when 'ajax_new_user_pref'
        %w[fa-user fa-plus-circle]
      when 'ajax_notice_pref'
        'fa-bullhorn'
      when 'ajax_profile_pref'
        'fa-user'
      when 'ajax_default_note_pref'
        'fa-file-text'
      when 'ajax_user_account_pref'
        %w[fa-user fa-pencil]
      when 'ajax_update_pref'
        'fa-database'
      end
    when 'terms'
      'fa-building'
    end
  end

  def sticky_category_short_text(category)
    case category
    when 'course'
      'コース'
    when 'private'
      '個人'
    end
  end

  def sticky_category_text(category)
    case category
    when 'course', 'private'
      return sticky_category_short_text(category) + 'ふせん'
    when 'user'
      'ユーザのコースふせん'
    end
  end

  def status_text(status)
    case status
    when 'draft'
      '準備中'
    when 'open'
      '公開中'
    when 'archived'
      'アーカイブ'
    end
  end

  # 3. for card ===============================================================================
  def content_activity_card_hash(user)
    managing_contents = Content.associated_by user.id, 'manager'
    assisting_contents = Content.associated_by user.id, 'assistant'
    card = {}
    card['icon'] = 'fa fa-book'
    card['header'] = '教材に関する活動'
    card['body'] = "管理している教材： #{managing_contents.size}教材\n"
    card['body'] += "補助している教材： #{assisting_contents.size}教材\n"
    card['summary'] = false
    card['footnotes'] = [t('helpers.last_used_at') + ' : ' + last_signin_at_text(user.last_signin_at)]
    card
  end

  def course_activity_card_hash(user)
    learning_courses = Course.associated_by user.id, 'learner'
    managing_courses = Course.associated_by user.id, 'manager'
    assisting_courses = Course.associated_by user.id, 'assistant'
    card = {}
    card['icon'] = 'fa fa-flag'
    card['header'] = 'コースに関する活動'
    card['body'] = "学習しているコース： #{learning_courses.size}コース\n"
    card['body'] += "管理しているコース： #{managing_courses.size}コース\n"
    card['body'] += "補助しているコース： #{assisting_courses.size}コース\n"
    card['summary'] = false
    card['footnotes'] = [t('helpers.last_used_at') + ' : ' + last_signin_at_text(user.last_signin_at)]
    card['footnotes'].push("[#{t('helpers.contents_manage')}: #{user.content_manageable? ? t('helpers.possible') : t('helpers.impossible')}]")
    card
  end

  def course_card_hash(course)
    card = {}
    if course.image
      card['image'] = course.image_rails_url('80')
    else
      card['icon'] = 'fa fa-flag'
    end
    card['header'] = course.title
    card['body'] = course.overview
    card['summary'] = true
    period_footnote = course_period(course, false).empty? ? '' : course_period(course, false) + ' / '
    card['footnotes'] = [period_footnote + term_display_title(course.term.title)]
    card
  end

  def lesson_activity_card_hash(course_role, lesson_resources)
    card = {}
    card['header'] = t('helpers.lesson_status')
    case course_role
    when 'learner'
      non_self_eval_num = lesson_resources['non_self_eval'].size
      if non_self_eval_num.zero?
        card['icon'] = 'fa fa-check-circle'
        card['body'] = '全ての公開レッスンで、自己評価済みです'
      else
        card['icon'] = 'fa fa-exclamation-circle'
        card['body'] = "以下のレッスンで、自己評価がされていません\n"
        lesson_resources['non_self_eval'].each_with_index do |lesson, i|
          card['body'] += "　・レッスン#{lesson.display_order}: #{lesson.content.title} \n"
          card['body'] += "\n" if (i == 1) && non_self_eval_num > 2
        end
      end
      card['summary'] = true
    else
      card['icon'] = 'fa fa-info-circle'
      card['body'] = '学生には、自己評価をしていないレッスンが表示されます'
      card['summary'] = false
    end
    card['footnotes'] = []
    card
  end

  def notice_card_hash(notice, border_category, course = Course.new)
    card = {}
    if notice.manager.image
      card['image'] = notice.manager.image_rails_url('80')
    else
      card['icon'] = 'fa fa-user'
    end
    card['caption'] = notice.manager.full_name
    card['body'] = notice.message
    card['footnotes'] = [l(notice.updated_at, format: :long)]
    card['footnotes'].push('[更新]') if notice.created_at != notice.updated_at

    case action_name
    when 'ajax_edit_notice', 'ajax_notice_pref', 'ajax_create_notice', 'ajax_destroy_notice', 'ajax_reedit_notice', 'ajax_archive_notice', 'ajax_open_notice', 'ajax_update_notice'
      course_id = course.new_record? ? 0 : course.id
      card['operations'] = notice_card_operations(notice, border_category, course_id)
    when 'signin'
      card['operations'] = nil
    else
      card['operations'] = [{ label: '公開終了', url: { action: 'ajax_archive_notice_from_course_top', id: course.id, notice_id: notice.id } }] if course.staff? session[:id]
    end
    card
  end

  def notice_card_operations(notice, border_category, course_id)
    operations = []
    case border_category
    when 'course'
      operations.push(label: t('helpers.archive'), url: { action: 'ajax_archive_notice', id: course_id, notice_id: notice.id })
      if notice.manager_id == session[:id]
        operations.push(label: t('helpers.edit'), url: { action: 'ajax_reedit_notice', id: course_id, notice_id: notice.id })
      end
    when 'pending'
      if notice.manager_id == session[:id]
        operations.push(label: t('helpers.delete'), url: { action: 'ajax_destroy_notice', id: course_id, notice_id: notice.id })
      end
      operations.push(label: t('helpers.reopen'), url: { action: 'ajax_open_notice', id: course_id, notice_id: notice.id })
    end
    operations
  end

  def sticky_activity_card_hash(user, stickies)
    card = {}
    card['icon'] = 'fa fa-th-list fa-flip-horizontal'
    card['header'] = 'ふせんに関する活動'
    card['body'] = "個人ふせん： 計#{stickies['private']}枚\n"
    card['body'] += "コースふせん： 計#{stickies['course']}枚\n"
    card['summary'] = false
    card['footnotes'] = [t('helpers.last_used_at') + ' : ' + last_signin_at_text(user.last_signin_at)]
    card
  end

  def support_card_hash(category)
    card = {}
    case category
    when 'content'
      card['icon'] = 'fa fa-book'
      card['header'] = '教材とは？'
      card['body'] = 'PC等で作成した教材ファイルをLePoにアップロードして、教材として利用できます。教材には学習目標と課題の設定が必須です。また、学生は教材の学習目標に対して自己評価を行うことが必須です。教材は以下の手順で新規作成することができます。'
    when 'selfeval_chart'
      card['icon'] = 'fa fa-info-circle'
      card['header'] = '自己評価の推移'
      card['body'] = '学生には、自己評価合計の2週間の推移が表示されます。'
    end
    card['summary'] = false
    card['footnotes'] = []
    card
  end

  def user_card_l_hash(user)
    card = {}
    if user.image
      card['image'] = user.image_rails_url('80')
    else
      card['icon'] = 'fa fa-user'
    end
    card['header'] = link_to_if(user.web_url?, user.full_name_all, user.web_url, target: '_blank')
    card['body'] = user.description
    card['summary'] = false
    if user.updated_at
      card['footnotes'] = [t('helpers.last_updated_at') + ' : ' + l(user.updated_at, format: :long)]
    else
      card['footnotes'] = ['最終更新： 未更新']
    end
    card
  end

  def user_card_l_border(user)
    return 'course' if session[:nav_controller] != 'course_members'
    course = Course.find_enabled_by session[:nav_id]
    return 'staff' if course.staff? user.id
    'learner'
  end

  def member_candidate_url(category, form_category, user, resource_id, update_to, search_word, member_role, candidates_csv)
    case category
    when 'content'
      { action: 'ajax_update_role', user_id: user.id, content_id: resource_id, update_to: update_to, form_category: form_category, search_word: search_word, member_role: member_role, candidates_csv: candidates_csv }
    when 'course'
      { action: 'ajax_update_role', user_id: user.id, course_id: resource_id, update_to: update_to, form_category: form_category, search_word: search_word, member_role: member_role, candidates_csv: candidates_csv }
    when 'system'
      if update_to == 'suspended'
        { action: 'ajax_update_role', user_id: user.id, update_to: 'suspended', form_category: form_category, search_word: search_word, member_role: member_role, candidates_csv: candidates_csv }
      else
        params = { action: 'ajax_create_user', role: user.role, authentication: user.authentication, signin_name: user.signin_name, password: user.password, family_name: user.family_name, given_name: user.given_name, candidates_csv: candidates_csv }
        params[:phonetic_family_name] = user.phonetic_family_name if USER_PHONETIC_NAME_FLAG
        params[:phonetic_given_name] = user.phonetic_given_name if USER_PHONETIC_NAME_FLAG
        params
      end
    end
  end

  def managers_of_course(category, user, course_id, manager_ids)
    { controller: 'course_members', action: 'ajax_get_managers', category: category, manager_id: user.id, course_id: course_id, manager_ids: manager_ids }
  end

  # 4. for others =============================================================================
  def assignment_categories
    [[t('activerecord.others.content.as_category.text'), 'text'], [t('activerecord.others.content.as_category.file'), 'file'], [t('activerecord.others.content.as_category.outside'), 'outside']]
  end

  def available_bookmarks
    user_id = session[:id]
    return Bookmark.by_user(user_id) + Bookmark.by_system_staffs if user_id && !User.system_staff?(user_id)
    Bookmark.by_system_staffs
  end

  def check_identical(item, nav_id_exists, nav_section, nav_controller, nav_id)
    return false if (item[:nav_section] != nav_section) || (item[:nav_controller] != nav_controller)
    return (item[:nav_id] == nav_id.to_i) if nav_id_exists
    true
  end

  def course_cancel_hash
    case session[:nav_id]
    when 0
      # for new course creation
      { controller: 'preferences', action: 'ajax_index', nav_section: 'home', nav_id: 0 }
    else
      # for existing course edit
      { controller: 'courses', action: 'ajax_index', nav_section: session[:nav_section], nav_id: session[:nav_id] }
    end
  end

  def get_evaluators(managers)
    evaluators = [[lesson_evaluator_text(0), 0]]
    managers.each do |manager|
      evaluators.push [lesson_evaluator_text(manager.id), manager.id]
    end
    evaluators
  end

  def main_nav_items(section, subsections = [])
    items = []
    case section
    when 'home'
      items.push(nav_section: 'home', nav_controller: 'dashboard', title: t('helpers.dashboard'), class: 'fa fa-dashboard fa-lg')
      items.push(nav_section: 'home', nav_controller: 'notes', title: t('helpers.note_management'), class: 'fa fa-file-text fa-lg')
      items.push(nav_section: 'home', nav_controller: 'contents', title: t('helpers.support'), class: 'fa fa-question-circle fa-lg')
      items.push(nav_section: 'home', nav_controller: 'preferences', title: t('helpers.preferences'), class: 'fa fa-cog fa-lg')
    when 'open_courses'
      subsections.each do |course|
        items.push(nav_section: 'open_courses', nav_controller: 'courses', nav_id: course.id, title: course_combined_title(course), class: 'fa fa-flag fa-lg')
        items.push(nav_section: 'open_courses', nav_controller: 'portfolios', nav_id: course.id, title: t('helpers.portfolio'), class: 'no-icon')
        # items.push(nav_section: 'open_courses', nav_controller: 'stickies', nav_id: course.id, title: t('activerecord.models.sticky'), class: 'no-icon')
        items.push(nav_section: 'open_courses', nav_controller: 'notes', nav_id: course.id, title: t('helpers.worksheet_note'), class: 'no-icon')
        items.push(nav_section: 'open_courses', nav_controller: 'course_members', nav_id: course.id, title: t('activerecord.models.course_member'), class: 'no-icon')
      end
    when 'repository'
      items.push(nav_section: 'repository', nav_controller: 'contents', title: t('activerecord.models.content'), class: 'fa fa-book fa-lg')
      subsections.each do |course|
        items.push(nav_section: 'repository', nav_controller: 'courses', nav_id: course.id, title: course_combined_title(course), class: 'fa fa-flag fa-lg')
        items.push(nav_section: 'repository', nav_controller: 'portfolios', nav_id: course.id, title: t('helpers.portfolio'), class: 'no-icon')
        items.push(nav_section: 'repository', nav_controller: 'notes', nav_id: course.id, title: t('helpers.worksheet_note'), class: 'no-icon')
        items.push(nav_section: 'repository', nav_controller: 'course_members', nav_id: course.id, title: t('activerecord.models.course_member'), class: 'no-icon')
      end
    end
    items
  end

  def get_selected_association(_lesson_id, objective_id, associations)
    associations.each do |a|
      return a if a.objective_id == objective_id
    end
    GoalsObjective.new(goal_id: 0)
  end

  def get_self_achievement_charts(user_id, course_id, latest, interval, data_num)
    line_data = '['
    x_min = ''
    x_max = ''
    y_max = 0

    data_num.times do |data|
      day = latest - (data_num - data - 1) * interval
      outcome_messages = OutcomeMessage.where('manager_id = ? AND created_at < ?', user_id, day + 1).group(:outcome_id)
      achievement = 0
      outcome_messages.each do |om|
        achievement += om.score if om.score && (om.outcome.lesson.course.id == course_id) && (om.outcome.lesson.status == 'open')
      end
      line_data += "['" + day.strftime('%Y-%m-%d') + "', #{achievement}],"
      x_min = day.strftime('%b %d, %Y') if data.zero?
      x_max = day.strftime('%b %d, %Y')
      y_max = achievement
    end

    line_data = line_data.slice(0, line_data.length - 1) if line_data.length > 1
    line_data += ']'

    { 'chart_id' => 'self-eval-chart', title: '自己評価合計の推移（過去2週間）', 'x_title' => '', 'x_min' => x_min, 'x_max' => x_max, 'y_title' => '点', 'y_max' => y_max, 'line_data' => line_data }
  end

  def get_url_hash(course_id, _course_status)
    { controller: 'courses', action: 'ajax_index', nav_section: session[:nav_section], nav_id: course_id }
  end

  def link_to_lesson(body, course_id, lesson_id, html_options)
    link_to(sanitize("<div>#{body}</div>"), { controller: 'courses', action: 'ajax_show', id: course_id, lesson_id: lesson_id }, html_options.merge(remote: true))
  end

  def link_to_lesson_evaluator(course, lesson)
    title = lesson_evaluator_text lesson.evaluator_id
    outcomes = lesson.outcomes
    if outcomes
      non_draft_outcomes = outcomes.reject { |x| x.status == 'draft' }
      if non_draft_outcomes && !non_draft_outcomes.empty?
        return title if lesson.evaluator_id.zero? || (course.managers.size == 1)
      end
    end
    link_to(title, { action: 'ajax_update_evaluator_from', id: course.id, lesson_id: lesson.id }, class: 'bright-link', remote: true)
  end

  def link_to_target_in_course(sticky, grouped_by_content)
    case sticky.target_type
    when 'Page'
      page_num_text = page_num_text_by_id sticky.content, sticky.target_id
      sticky_title = page_num_text
      sticky_title = sticky.content.title + ': ' + sticky_title unless grouped_by_content
      course_id_for_link = sticky.course_id_for_link
      if course_id_for_link > 0
        link_to(sticky_title, { controller: 'courses', action: 'ajax_show_page_from_sticky', course_id: course_id_for_link, content_id: sticky.content.id, target_id: sticky.target_id }, remote: true)
      else
        sticky_title
      end
    when 'Note'
      note = Note.find(sticky.target_id)
      sticky_title = note.title + ' by ' + note.manager.full_name

      course_id_for_link = sticky.course_id_for_link
      if course_id_for_link > 0
        link_to(sticky_title, { controller: 'notes', action: 'ajax_show_from_others', nav_id: course_id_for_link, id: sticky.target_id }, title: 'ノートに移動', remote: true)
      else
        sticky_title
      end
    end
  end

  def link_to_target_in_course_snippet(snippet, page)
    content = page.content
    page_num_text = page_num_text_by_id content, page.id
    title = content.title + ': ' + page_num_text
    course_id = snippet.notes[0].course_id
    if course_id > 0
      link_to(title, { controller: 'courses', action: 'ajax_show_page_from_sticky', course_id: course_id, content_id: content.id, target_id: page.id }, style: 'font-weight: bold;', remote: true)
    else
      sticky_title
    end
  end

  def link_to_resource(body, resource_id, html_options, action = 'ajax_show')
    link_to(sanitize("<div>#{body}</div>"), { action: action, id: resource_id }, html_options.merge(remote: true))
  end

  def member_role_options(update_model)
    case update_model
    when 'content_member'
      options = [[t('activerecord.others.content_member.role.manager') + t('helpers.candidate'), 'manager']]
      options.push [t('activerecord.others.content_member.role.assistant') + t('helpers.candidate'), 'assistant']
      options.push [t('activerecord.others.content_member.role.user') + t('helpers.candidate'), 'user']
    when 'course_member'
      options = [[t('activerecord.attributes.course.managers') + t('helpers.candidate'), 'manager']]
      options.push [t('activerecord.attributes.course.assistants') + t('helpers.candidate'), 'assistant']
      options.push [t('activerecord.attributes.course.learners') + t('helpers.candidate'), 'learner']
    when 'system'
      options = [[t('activerecord.others.user.role.admin'), 'admin']]
      options.push [t('activerecord.others.user.role.manager'), 'manager']
      options.push [t('activerecord.others.user.role.user'), 'user']
      options.push [t('activerecord.others.user.role.suspended'), 'suspended']
    end
    options
  end

  def page_exists?(page_num, max_page_num)
    # page 0 is cover page and page max_page_num is assignment page
    ((page_num >= 0) && (page_num <= max_page_num))
  end

  def previous_status_button(evaluator_id, lesson_role, outcome)
    case lesson_role
    when 'learner'
      case outcome.status
      when 'draft'
        if evaluator_id > 0
          link_to(raw("<i class = 'fa fa-times-circle'></i> 再提出をキャンセル"), { controller: 'outcomes', action: 'ajax_previous_status', id: outcome.id, previous_status: 'return' }, class: 'btn btn-light btn-lg', remote: true) if outcome.score
        else
          link_to(raw("<i class = 'fa fa-times-circle'></i> 再自己評価をキャンセル"), { controller: 'outcomes', action: 'ajax_previous_status', id: outcome.id, previous_status: 'self_submit' }, class: 'btn btn-light btn-lg', remote: true) if outcome.score
        end
      when 'self_submit'
        link_to(raw("<i class = 'fa fa-check-circle'></i> 自己評価を再入力"), { controller: 'outcomes', action: 'ajax_previous_status', id: outcome.id, previous_status: 'draft' }, class: 'btn btn-light btn-lg', remote: true)
      when 'submit'
        if outcome.checked
          '教師が評価中のため、評価依頼をキャンセルできません'
        else
          link_to(raw("<i class = 'fa fa-times-circle'></i> 評価依頼をキャンセル"), { controller: 'outcomes', action: 'ajax_previous_status', id: outcome.id, previous_status: 'draft' }, class: 'btn btn-light btn-lg', remote: true)
        end
      when 'return'
        link_to(raw("<i class = 'fa fa-check-circle'></i> 課題を再提出"), { controller: 'outcomes', action: 'ajax_previous_status', id: outcome.id, previous_status: 'draft' }, class: 'btn btn-light btn-lg', remote: true)
      end
    when 'evaluator'
      case outcome.status
      when 'return'
        link_to(raw("<i class = 'fa fa-times-circle'></i> 評価をキャンセル"), { controller: 'outcomes', action: 'ajax_previous_status', id: outcome.id, previous_status: 'submit' }, class: 'btn btn-light btn-lg', remote: true)
      end
    end
  end

  def user_stared_sticky?(user_id, sticky)
    case sticky.category
    when 'private'
      (sticky.stars_count == 1)
    else
      sticky_star = StickyStar.find_by(manager_id: user_id, sticky_id: sticky.id)
      sticky_star && sticky_star.stared
    end
  end

  def user_stared_note?(user_id, note)
    note_star = NoteStar.find_by(manager_id: user_id, note_id: note.id)
    note_star && note_star.stared
  end

  def sticky_star_btn_class(user_id, sticky)
    stared = user_stared_sticky? user_id, sticky
    stared ? 'stared' : ''
  end

  def note_star_btn_class(user_id, note)
    stared = user_stared_note? user_id, note
    stared ? 'stared' : ''
  end

  def select_options_unspecified(options)
    options.unshift([t('helpers.unspecified'), nil])
  end

end
