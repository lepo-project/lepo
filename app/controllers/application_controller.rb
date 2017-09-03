# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
# 0. general
# 1. variable getter
# 2. page replacer

class ApplicationController < ActionController::Base
  include HttpAcceptLanguage::AutoLocale
  after_action :discard_flash_if_xhr
  before_action :authorize
  helper_method :current_user
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  def key_binder
    case params[:key]
    when 'left', 'j', 'shift left', 'shift j', 'right', 'k', 'shift right', 'shift k', 'shift up', 'shift down'
      if (session[:content_id] > 0) && session[:page_num]
        page_num = key_to_page params[:key]
        if page_num && (page_num != session[:page_num])
          redirect_to(controller: session[:nav_controller], action: 'ajax_show_page', protocol: app_protocol, page_num: page_num)
        end
      end
    end
  end

  protected

  # 0. general =================================================================
  def all_blank_title?(attributes)
    not_blank_titles = attributes.values.pluck(:title).delete_if { |t| t == '' }
    not_blank_titles.size.zero?
  end

  def app_protocol
    SSL_ACCESS ? 'https://' : 'http://'
  end

  def authorize
    return if User.find_by_id(session[:id])
    # For snippet import through bookmarklet
    return if (controller_name == 'snippets') && (action_name == 'create_web_snippet')
    # For mainly expired session
    reset_session
    flash[:message] = 'サインインしてください'
    render 'layouts/renders/signout'
  end

  def current_user
    @current_user ||= User.find_by(id: session[:id])
  end

  def delete_existing(candidates, exists)
    exists.each do |ex|
      candidates.delete_if { |ca| ca.id == ex.id }
    end
    candidates
  end

  def discard_flash_if_xhr
    flash.discard if request.xhr?
  end

  def key_to_page(key)
    case key
    when 'left', 'j'
      [0, session[:page_num] - 1].max
    when 'shift left', 'shift j'
      [0, session[:page_num] - 5].max
    when 'right', 'k'
      [session[:page_num] + 1, session[:max_page_num]].min
    when 'shift right', 'shift k'
      [session[:page_num] + 5, session[:max_page_num]].min
    when 'shift up'
      0
    when 'shift down'
      -1
    end
  end

  def set_page_session(page_num, content = nil)
    if content
      max_page_num = content.page_files.size + 1 # max page number is assignment page num

      session[:max_page_num] = max_page_num
      session[:page_num] = get_page_num page_num, max_page_num
      session[:content_id] = content.id
    else
      session[:max_page_num] = 0
      session[:page_num] = 0
      session[:content_id] = 0
    end
  end

  def set_nav_session(nav_section, nav_controller, nav_id = 0)
    session[:nav_section] = nav_section
    session[:nav_controller] = nav_controller
    session[:nav_id] = nav_id
    set_page_session 0
  end

  def set_sticky_panel_session
    session[:sticky_panel] = 'show' if !session[:sticky_panel] || (session[:sticky_panel] != 'mini')
  end

  def set_star_sort_stickies_session(session_value = false)
    session_value = to_boolean(session_value) if (session_value == 'true') || (session_value == 'false')
    return if (session_value != true) && (session_value != false)

    if session[:star_sort_stickies].nil? || (session[:star_sort_stickies] != session_value)
      session[:star_sort_stickies] = session_value
    end
  end

  def set_related_course_stickies_session(session_value = false)
    session_value = to_boolean(session_value) if (session_value == 'true') || (session_value == 'false')
    return if (session_value != true) && (session_value != false)

    if session[:related_course_stickies].nil? || (session[:related_course_stickies] != session_value)
      session[:related_course_stickies] = session_value
    end
  end

  def to_boolean(str)
    str == 'true'
  end

  # 1. variable getter =========================================================
  def get_dashboard_resources(user)
    @cards = []
    @cards.concat(dashboard_evaluation_card(user, 'manager'))
    @cards.concat(dashboard_evaluation_card(user, 'learner'))
    @cards.concat(dashboard_archive_card(user))
  end

  def get_outcome_resources(lesson, content)
    @lesson_role = lesson.user_role current_user.id
    if !@lesson.new_record? && @lesson_role != 'assistant'
      @outcomes = Outcome.get_all_by_lesson_id_and_lesson_role_and_manager_id @lesson.course_id, @lesson.id, @lesson_role, current_user.id
    else
      @outcomes = [Outcome.new_with_associations(current_user.id, 0, 0, 'observer')]
    end

    # OutcomesObjectives setting
    case @lesson_role
    when 'learner', 'assistant', 'observer'
      outcome = @outcomes[0]
      content.objectives.each do |co|
        outcome.outcomes_objectives.build(objective_id: co.id) unless OutcomesObjective.find_by_outcome_id_and_objective_id(outcome.id, co.id)
      end
    end
  end

  def get_marked_outcome_num(lesson_id, user_role)
    case user_role
    when 'evaluator'
      outcomes = Outcome.where(lesson_id: lesson_id, status: 'submit').order(updated_at: :asc) || []
      return outcomes.size
    when 'learner'
      outcome = Outcome.find_by_manager_id_and_lesson_id session[:id], lesson_id
      return 1 if (outcome && outcome.status == 'return' && !outcome.checked) || (outcome && outcome.status == 'self_submit' && !outcome.checked)
    end
    0
  end

  def get_message_templates(course_manager)
    return {} unless course_manager

    contents_templates = MessageTemplate.where(manager_id: session[:id], content_id: 0).order(created_at: :asc)
    content_templates = []
    objective_templates = []
    templates = MessageTemplate.where(manager_id: session[:id], content_id: session[:content_id]).order(created_at: :asc)
    templates.each do |tmp|
      if tmp.objective_id.zero?
        content_templates.push tmp
      else
        objective_templates.push tmp
      end
    end

    objective_templates.sort! { |a, b| a.objective_id <=> b.objective_id }
    { contents: contents_templates, content: content_templates, objective: objective_templates }
  end

  def get_page(lesson_id, content)
    p = {}
    p['parent_id'] = lesson_id > 0 ? lesson_id : content.id # only open course contents are lesson_id > 0
    p['file'] = get_page_file(lesson_id, content, session[:page_num], session[:max_page_num])
    p['file_id'] = get_page_file_id(content, session[:page_num], session[:max_page_num])

    if (session[:nav_section] == 'open_courses') || ((session[:nav_section] == 'repository') && (session[:nav_controller] == 'courses'))
      p['stickies'] = get_course_stickies_by_target session[:nav_id], 'page', p['file_id'], content.id
    else
      p['stickies'] = get_stickies content.id, 'page', p['file_id']
    end
    p
  end

  def get_page_file(_lesson_id, content, page_num, max_page_num)
    if (page_num > 0) && (page_num < max_page_num)
      file = content.page_files[page_num - 1]
      case file.upload_content_type[0, 1]
      when 't' then
        return file.upload.url
      when 'i' then
        if ENV['RAILS_RELATIVE_URL_ROOT']
          return "#{ENV['RAILS_RELATIVE_URL_ROOT']}/iframe/image_page/" + file.id.to_s
        else
          return 'iframe/image_page/' + file.id.to_s
        end
      when 'v' then
        if ENV['RAILS_RELATIVE_URL_ROOT']
          return "#{ENV['RAILS_RELATIVE_URL_ROOT']}/iframe/video_page/" + file.id.to_s
        else
          return 'iframe/video_page/' + file.id.to_s
        end
      end
    end
  end

  def get_page_num(page_num, max_page_num)
    page_num = page_num.to_i
    return max_page_num if page_num == -1 # -1 page_num is for assignment page
    [[0, page_num].max, max_page_num].min
  end

  def get_stickies(content_id, target_type, target_id = nil)
    if target_id
      stickies = Sticky.where(manager_id: session[:id], content_id: content_id, target_type: target_type, target_id: target_id).limit(100)
    else
      stickies = Sticky.where(manager_id: session[:id], content_id: content_id, target_type: target_type).limit(1000)
    end
    sort_sticky stickies
  end

  def get_course_stickies(course_id, target_type, content_id = nil)
    stickies = Sticky.where(category: 'private', manager_id: session[:id], content_id: content_id, target_type: target_type).limit(200).to_a
    c_stickies = Sticky.where(category: 'course', course_id: course_id, content_id: content_id, target_type: target_type).limit(400).to_a
    c_stickies.select! { |s| s.related_to? session[:id] } if session[:related_course_stickies]
    stickies += c_stickies
    sort_sticky stickies
  end

  def get_course_stickies_by_target(course_id, target_type, target_id, content_id = nil)
    if content_id
      stickies = Sticky.where(category: 'private', manager_id: session[:id], content_id: content_id, target_type: target_type, target_id: target_id).limit(100).to_a
      c_stickies = Sticky.where(category: 'course', course_id: course_id, content_id: content_id, target_type: target_type, target_id: target_id).limit(200).to_a
    else
      stickies = Sticky.where(category: 'private', manager_id: session[:id], target_type: target_type, target_id: target_id).limit(100).to_a
      c_stickies = Sticky.where(category: 'course', course_id: course_id, target_type: target_type, target_id: target_id).limit(200).to_a
    end
    c_stickies.select! { |s| s.related_to? session[:id] } if session[:related_course_stickies]
    stickies += c_stickies
    sort_sticky stickies
  end

  def sort_sticky(stickies)
    stickies = stickies.to_a
    case session[:star_sort_stickies]
    when true
      stickies.sort! do |a, b|
        (b.stars_count <=> a.stars_count).nonzero? ||
        (b.created_at <=> a.created_at)
      end
    when false
      stickies.sort! { |a, b| b.created_at <=> a.created_at }
    end
    stickies
  end

  def csv_to_member_candidates(users_in_csv, manager_changeable, category, resource_id)
    candidates = []
    CSV.parse(users_in_csv) do |row|
      unless appropriate_member_format? row
        flash[:message] = 'CSVデータに、不適切なフォーマットの行があります'
        flash[:message_category] = 'error'
        return candidates
      end

      signin_name = row[0].strip
      member_role = row[1].strip

      user = User.find_by_signin_name(signin_name)
      if user
        current_relation = ContentMember.find_by_content_id_and_user_id(resource_id, user.id) if category == 'content'
        current_relation = CourseMember.find_by_course_id_and_user_id(resource_id, user.id) if category == 'course'
        current_role = current_relation ? current_relation.role : ''

        if current_role == 'manager'
          candidates.push [user, 'manager', member_role] if manager_changeable && (member_role != 'manager')
        elsif member_role != current_role
          candidates.push [user, current_role, member_role]
        end
      end
    end
    candidates
  end

  def appropriate_member_format?(row)
    # signin_name, category
    return false if row.size != 2
    return false if row[0].nil? || row[1].nil?
    true
  end

  # 2. page replacer ===========================================================
  def render_content_page(pg, force_replace_all = false)
    case session[:page_num]
    when 0
      resource_name = 'layouts/cover_page'
    when session[:max_page_num]
      resource_name = 'layouts/assignment_page'
    else
      resource_name = 'layouts/page_viewer'
    end

    force_replace_all = true if (session[:nav_section] == 'open_courses') && (session[:page_num].zero? || (session[:page_num] == session[:max_page_num]))
    if force_replace_all
      # to spped up page operation, marked resource check is executed only when top or assignment page showed
      render 'layouts/renders/all_with_pg', locals: { resource: resource_name, pg: pg }
    else
      render 'layouts/renders/main_pane_with_pg', locals: { resource: resource_name, pg: pg }
    end
  end

  # FIXME: PushNotification
  # def send_push_notification(registration_id)
  #   fcm_url = 'https://fcm.googleapis.com/fcm/send'
  #   payload = "{\"registration_ids\":[\"" + registration_id + "\"],\"delay_while_idle\":true,\"collapse_key\":\"lepo\"}"
  #   headers = { content_type: :json, accept: :json, Authorization: 'key=' + FCM_AUTHORIZATION_KEY }
  #   RestClient.post fcm_url, payload, headers
  # end

  # ====================================================================
  # Private Functions
  # ====================================================================

  private

  def dashboard_archive_card(user)
    list = []
    card_display_days = 14
    archived_courses = Course.archived_courses_in_days user.id, card_display_days
    archived_courses.each do |course|
      list.push(title: course.title, controller: 'courses', action: 'ajax_index', nav_section: 'repository', nav_id: course.id)
    end

    return [] if list.size.zero?
    [{ header: '保管庫に移動したコース', content: "以下のコースは、過去#{card_display_days}日以内に終了処理が行われたため保管庫に移動しました。", list: list }]
  end

  def dashboard_evaluation_card(user, role)
    return [] if user.system_staff?

    list = []
    courses = Course.associated_by user.id, role
    courses.delete_if { |c| c.status != 'open' }
    courses.each do |course|
      course.lessons.each do |lesson|
        marked_outcome_num = get_marked_outcome_num(lesson.id, lesson.user_role(user.id))
        next unless marked_outcome_num > 0
        nav_section = course.status == 'open' ? 'open_courses' : 'repository'
        case role
        when 'learner'
          list.push(title: course.title + ' / Lesson ' + lesson.display_order.to_s, controller: 'courses', action: 'ajax_show_page_with_transition', nav_section: nav_section, nav_id: course.id, lesson_id: lesson.id, page_num: '-1')
        when 'manager'
          list.push(title: course.title + ' / Lesson ' + lesson.display_order.to_s + ' : 評価依頼' + marked_outcome_num.to_s + '件', controller: 'courses', action: 'ajax_show_page_with_transition', nav_section: nav_section, nav_id: course.id, lesson_id: lesson.id, page_num: '-1')
        end
      end
    end

    return [] if list.size.zero?
    case role
    when 'learner'
      [{ header: '未読の課題評価', content: '以下のレッスンに未読の課題評価があります。', list: list }]
    when 'manager'
      [{ header: '未評価の提出課題', content: '以下のレッスンに未評価の提出課題があります。', list: list }]
    end
  end

  def get_page_file_id(content, page_num, max_page_num)
    case page_num
    when 0
      0
    when 1..(max_page_num - 1)
      page_file = content.page_files[page_num - 1]
      page_file.id
    when max_page_num
      -1
    end
  end
end
