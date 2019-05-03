require 'csv'
class EnrollmentsController < ApplicationController
  include RosterApi
  include ::UsersController::AllActions
  include ::StickiesController::AllActions
  # ====================================================================
  # Public Functions
  # ====================================================================
  def new
    get_resources
    @form_category = ''
    @member_role = 'learner'
    render 'layouts/renders/main_pane', locals: { resource: 'enrollments/new' }
  end

  def create
    enrollment = Enrollment.find_or_initialize_by(course_id: params[:enrollment][:course_id], user_id: params[:enrollment][:user_id])
    role = params[:enrollment][:role]
    begin
      raise unless enrollment.new_record?
      raise unless Enrollment.creatable? enrollment.course_id, session[:id], role
      Enrollment.transaction do
        enrollment.role = role
        enrollment.save!
        if SYSTEM_ROSTER_SYNC == :on
          payload = {enrollment: enrollment.to_roster_hash}
          response = request_roster_api('/enrollments/', :post, payload)
          enrollment.update_attributes!(sourced_id: response['enrollment']['sourcedId'])
        end
      end
    rescue => error
      notify_error error, t('controllers.enrollments.creation_failed')
    end

    case params[:form_category]
    when 'search'
      ajax_search_candidates
    when 'csv'
      ajax_csv_candidates
    else
      new
    end
  end

  def edit
    @enrollment = Enrollment.find params[:id]
    @course = Course.find_enabled_by @enrollment.course_id
    @user = @enrollment.user
    render 'layouts/renders/main_pane', locals: { resource: 'enrollments/edit' }
  end

  def update
    @enrollment = Enrollment.find params[:id]
    @course = Course.find_enabled_by @enrollment.course_id
    @user = @enrollment.user
    from_role = @enrollment.role
    to_role = params[:enrollment][:role]
    begin
      raise unless @enrollment.updatable? session[:id]
      raise t('controllers.enrollments.evaluator_must_be_manager') if (to_role != 'manager') && (@course.evaluator? @user.id)
      Enrollment.transaction do
        @enrollment.update_attributes!(enrollment_params)
        if (SYSTEM_ROSTER_SYNC == :on) && (to_role != from_role)
          payload = {enrollment: @enrollment.to_roster_hash}
          response = request_roster_api("/enrollments/#{@enrollment.sourced_id}", :put, payload)
        end
      end
      render_index
    rescue => error
      notify_error error, t('controllers.enrollments.update_failed')
      render 'layouts/renders/main_pane', locals: { resource: 'enrollments/edit' }
    end
  end

  def destroy
    @enrollment = Enrollment.find params[:id]
    @course = Course.find_enabled_by @enrollment.course_id
    @user = @enrollment.user
    begin
      raise t('controllers.enrollments.evaluator_must_be_manager') if (@course.evaluator? @user.id)
      raise unless @enrollment.destroyable? session[:id]
      Enrollment.transaction do
        @enrollment.destroy!
        response = request_roster_api("/enrollments/#{@enrollment.sourced_id}", :delete) if (SYSTEM_ROSTER_SYNC == :on)
      end
      render_index
    rescue => error
      notify_error error, t('controllers.enrollments.delete_failed')
      render 'layouts/renders/main_pane', locals: { resource: 'enrollments/edit' }
    end
  end

  def ajax_index
    set_nav_session params[:nav_section], 'enrollments', params[:nav_id].to_i
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
    set_nav_session session[:nav_section], 'enrollments', session[:nav_id]
    ajax_show true
  end

  def ajax_edit_group
    get_resources
    render 'layouts/renders/main_pane', locals: { resource: 'enrollments/edit_group' }
  end

  def ajax_csv_candidates
    @form_category = 'csv'
    @member_role = ''
    @search_word = ''
    @candidates_csv = params[:candidates_csv] ? params[:candidates_csv] : ''

    get_resources
    manageable = @course.manager_changeable? session[:id]
    @candidates = csv_to_member_candidates @candidates_csv, manageable, 'course', @course.id
    render 'layouts/renders/resource', locals: { resource: 'enrollments/new' }
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
        current_relation = Enrollment.find_by(user_id: cn.id, course_id: session[:nav_id])
        current_role = current_relation ? current_relation.role : ''
        current_categories.push current_role
      end
      @candidates = candidates.zip current_categories, Array.new(candidates.size, @member_role)
    end
    render 'layouts/renders/resource', locals: { resource: 'enrollments/new' }
  end

  def ajax_update_group
    course_id = session[:nav_id]
    user_id = params[:user_id]
    group_index = params[:group_index]

    enrollment = Enrollment.find_by(user_id: user_id, course_id: course_id)
    enrollment.update_attributes(group_index: group_index)
    get_resources
    render 'layouts/renders/main_pane', locals: { resource: 'enrollments/edit_group' }
  end

  def ajax_get_managers
    manager_ids = params[:manager_ids].nil? ? [] : params[:manager_ids]
    case params[:category]
    when 'release' then
      course_user = Enrollment.find_by(course_id: params[:course_id], user_id: params[:manager_id])
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

  def enrollment_params
    params.require(:enrollment).permit(:role)
  end

  def get_resources
    @course = Course.find_enabled_by session[:nav_id]
    @managers = User.sort_by_signin_name @course.managers
    @assistants = User.sort_by_signin_name @course.assistants
    @learners = User.sort_by_signin_name @course.learners
  end

  def render_index
    @managers = User.sort_by_signin_name @course.managers
    @assistants = User.sort_by_signin_name @course.assistants
    @learners = User.sort_by_signin_name @course.learners
    render 'layouts/renders/main_pane', locals: { resource: 'index' }
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
