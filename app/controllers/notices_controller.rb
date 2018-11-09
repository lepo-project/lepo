class NoticesController < ApplicationController
  module AllActions
    # ====================================================================
    # Public Functions
    # ====================================================================
    def ajax_archive_notice
      @notice = Notice.find params[:notice_id]
      @notice.update_attributes(status: 'archived')
      render_notice
    end

    def ajax_archive_notice_from_course_top
      notice = Notice.find params[:notice_id]
      notice.update_attributes(status: 'archived')
      @course = Course.find_enabled_by session[:nav_id]
      @goals = get_goal_resources @course
      @marked_lessons = marked_lessons @course.id
      render 'layouts/renders/resource', locals: { resource: 'index' }
    end

    def ajax_create_notice
      @notice = Notice.new(notice_params)
      @notice.course_id = params[:id].to_i
      @notice.manager_id = session[:id]
      @notice.save
      render_notice
    end

    def ajax_destroy_notice
      @notice = Notice.find params[:notice_id]
      @notice.destroy
      render_notice
    end

    def ajax_edit_notice
      render_notice
    end

    def ajax_notice_pref
      ajax_edit_notice
    end

    def ajax_open_notice
      @notice = Notice.find params[:notice_id]
      @notice.update_attributes(status: 'open')
      render_notice
    end

    def ajax_reedit_notice
      @editting_notice = Notice.find params[:notice_id]
      render_notice
    end

    def ajax_update_notice
      @notice = Notice.find params[:notice_id]
      @notice.update_attributes(notice_params)
      render_notice
    end

    # ====================================================================
    # Private Functions
    # ====================================================================

    private

    def notice_params
      params.require(:notice).permit(:course_id, :manager_id, :status, :message)
    end

    def get_notices
      course_id = session[:nav_id]
      @course_id = course_id > 0 ? course_id : 0
      @open_notices = Notice.where(course_id: @course_id, status: 'open').order(updated_at: :desc)
      @archived_notices = Notice.where(course_id: @course_id, status: 'archived').order(updated_at: :desc).limit(100)
    end

    def render_notice
      get_notices
      render 'layouts/renders/main_pane', locals: { resource: 'notices/edit' }
    end
  end
end
