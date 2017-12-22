class BookmarksController < ApplicationController
  # ====================================================================
  # Public Functions
  # ====================================================================
  def ajax_create
    @display_title = params[:display_title]
    @url = params[:url]

    # web page setting
    web_page = WebPage.find_by(url: params[:url])
    unless web_page
      if params[:display_title].size.zero?
        render_creation_fail
        return
      end
      web_page = WebPage.new(url: params[:url])
      unless web_page.save
        render_creation_fail
        return
      end
    end

    # bookmark creation / update
    bookmark = Bookmark.find_by(manager_id: session[:id], target_id: web_page.id, target_type: 'web')
    if bookmark
      if bookmark.update_attributes(display_title: params[:display_title])
        flash.now[:message] = t('controllers.bookmarks.updated')
      else
        render_creation_fail unless web_page.save
        return
      end
    else
      bookmark = Bookmark.new(manager_id: session[:id], display_title: params[:display_title], display_order: params[:display_order], target_id: web_page.id, target_type: 'web')
      if bookmark.save
        flash.now[:message] = t('controllers.bookmarks.created')
      else
        render_creation_fail unless web_page.save
        return
      end
    end

    flash.now[:message_category] = 'info'
    @display_title = ''
    @url = ''
    render_bookmark
  end

  def ajax_destroy
    bookmark = Bookmark.find params[:id]
    bookmark.destroy if bookmark.deletable? current_user

    bookmarks = current_user.system_staff? ? Bookmark.by_system_staffs : Bookmark.by_user(session[:id])
    bookmarks.each_with_index do |li, i|
      li.update_attributes(display_order: i + 1)
    end
    render_bookmark
  end

  def ajax_new
    if (session[:nav_section] != 'home') || (session[:nav_controller] != 'preferences')
      # through sub-pane toolbar operation
      set_nav_session 'home', 'preferences', 0
      render_bookmark
    else
      render_bookmark false
    end
  end

  def ajax_sort
    params[:bookmark].each_with_index { |id, i| Bookmark.update(id, display_order: i + 1) }
    render_bookmark
  end

  # ====================================================================
  # Private Functions
  # ====================================================================

  private

  def render_bookmark(render_all = true)
    @display_title ||= ''
    @url ||= ''
    @system_bookmarks = Bookmark.by_system_staffs
    @editable_bookmarks = current_user.system_staff? ? @system_bookmarks : Bookmark.by_user(session[:id])
    if render_all
      render 'layouts/renders/all_with_sub_toolbar', locals: { resource: 'new' }
    else
      render 'layouts/renders/main_pane', locals: { resource: 'new' }
    end
  end

  def render_creation_fail
    flash.now[:message] = t('controllers.bookmarks.creation_failed')
    flash.now[:message_category] = 'error'
    render_bookmark
  end
end
