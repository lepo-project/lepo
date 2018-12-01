require 'csv'
class CourseMembersController < ApplicationController
  include ::UsersController::AllActions
  include ::StickiesController::AllActions
  # ====================================================================
  # Public Functions
  # ====================================================================
  def ajax_index
    set_nav_session params[:nav_section], 'course_members', params[:nav_id].to_i
    get_resources
    render 'layouts/renders/all', locals: { resource: 'index' }
  end

  def ajax_show(transition = false)
    @selected_user = User.find params[:id]
    get_resources
    @stickies = course_stickies_by_user @selected_user.id, session[:nav_id]
    if transition
      render 'layouts/renders/all', locals: { resource: 'users/user' }
    else
      render 'layouts/renders/main_pane', locals: { resource: 'users/user' }
    end
  end

  def ajax_show_with_transition
    # ajax show with in-course transition
    set_nav_session session[:nav_section], 'course_members', session[:nav_id]
    ajax_show true
  end

  def ajax_edit
    get_resources
    @form_category = ''
    @member_role = 'learner'
    render 'layouts/renders/main_pane', locals: { resource: 'course_members/edit' }
  end

  def ajax_edit_group
    get_resources
    render 'layouts/renders/main_pane', locals: { resource: 'course_members/edit_group' }
  end

  def ajax_csv_candidates
    @form_category = 'csv'
    @member_role = ''
    @search_word = ''
    @candidates_csv = params[:candidates_csv] ? params[:candidates_csv] : ''

    get_resources
    manageable = @course.manager_changeable? session[:id]
    @candidates = csv_to_member_candidates @candidates_csv, manageable, 'course', @course.id
    render 'layouts/renders/resource', locals: { resource: 'course_members/edit' }
  end

  def ajax_search_candidates
    @form_category = 'search'
    @member_role = params[:member_role] ? params[:member_role] : ''
    @search_word = params[:search_word] ? params[:search_word] : ''
    @candidates_csv = ''

    candidates = User.search @search_word
    get_resources
    case @member_role
    when 'manager'
      candidates = delete_existing candidates, @course.managers
    when 'assistant'
      candidates = delete_existing candidates, @course.assistants
      candidates = delete_existing candidates, @course.managers unless @course.manager_changeable? session[:id]
    when 'learner'
      candidates = delete_existing candidates, @course.learners
      candidates = delete_existing candidates, @course.managers unless @course.manager_changeable? session[:id]
    end

    if session[:nav_id]
      current_categories = []
      candidates.each do |cn|
        current_relation = CourseMember.find_by(user_id: cn.id, course_id: session[:nav_id])
        current_role = current_relation ? current_relation.role : ''
        current_categories.push current_role
      end
      @candidates = candidates.zip current_categories, Array.new(candidates.size, @member_role)
    end
    render 'layouts/renders/resource', locals: { resource: 'course_members/edit' }
  end

  def ajax_update_role
    if params[:update_to] == 'none'
      course_member = CourseMember.find_by(user_id: params[:user_id], course_id: params[:course_id])
      if course_member && course_member.deletable?
        course_member.destroy
      else
        if course_member.role == 'manager'
          flash.now[:message] = 'レッスンの評価担当者、またはコース内でふせんを記載している場合は削除できません。'
        else
          flash.now[:message] = 'コース内でふせんを記載しているユーザ、または課題を提出済みの学生ユーザは削除できません'
        end
        flash[:message_category] = 'error'
      end
    else
      update_role params[:user_id], params[:course_id], params[:update_to]
    end

    # replace page process
    case params[:form_category]
    when 'search'
      ajax_search_candidates
    when 'csv'
      ajax_csv_candidates
    else
      ajax_edit
    end
  end

  def ajax_update_group
    course_id = session[:nav_id]
    user_id = params[:user_id]
    group_index = params[:group_index]

    cm = CourseMember.find_by(user_id: user_id, course_id: course_id)
    cm.update_attributes(group_index: group_index)
    get_resources
    render 'layouts/renders/main_pane', locals: { resource: 'course_members/edit_group' }
  end

  def ajax_get_managers
    manager_ids = params[:manager_ids].nil? ? [] : params[:manager_ids]
    case params[:category]
    when 'release' then
      course_user = CourseMember.find_by(course_id: params[:course_id], user_id: params[:manager_id])
      if course_user.nil? || course_user.deletable?
        manager_ids.delete(params[:manager_id])
      else
        flash.now[:message] = 'レッスンの評価担当者、またはコース内でふせんを記載している場合は削除できません。'
        flash[:message_category] = 'error'
      end
    when 'add' then
      user = User.find_by(id: params[:manager_id])
      manager_ids.push(user.id) unless user.nil?
    end
    managers = []
    manager_ids.each do |manager_id|
      user = User.find_by(id: manager_id)
      managers.push(user) unless user.nil?
    end
    render 'courses/renders/tmp_managers', locals: { managers: managers, course_id: session[:nav_id], message: flash.now[:message], message_category: flash[:message_category] }
  end

  def autocomplete_manager
    if invalid_autocomplete_request?(params[:search_word])
      render json: []
    else
      users = User.autocomplete params[:search_word]
      user_suggestions = []
      excludes = exclude_members(params[:tmp_managers], params[:course_id])
      users.each do |u|
        # for the case given_name is nil, to_s is added
        label = u.signin_name + ', ' + u.family_name + ' ' + u.given_name.to_s
        user_suggestions.push(value: u.id, label: label) unless excludes.include?(u.id)
      end
      user_suggestions.slice!(AUTOCOMPLETE_MAX_SIZE...user_suggestions.size)
      render json: user_suggestions
    end
  end

  # ====================================================================
  # Private Functions
  # ====================================================================

  private

  def get_resources
    @course = Course.find_enabled_by session[:nav_id]
    @managers = User.sort_by_signin_name @course.managers
    @assistants = User.sort_by_signin_name @course.assistants
    @learners = User.sort_by_signin_name @course.learners
  end

  def update_role(user_id, course_id, role)
    course_member = CourseMember.find_by(user_id: user_id, course_id: course_id)
    course = Course.find_enabled_by course_id
    if course_member
      if (course_member.role == 'manager') && (course.evaluator? user_id)
        flash.now[:message] = 'レッスンの評価担当者は、教師である必要があります'
        flash[:message_category] = 'error'
      else
        unless course_member.update_attributes(role: role)
          flash.now[:message] = 'コース管理者は、コース管理権限のあるユーザのみ登録できます'
          flash[:message_category] = 'error'
        end
      end
    else
      new_coourse_user = CourseMember.new(user_id: user_id, course_id: course_id, role: role)
      unless new_coourse_user.save
        flash.now[:message] = 'コース管理者は、コース管理権限のあるユーザのみ登録できます'
        flash[:message_category] = 'error'
      end
    end
  end

  def invalid_autocomplete_request?(param)
    request.get? || param.nil? || param.empty? || !User.system_staff?(session[:id])
  end

  def exclude_members(tmp_managers, course_id)
    excludes = tmp_managers.nil? ? [] : tmp_managers.map(&:to_i)
    # Considering that the value of course_id is -1 (new course), use find_by instead of find
    course = Course.find_enabled_by course_id
    return excludes if course.nil?
    learners = course.learners
    learners.each do |l|
      excludes.push(l.id)
    end
    assistants = course.assistants
    assistants.each do |a|
      excludes.push(a.id)
    end
    excludes
  end
end
