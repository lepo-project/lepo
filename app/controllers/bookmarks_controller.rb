class BookmarksController < ApplicationController
  # ====================================================================
  # Public Functions
  # ====================================================================
  def ajax_create
    @bookmark = Bookmark.new(bookmark_params)
    @bookmark.manager_id = session[:id]
    existing_bookmark = Bookmark.find_by_manager_id_and_title(session[:id], @bookmark.title)
    if existing_bookmark
      if existing_bookmark.update_attributes(url: @bookmark.url)
        flash.now[:message] = 'ブックマークを更新しました'
        flash.now[:message_category] = 'info'
        @bookmark = Bookmark.new
      else
        flash.now[:message] = 'ブックマークの更新に失敗しました'
        flash.now[:message_category] = 'error'
      end
    elsif @bookmark.save
      flash.now[:message] = 'ブックマークを追加しました'
      flash.now[:message_category] = 'info'
      @bookmark = Bookmark.new
    else
      flash.now[:message] = 'ブックマークの追加に失敗しました'
      flash.now[:message_category] = 'error'
    end

    render_bookmark
  end

  def ajax_destroy
    bookmark = Bookmark.find(params[:bookmark_id])
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

  def bookmark_params
    params.require(:bookmark).permit(:manager_id, :display_order, :url, :title)
  end

  def render_bookmark(render_all = true)
    @bookmark = Bookmark.new unless @bookmark
    @system_bookmarks = Bookmark.by_system_staffs
    @editable_bookmarks = current_user.system_staff? ? @system_bookmarks : Bookmark.by_user(session[:id])
    if render_all
      render 'layouts/renders/all_with_sub_toolbar', locals: { resource: 'new' }
    else
      render 'layouts/renders/main_pane', locals: { resource: 'new' }
    end
  end
end
