class PortfoliosController < ApplicationController
  include ::StickiesController::AllActions
  # ====================================================================
  # Public Functions
  # ====================================================================
  def ajax_index
    set_nav_session params[:nav_section], 'portfolios', params[:nav_id]
    get_resources
    render 'layouts/renders/all', locals: { resource: 'index' }
  end

  def ajax_show(transition = false)
    set_related_course_stickies_session false
    @lesson = Lesson.find params[:id].to_i
    stickies = stickies_by_content @lesson.content_id
    @private_stickies = stickies.select { |s| s.category == 'private' }
    @course_stickies = stickies.select { |s| s.category == 'course' }
    get_resources
    if transition
      render 'layouts/renders/all', locals: { resource: 'show' }
    else
      # page information clearance
      set_page_session 0
      render 'layouts/renders/main_pane', locals: { resource: 'show' }
    end
  end

  def ajax_show_with_transition
    # ajax show with in-course transition
    session[:nav_controller] = 'portfolios'
    ajax_show true
  end

  # ====================================================================
  # Private Functions
  # ====================================================================

  private

  def get_resources
    @course = Course.find(session[:nav_id])
    @course_role = @course.user_role session[:id]
    @lessons = @course.lessons
    @last_sticky_dates = last_sticky_dates @lessons

    @learners = User.sort_by_user_id @course.learners
    @myself = User.find(session[:id])
  end
end
