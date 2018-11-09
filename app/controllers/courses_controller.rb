class CoursesController < ApplicationController
  include ::NoticesController::AllActions
  include ::StickiesController::AllActions
  # ====================================================================
  # Public Functions
  # ====================================================================
  def ajax_index
    record_user_action('read', params[:nav_id])
    render_course_index(params[:nav_section], params[:nav_id])
  end

  def ajax_index_by_system_staff
    course = Course.find_enabled_by params[:id]
    if course.nil? || (!User.system_staff? session[:id])
      ajax_index_no_course
      render 'layouts/renders/main_pane_candidates', locals: { resource: 'select_course' }
    else
      record_user_action('read', params[:nav_id])
      render_course_index(course.status, course.id)
    end
  end

  def ajax_show
    set_star_sort_stickies_session
    set_related_course_stickies_session
    @course = Course.find_enabled_by params[:id]
    @lesson = Lesson.find params[:lesson_id]
    @content = @lesson.content
    set_page_session 0, @content
    set_sticky_panel_session
    pg = get_page(@lesson.id, @content)
    @sticky = Sticky.new(content_id: @content.id, course_id: @course.id, target_id: pg['file_id'])
    record_user_action('read', @course.id, @lesson.id, @content.id, pg['file_id'])
    render 'layouts/renders/all_with_pg', locals: { resource: 'layouts/cover_page', pg: pg }
  end

  def ajax_toggle_lesson_note
    return unless session[:nav_id] > 0 && session[:content_id] > 0 && session[:page_num]
    @course = Course.find_enabled_by session[:nav_id]
    @content = Content.find session[:content_id]
    @lesson = Lesson.find_by(course_id: @course.id, content_id: @content.id)
    pg = get_page(@lesson.id, @content)
    case params[:from]
    when 'content'
      @note = @course.lesson_note(session[:id])
      @note_items = @note.note_indices
      render 'layouts/renders/main_pane_with_pg', locals: { resource: '/notes/show', pg: pg }
    when 'note'
      @sticky = Sticky.new(content_id: @content.id, course_id: @course.id, target_id: pg['file_id'])
      get_outcome_resources @lesson, @content
      @message_templates = get_message_templates(@course.manager?(session[:id])) if session[:page_num] == session[:max_page_num]
      render_content_page pg
    end
  end

  def ajax_show_lesson_note_from_others
    set_nav_session params[:nav_section], 'courses', params[:nav_id].to_i
    @course = Course.find_enabled_by session[:nav_id]
    @lesson = Lesson.find_by(id: params[:lesson_id])
    @content = @lesson.content
    set_page_session 0, @content
    pg = get_page @lesson.id, @content
    @note = @course.lesson_note(session[:id])
    @note_items = @note.note_indices
    render 'layouts/renders/all_with_pg', locals: { resource: '/notes/show', pg: pg }
  end

  def ajax_show_page
    set_related_course_stickies_session
    @course = Course.find_enabled_by session[:nav_id]
    @content = Content.find session[:content_id]
    @lesson = Lesson.find_by(course_id: @course.id, content_id: @content.id)
    set_page_session params[:page_num].to_i, @content
    set_sticky_panel_session
    pg = get_page(@lesson.id, @content)
    @sticky = Sticky.new(content_id: @content.id, course_id: @course.id, target_id: pg['file_id'])
    get_outcome_resources @lesson, @content
    @message_templates = get_message_templates(@course.manager?(session[:id])) if session[:page_num] == session[:max_page_num]
    record_user_action('read', @course.id, @lesson.id, @content.id, pg['file_id'])
    render_content_page pg
  end

  def ajax_show_page_from_sticky
    set_star_sort_stickies_session
    set_related_course_stickies_session
    @course = Course.find_enabled_by params[:course_id]
    nav_section = @course.status == 'open' ? 'open_courses' : 'repository'
    @content = Content.find params[:content_id]
    @lesson = Lesson.find_by(course_id: @course.id, content_id: @content.id)
    page_num = Page.find_by(id: params[:target_id].to_i).display_order
    set_nav_session nav_section, 'courses', params[:course_id]
    set_page_session page_num, @content

    pg = get_page @lesson.id, @content
    @sticky = Sticky.new(content_id: @content.id, course_id: @course.id, target_id: pg['file_id'])
    set_sticky_panel_session
    get_outcome_resources @lesson, @content
    @message_templates = get_message_templates(@course.manager?(session[:id])) if session[:page_num] == session[:max_page_num]

    record_user_action('read', @course.id, @lesson.id, @content.id, pg['file_id'])
    render_content_page pg, true
  end

  def ajax_show_page_from_others
    set_related_course_stickies_session
    session[:nav_section] = params[:nav_section]
    session[:nav_controller] = 'courses'
    session[:nav_id] = params[:nav_id].to_i

    @course = Course.find_enabled_by params[:nav_id]
    @lesson = Lesson.find params[:lesson_id]
    @content = @lesson.content
    set_page_session params[:page_num].to_i, @content if params[:page_num]

    page_num = session[:page_num] ? session[:page_num].to_i : 0
    set_page_session page_num, @content
    pg = get_page @lesson.id, @content
    @sticky = Sticky.new(content_id: @content.id, course_id: @course.id, target_id: pg['file_id'])
    set_sticky_panel_session
    get_outcome_resources @lesson, @content
    @message_templates = get_message_templates(@course.manager?(session[:id])) if session[:page_num] == session[:max_page_num]

    record_user_action('read', @course.id, @lesson.id, @content.id, pg['file_id'])
    render_content_page pg, true
  end

  def ajax_course_pref
    # for security reason
    if User.system_staff? session[:id]
      render 'layouts/renders/main_pane', locals: { resource: 'course_pref' }
    else
      head :ok
    end
  end

  def ajax_create
    @course = Course.new(course_params)
    unless @course.term_id
      flash[:message] = 'コースを登録できる学期がありません。システム管理者に相談して下さい。'
      flash[:message_category] = 'error'
      @course.fill_goals
      render 'layouts/renders/resource', locals: { resource: 'new' }
      return
    end
    if @course.save
      if register_course_managers
        set_nav_session 'repository', 'courses', @course.id
        get_content_array # for new lesson creation
        record_user_action('created', @course.id)
        render 'layouts/renders/all', locals: { resource: 'edit_lessons' }
      else
        flash[:message] = 'コースと教師の関連づけに失敗しました'
        flash[:message_category] = 'error'
        @course.fill_goals
        render 'layouts/renders/resource', locals: { resource: 'new' }
      end
    else
      flash[:message] = 'コースの作成に失敗しました'
      flash[:message_category] = 'error'
      @course.fill_goals
      render 'layouts/renders/resource', locals: { resource: 'new' }
    end
  end

  def ajax_create_lesson
    lesson = Lesson.new(lesson_params)

    lesson.course_id = params[:id]
    lesson.status = LESSON_STATUS_DEFAULT
    lesson.save

    lesson.content.objectives.each { |o| GoalsObjective.create(lesson_id: lesson.id, objective_id: o.id, goal_id: 0) }

    @course = Course.find_enabled_by params[:id]
    get_content_array # for new lesson creation
    record_user_action('created', @course.id, lesson.id)
    render 'layouts/renders/resource', locals: { resource: 'courses/edit_lessons' }
  end

  def ajax_create_snippet
    return unless session[:nav_id] > 0 && session[:page_num].between?(0, session[:max_page_num])
    @course = Course.find_enabled_by session[:nav_id]
    @content = Content.find session[:content_id]
    @lesson = Lesson.find_by(course_id: @course.id, content_id: @content.id)
    note = @course.lesson_note(session[:id])
    display_order = note.note_indices.size + 1

    Snippet.transaction do
      snippet = Snippet.create!(manager_id: session[:id], category: 'text', description: params[:description], source_type: 'page', source_id: @content.page_id(session[:page_num]))
      NoteIndex.create!(note_id: note.id, item_id: snippet.id, item_type: 'Snippet', display_order: display_order)
      record_user_action('created', @course.id, @lesson.id, @content.id, snippet.source_id, nil, nil, snippet.id, nil, nil)
    end
    note.update_items(@course.open_lessons)

    pg = get_page(@lesson.id, @content)
    @sticky = Sticky.new(content_id: @content.id, course_id: @course.id, target_id: pg['file_id'])

    render 'courses/renders/snippet_saved', locals: { pg: pg }
  end

  def ajax_destroy
    @course = Course.find_enabled_by params[:id]
    @course.destroy if @course.deletable? session[:id]
    record_user_action('deleted', @course.id)
    redirect_to controller: 'contents', action: 'ajax_index', nav_section: 'home', nav_id: 0
  end

  def ajax_destroy_lesson
    @course = Course.find_enabled_by params[:id]
    lesson = Lesson.find params[:lesson_id]

    if lesson.deletable? session[:id]
      record_user_action('deleted', @course.id, lesson.id)
      lesson.destroy
      @course.lessons.each_with_index do |lsn, i|
        lsn.update_attributes(display_order: i + 1)
      end
      @course.reload
    else
      flash[:message] = '課題提出やふせん添付があるレッスンは、削除できません'
      flash[:message_category] = 'error'
    end

    get_content_array
    render 'layouts/renders/resource', locals: { resource: 'courses/edit_lessons' }
  end

  def ajax_destroy_snippet
    snippet = Snippet.find_by(id: params[:snippet_id])
    if snippet.deletable?(session[:id])
      lesson = Lesson.find_by(course_id: session[:nav_id], content_id: session[:content_id])
      if lesson && (snippet.source_type == 'page')
        record_user_action('deleted', session[:nav_id], lesson.id, session[:content_id], snippet.source_id, nil, nil, snippet.id, nil, nil)
      end
      snippet.destroy
    end
    head :no_content
  end

  def ajax_duplicate
    original_course = Course.find_enabled_by params[:original_id]
    return unless original_course

    @course = Course.new(course_params)
    @course.overview = original_course.overview
    if @course.save
      record_user_action('created', @course.id)
      course_member = CourseMember.new(course_id: @course.id, user_id: session[:id], role: 'manager')
      if course_member.save
        original_course.duplicate_goals_to @course.id
        original_course.duplicate_lessons_to @course.id, session[:id]
        set_nav_session 'repository', 'courses', @course.id
        @course.fill_goals
        render 'layouts/renders/all', locals: { resource: 'courses/edit' }
      else
        render_duplicate_error('コースと教師の関連づけに失敗しました', params[:original_id].to_i)
      end
    else
      render_duplicate_error('コースの複製に失敗しました', params[:original_id].to_i)
    end
  end

  def ajax_edit
    @course = Course.find_enabled_by params[:id]
    @course.fill_goals
    render 'layouts/renders/main_pane', locals: { resource: 'courses/edit' }
  end

  def ajax_new
    set_nav_session 'repository', 'courses', 0
    @course = Course.new
    @course.fill_goals
    @course.goals[0].title = '...'
    render 'layouts/renders/all_with_sub_toolbar', locals: { resource: 'new' }
  end

  def ajax_update
    @course = Course.find_enabled_by params[:id]
    course_form = course_params
    course_form[:status] = @course.status if @course.status != 'draft' && course_form[:status] == 'draft'
    # Remedy for both new file upload and delete_image are selected
    course_form.delete(:remove_image) if course_form[:image] && course_form[:image].size.nonzero?

    if all_blank_title? course_form[:goals_attributes]
      flash[:message] = '到達目標を、1つ以上設定する必要があります'
      flash[:message_category] = 'error'
      @course.fill_goals
      render 'layouts/renders/resource', locals: { resource: 'edit' }
    elsif !register_course_managers
      flash[:message] = 'コースと教師の関連づけに失敗しました'
      flash[:message_category] = 'error'
      @course.fill_goals
      render 'layouts/renders/resource', locals: { resource: 'edit' }
    else
      destroy_blank_goals(course_form[:goals_attributes])

      if @course.update_attributes course_form
        record_user_action('updated', @course.id)
        # update lesson note
        @course.update_lesson_notes
        check_course_groups course_form[:groups_count]
        case @course.status
        when 'archived'
          render_course_index('repository', @course.id)
        else
          get_content_array # for new lesson creation
          flash.discard
          render 'layouts/renders/all', locals: { resource: 'edit_lessons' }
        end
      else
        @course.fill_goals
        render 'layouts/renders/resource', locals: { resource: 'edit' }
      end
    end
  end

  def ajax_update_association
    # update goal - objective association
    @course = Course.find_enabled_by params[:id]
    get_content_array
    if params[:association_id]
      association = GoalsObjective.find params[:association_id]
      if params[:g_id].to_i.zero?
        association.destroy
      else
        association.update_attributes(goal_id: params[:g_id])
      end
    else
      GoalsObjective.create(lesson_id: params[:lesson_id], objective_id: params[:objective_id], goal_id: params[:g_id])
    end
    render 'layouts/renders/resource', locals: { resource: 'courses/edit_lessons' }
  end

  def ajax_update_evaluator_from
    @course = Course.find_enabled_by params[:id]
    set_lesson_evaluator @course.managers, params[:lesson_id]
    get_content_array
    render 'layouts/renders/resource', locals: { resource: 'courses/edit_lessons' }
  end

  def ajax_update_lesson_status
    set_lesson_status params[:lesson_id], params[:status]
    case params[:page]
    when 'index'
      @course = Course.find_enabled_by params[:id]
      @goals = get_goal_resources @course
      @marked_lessons = marked_lessons @course.id
      @lesson_resources = get_lesson_resources @course.lessons
      @course.lesson_note(session[:id]).update_items(@course.open_lessons)
      render 'layouts/renders/resource', locals: { resource: 'index' }
    when 'edit_lessons'
      get_content_array
      render 'layouts/renders/resource', locals: { resource: 'courses/edit_lessons' }
    end
  end

  def ajax_search_courses
    @candidates = Course.search(params[:term_id], params[:status], params[:title], params[:manager])
    if @candidates.size.zero? || (!User.system_staff? session[:id])
      ajax_index_no_course
    end
    render 'layouts/renders/main_pane_candidates', locals: { resource: 'select_course' }
  end

  def ajax_sort_lessons
    params[:lesson].each_with_index { |id, i| Lesson.update(id, display_order: i + 1) }
    @course = Course.find_enabled_by params[:id]
    get_content_array
    render 'layouts/renders/resource', locals: { resource: 'courses/edit_lessons' }
  end

  def show_image
    @course = Course.find_enabled_by params[:id]
    if %w[px40 px80 px160].include? params[:version]
      image_id = @course.image_id(params[:version])
      return nil unless params[:file_id] == image_id
      url = @course.image_url(params[:version].to_sym).to_s
      filepath = Rails.root.join('storage', url[1, url.length-1])
      send_file filepath, disposition: "inline"
    end
  end

  # ====================================================================
  # Private Functions
  # ====================================================================

  private

  def ajax_index_no_course
    @candidates = nil
    flash[:message] = t('controllers.courses.no_courses_with_criteria')
    flash[:message_category] = 'error'
  end

  def course_params
    params.require(:course).permit(:image, :remove_image, :title, :term_id, :overview, :weekday, :period, :status, :groups_count, goals_attributes: %i[title id])
  end

  def lesson_params
    params.require(:lesson).permit(:evaluator_id, :content_id, :course_id, :display_order, :status)
  end

  def check_course_groups(groups_count)
    deleted_group_learners = @course.course_members.where('course_members.role = ? and course_members.group_index >= ?', 'learner', groups_count)
    deleted_group_learners.each do |dgl|
      dgl.update_attributes(group_index: groups_count.to_i - 1)
    end
  end

  def get_content_array
    @content_array = []
    @course.managers.each do |cm|
      @content_array += Content.associated_by_with_status cm.id, 'manager', 'open'
      @content_array += Content.associated_by_with_status cm.id, 'assistant', 'open'
      @content_array += Content.associated_by_with_status cm.id, 'user', 'open'
    end
    @content_array.sort! { |a, b| a.updated_at <=> b.updated_at }
    @content_array.reverse!
    @content_array.map! { |c| [c.title, c.id] }

    @course.lessons.each do |lesson|
      @content_array.delete_if { |x| x[1] == lesson.content.id }
    end
  end

  def get_goal_resources(course)
    resources = []
    course.goals.each do |goal|
      resources.push goal_resource(course, goal)
    end
    ngr = no_goal_resource(course)
    resources.push(ngr) if ngr['id']
    resources
  end

  def get_lesson_resources(lessons)
    lr = {}
    lr['score'] = 0
    lr['self_eval'] = []
    lr['non_self_eval'] = []
    lessons.each do |lesson|
      outcome = Outcome.find_by(lesson_id: lesson.id, manager_id: session[:id])
      lr['score'] += outcome.score if outcome && outcome.score

      if outcome && outcome.self_evaluated?
        lr['self_eval'].push lesson if lesson.status == 'open'
      else
        lr['non_self_eval'].push lesson if lesson.status == 'open'
      end
    end
    lr
  end

  def goal_resource(course, goal)
    go_re = {}
    go_re['id'] = goal.id
    go_re['title'] = goal.title
    go_re['self_allocation_sum'] = 0

    ob_res = []
    goal.objectives.each do |objective|
      ob_re = objective_resource(course.id, objective)
      ob_al = objective.allocation
      go_re['self_allocation_sum'] += ob_al
      ob_res.push(title: objective.title, display_order: ob_re['lesson_display_order'], self_allocation: ob_al)
    end
    ob_res.sort! { |a, b| a[:display_order] <=> b[:display_order] }
    go_re['objectives'] = ob_res
    go_re
  end

  def marked_lessons(course_id)
    lessons = {}
    course = Course.find_enabled_by course_id
    user_id = session[:id]
    user_role = course.user_role user_id
    return lessons unless %w[manager learner].include? user_role

    course.lessons.each do |lesson|
      lesson = { lesson.id => lesson.marked_outcome_num(user_id) }
      lessons.merge! lesson
    end
    lessons
  end

  def no_goal_resource(course)
    go_re = {}
    ob_no = []
    ob_res = []

    course.open_lessons.each do |le|
      le.no_goal_objectives.each do |obj|
        ob_no.push obj
      end
    end

    return go_re if ob_no.size.zero?

    go_re['id'] = 0
    go_re['title'] = '（その他）'
    go_re['self_allocation_sum'] = 0

    ob_no.each do |objective|
      ob_re = objective_resource course.id, objective
      ob_al = objective.allocation
      go_re['self_allocation_sum'] += ob_al
      ob_res.push(title: objective.title, display_order: ob_re['lesson_display_order'], self_allocation: ob_al)
    end

    ob_res.sort! { |a, b| a[:display_order] <=> b[:display_order] }
    go_re['objectives'] = ob_res
    go_re
  end

  def objective_resource(course_id, objective)
    ob_re = {}
    lesson = Lesson.find_by(course_id: course_id, content_id: objective.content_id)
    ob_re['content_id'] = objective.content_id
    ob_re['lesson_display_order'] = lesson.display_order
    ob_re
  end

  #============================================================================================

  def get_next_evaluator(managers, lesson)
    evaluators = [0]

    # if there are non_draft outcomes already, possible evaluator transitions are between managers only
    outcomes = lesson.outcomes
    if outcomes
      non_draft_outcomes = outcomes.reject { |x| x.status == 'draft' }
      evaluators = [] if non_draft_outcomes && !non_draft_outcomes.empty?
    end

    managers.each do |manager|
      evaluators.push manager.id
    end
    next_evaluator_index = evaluators.index(lesson.evaluator_id) + 1
    next_evaluator_index = 0 if next_evaluator_index == evaluators.size
    evaluators[next_evaluator_index]
  end

  def destroy_blank_goals(attributes)
    attributes.each do |_key, attribute|
      next unless attribute[:id] && attribute[:title].blank?
      goal = Goal.find attribute[:id]
      goal.goals_objectives.each do |go|
        go.update_attributes(goal_id: 0)
      end
      attribute['_destroy'] = 'true'
    end
  end

  def set_lesson_evaluator(managers, lesson_id)
    @lesson = Lesson.find lesson_id
    @lesson.update_attributes(evaluator_id: get_next_evaluator(managers, @lesson))
    @marked_lessons = marked_lessons @lesson.course_id
  end

  def set_lesson_status(lesson_id, status)
    @lesson = Lesson.find lesson_id
    @lesson.update_attributes(status: status)
    @course = Course.find_enabled_by params[:id]
    @marked_lessons = marked_lessons @course.id
  end

  def render_duplicate_error(message, course_id)
    flash[:message] = message
    @course = Course.find_enabled_by course_id
    @course.fill_goals
    render 'layouts/renders/resource', locals: { resource: 'courses/edit' }
  end

  def register_course_managers
    current_ids = @course.manager_ids
    ids = params[:managers].nil? ? [] : ids_from_user_hash_l(params[:managers].values)
    if ids.empty?
      ids = current_ids.empty? ? [session[:id]] : current_ids.dup
    end
    CourseMember.update_managers @course.id, current_ids, ids
  end

  def ids_from_user_hash_l(values)
    ids = []
    values.each do |v|
      ids.push(v['id'].to_i) unless Integer(v['id']).nil?
    end
    ids
  end

  def render_course_index(nav_section, course_id)
    set_nav_session nav_section, 'courses', course_id
    @course = Course.find_enabled_by course_id
    @goals = get_goal_resources @course
    @marked_lessons = marked_lessons @course.id
    @lesson_resources = get_lesson_resources @course.lessons
    # update items in lesson note
    @course.lesson_note(session[:id]).update_items(@course.open_lessons) if @course.member? session[:id]
    render 'layouts/renders/all', locals: { resource: 'index' }
  end
end
