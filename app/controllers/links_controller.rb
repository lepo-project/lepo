class LinksController < ApplicationController
  # ====================================================================
  # Public Functions
  # ====================================================================
  def ajax_create
    @user = User.find session[:id]
    @link = Link.new(link_params)
    @link.manager_id = @user.id
    existing_link = Link.find_by_manager_id_and_title(@user.id, @link.title)
    if existing_link
      if existing_link.update_attributes(url: @link.url)
        flash.now[:message] = 'リンクを更新しました'
        flash.now[:message_category] = 'info'
        @link = Link.new
      else
        flash.now[:message] = 'リンクの更新に失敗しました'
        flash.now[:message_category] = 'error'
      end
    elsif @link.save
      flash.now[:message] = 'リンクを追加しました'
      flash.now[:message_category] = 'info'
      @link = Link.new
    else
      flash.now[:message] = 'リンクの追加に失敗しました'
      flash.now[:message_category] = 'error'
    end

    render_link
  end

  def ajax_destroy
    @user = User.find session[:id]
    link = Link.find(params[:link_id])
    link.destroy if link.deletable? @user

    links = @user.system_staff? ? Link.by_system_staffs : Link.by_user(@user.id)
    links.each_with_index do |li, i|
      li.update_attributes(display_order: i + 1)
    end
    render_link
  end

  def ajax_new
    @user = User.find session[:id]
    if (session[:nav_section] != 'home') || (session[:nav_controller] != 'preferences')
      # through sub-pane toolbar operation
      set_nav_session 'home', 'preferences', 0
      render_link
    else
      render_link false
    end
  end

  def ajax_sort
    params[:link].each_with_index { |id, i| Link.update(id, display_order: i + 1) }
    @user = User.find session[:id]
    render_link
  end

  # ====================================================================
  # Private Functions
  # ====================================================================

  private

  def link_params
    params.require(:link).permit(:manager_id, :display_order, :url, :title)
  end

  def render_link(render_all = true)
    @link = Link.new unless @link
    @system_links = Link.by_system_staffs
    @editable_links = @user.system_staff? ? @system_links : Link.by_user(@user.id)
    if render_all
      render 'layouts/renders/all_with_sub_toolbar', locals: { resource: 'new' }
    else
      render 'layouts/renders/main_pane', locals: { resource: 'new' }
    end
  end
end
