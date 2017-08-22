class CoursesController < ApplicationController
  include ::NoticesController::AllActions
  include ::StickiesController::AllActions
  # ====================================================================
  # Public Functions
  # ====================================================================
  def ajax_index
    render_course_index(params[:nav_section], params[:nav_id])
  end

  def ajax_delete_image
    course = Course.find(params[:id].to_i)
    if course.staff? session[:id]
      course.image.clear
      flash[:message] = '画像を削除しました。' if course.save
      flash[:message_category] = 'info'
    end
    ajax_edit
  end

  def ajax_show
    set_star_sort_stickies_session
    set_related_course_stickies_session
    @course = Course.find(params[:id].to_i)
    @lesson = Lesson.find params[:lesson_id].to_i
    @content = @lesson.content
    set_page_session 0, @content
    set_sticky_panel_session
    pg = get_page(@lesson.id, @content)
    @sticky = Sticky.new(content_id: @content.id, course_id: @course.id, target_type: 'page', target_id: pg['file_id'])
    render 'layouts/renders/all_with_pg', locals: { resource: 'layouts/cover_page', pg: pg }
  end

  def ajax_show_page
    set_related_course_stickies_session
    @course = Course.find(session[:nav_id])
    @content = Content.find(session[:content_id])
    @lesson = Lesson.find_by_course_id_and_content_id(@course.id, @content.id)
    set_page_session params[:page_num].to_i, @content
    set_sticky_panel_session
    pg = get_page(@lesson.id, @content)
    @sticky = Sticky.new(content_id: @content.id, course_id: @course.id, target_type: 'page', target_id: pg['file_id'])
    get_outcome_resources @lesson, @content
    @message_templates = get_message_templates(@course.manager?(session[:id])) if session[:page_num] == session[:max_page_num]
    render_content_page pg
  end

  def ajax_show_page_from_sticky
    set_star_sort_stickies_session
    set_related_course_stickies_session
    @course = Course.find(params[:course_id].to_i)
    nav_section = @course.status == 'open' ? 'open_courses' : 'repository'
    @content = Content.find(params[:content_id].to_i)
    @lesson = Lesson.find_by_course_id_and_content_id(@course.id, @content.id)
    page_num = page_file_to_num params[:target_id]
    set_nav_session nav_section, 'courses', params[:course_id]
    set_page_session page_num, @content

    pg = get_page @lesson.id, @content
    @sticky = Sticky.new(content_id: @content.id, course_id: @course.id, target_type: 'page', target_id: pg['file_id'])
    set_sticky_panel_session
    get_outcome_resources @lesson, @content
    @message_templates = get_message_templates(@course.manager?(session[:id])) if session[:page_num] == session[:max_page_num]

    render_content_page pg, true
  end

  def ajax_show_page_with_transition
    set_related_course_stickies_session
    session[:nav_section] = params[:nav_section]
    session[:nav_controller] = 'courses'
    session[:nav_id] = params[:nav_id].to_i

    @course = Course.find(params[:nav_id].to_i)
    @lesson = Lesson.find(params[:lesson_id].to_i)
    @content = @lesson.content
    set_page_session params[:page_num].to_i, @content if params[:page_num]

    page_num = session[:page_num] ? session[:page_num].to_i : 0
    set_page_session page_num, @content
    pg = get_page @lesson.id, @content
    @sticky = Sticky.new(content_id: @content.id, course_id: @course.id, target_type: 'page', target_id: pg['file_id'])
    set_sticky_panel_session
    get_outcome_resources @lesson, @content
    @message_templates = get_message_templates(@course.manager?(session[:id])) if session[:page_num] == session[:max_page_num]

    render_content_page pg, true
  end

  def ajax_update_lesson_status_toolbar
    set_lesson_status params[:lesson_id], params[:status]
    @content = @lesson.content
    pg = get_page(@lesson.id, @content)

    render 'layouts/renders/main_toolbar_with_pg', locals: { pg: pg }
  end

  def ajax_new
    set_nav_session 'repository', 'courses', 0
    @course = Course.new(title: '（タイトル未定）')
    @course.fill_goals
    @course.goals[0].title = '(目標未定)'
    render 'layouts/renders/all_with_sub_toolbar', locals: { resource: 'new' }
  end

  def ajax_set_status
    render 'layouts/renders/status_flow', locals: { current_status: params[:current_status], selected_status: params[:selected_status] }
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

  def ajax_duplicate
    original_course = Course.find(params[:original_id].to_i)
    return unless original_course

    @course = Course.new(course_params)
    @course.overview = original_course.overview
    if @course.save
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

  def ajax_create_lesson
    lesson = Lesson.new(lesson_params)

    lesson.course_id = params[:id]
    lesson.status = LESSON_STATUS_DEFAULT
    lesson.save

    lesson.content.objectives.each { |o| GoalsObjective.create(lesson_id: lesson.id, objective_id: o.id, goal_id: 0) }

    @course = Course.find(params[:id].to_i)
    get_content_array # for new lesson creation
    render 'layouts/renders/resource', locals: { resource: 'courses/edit_lessons' }
  end

  def ajax_edit
    @course = Course.find(params[:id].to_i)
    @course.fill_goals
    render 'layouts/renders/main_pane', locals: { resource: 'courses/edit' }
  end

  def ajax_update
    @course = Course.find(params[:id].to_i)
    course_form = course_params

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
      set_destroy_for_blank(course_form[:goals_attributes])

      if @course.update_attributes course_form
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

  def ajax_destroy
    @course = Course.find(params[:id].to_i)
    @course.destroy if @course.deletable? session[:id]
    redirect_to controller: 'contents', action: 'ajax_index', nav_section: 'home', nav_id: 0
  end

  def ajax_update_association
    # update goal - objective association
    @course = Course.find(params[:id])
    get_content_array
    if params[:association_id]
      association = GoalsObjective.find(params[:association_id])
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

  def ajax_update_lesson_status
    set_lesson_status params[:lesson_id], params[:status]
    get_content_array
    render 'layouts/renders/resource', locals: { resource: 'courses/edit_lessons' }
  end

  def ajax_update_evaluator_from
    @course = Course.find(params[:id].to_i)
    set_lesson_evaluator @course.managers, params[:lesson_id]
    get_content_array
    render 'layouts/renders/resource', locals: { resource: 'courses/edit_lessons' }
  end

  def ajax_destroy_lesson
    @course = Course.find(params[:id])
    lesson = Lesson.find(params[:lesson_id])

    if lesson.deletable? session[:id]
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

  def ajax_sort_lessons
    params[:lesson].each_with_index { |id, i| Lesson.update(id, display_order: i + 1) }
    @course = Course.find(params[:id].to_i)
    get_content_array
    render 'layouts/renders/resource', locals: { resource: 'courses/edit_lessons' }
  end

  # ====================================================================
  # Private Functions
  # ====================================================================

  private

  def course_params
    params.require(:course).permit(:image, :title, :term_id, :overview, :status, :groups_count, goals_attributes: %i[title id])
  end

  def lesson_params
    params.require(:lesson).permit(:evaluator_id, :content_id, :course_id, :display_order, :status)
  end

  def check_course_groups(groups_count)
    deleted_group_learners = @course.course_members.where('course_members.role = ? and course_members.group_id >= ?', 'learner', groups_count)
    deleted_group_learners.each do |dgl|
      dgl.update_attributes(group_id: groups_count.to_i - 1)
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
      outcome = Outcome.find_by_lesson_id_and_manager_id(lesson.id, session[:id])
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
    course = Course.find course_id
    user_id = session[:id]
    user_role = course.user_role user_id
    return lessons unless %w[manager learner].include? user_role

    course.lessons.each do |lesson|
      lesson = { lesson.id => get_marked_outcome_num(lesson.id, lesson.user_role(user_id)) }
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
    lesson = Lesson.find_by_course_id_and_content_id course_id, objective.content_id
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

  def page_file_to_num(page_file_id)
    page_file_id = page_file_id.to_i
    case page_file_id
    when 0, -1
      page_file_id
    else
      sticky_page = PageFile.find(page_file_id)
      sticky_page.display_order
    end
  end

  def set_destroy_for_blank(attributes)
    attributes.each do |_key, attribute|
      next unless attribute[:id] && attribute[:title].blank?
      goal = Goal.find(attribute[:id])
      goal.goals_objectives.each do |go|
        go.update_attributes(goal_id: 0)
      end
      attribute['_destroy'] = 'true'
    end
  end

  def set_lesson_evaluator(managers, lesson_id)
    @lesson = Lesson.find(lesson_id.to_i)
    @lesson.update_attributes(evaluator_id: get_next_evaluator(managers, @lesson))
    @marked_lessons = marked_lessons @lesson.course_id
  end

  def set_lesson_status(lesson_id, status)
    @lesson = Lesson.find(lesson_id)
    @lesson.update_attributes(status: status)
    @course = Course.find(params[:id].to_i)
    @marked_lessons = marked_lessons @course.id
  end

  def render_duplicate_error(message, course_id)
    flash[:message] = message
    @course = Course.find(course_id)
    @course.fill_goals
    render 'layouts/renders/resource', locals: { resource: 'courses/edit' }
  end

  def register_course_managers
    current_ids = @course.managers.pluck(:id)
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

  def render_course_index(nav_section, nav_id)
    set_nav_session params[nav_section], 'courses', nav_id
    @user = User.find session[:id]
    @course = Course.find nav_id
    @goals = get_goal_resources @course
    @marked_lessons = marked_lessons @course.id
    @lesson_resources = get_lesson_resources @course.lessons
    render 'layouts/renders/all', locals: { resource: 'index' }
  end
end
