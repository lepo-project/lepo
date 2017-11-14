class ContentsController < ApplicationController
  include ::StickiesController::AllActions
  # ====================================================================
  # Public Functions
  # ====================================================================
  def ajax_index
    set_nav_session params[:nav_section], 'contents'
    get_content_resources
    render 'layouts/renders/all', locals: { resource: 'index' }
  end

  def ajax_show
    set_star_sort_stickies_session
    @content = Content.find(params[:id].to_i)
    set_page_session 0, @content

    pg = get_page 0, @content
    @sticky = Sticky.new(content_id: @content.id, target_id: pg['file_id'])
    get_content_resources
    set_sticky_panel_session
    render 'layouts/renders/all_with_pg', locals: { resource: 'layouts/cover_page', pg: pg }
  end

  def ajax_show_page
    @content = Content.find(session[:content_id])
    set_page_session params[:page_num].to_i, @content
    set_sticky_panel_session

    pg = get_page 0, @content
    @sticky = Sticky.new(content_id: @content.id, target_id: pg['file_id'])
    @lesson = Lesson.new
    get_outcome_resources @lesson, @content

    render_content_page pg
  end

  def ajax_new
    set_nav_session 'repository', 'contents', 0

    @content = Content.new(category: params[:category])
    @content.fill_objectives
    @content.objectives[0].title = '(目標未定)'
    get_content_resources
    render 'layouts/renders/all_with_sub_toolbar', locals: { resource: 'new' }
  end

  def ajax_create
    @content = Content.new(content_params)
    if @content.status == 'destroy'
      get_content_resources
      render 'layouts/renders/all', locals: { resource: 'index' }
    elsif @content.save
      content_member = ContentMember.new(content_id: @content.id, user_id: session[:id], role: 'manager')
      if content_member.save
        get_content_resources
        render 'layouts/renders/main_pane', locals: { resource: 'edit_pages' }
      else
        flash[:message] = '教材と学生の関連づけに失敗しました'
        flash[:message_category] = 'error'
        replace_page_with_fill_objectives 'new'
      end
    else
      flash[:message] = '教材の作成に失敗しました'
      flash[:message_category] = 'error'
      replace_page_with_fill_objectives 'new'
    end
  end

  def ajax_edit
    @content = Content.find(params[:id])
    @content.fill_objectives
    get_content_resources
    render 'layouts/renders/main_pane', locals: { resource: 'edit' }
  end

  def ajax_update
    @content = Content.find params[:id]
    content_form = content_params

    if all_blank_title? content_form[:objectives_attributes]
      flash[:message] = '到達目標を、1つ以上設定する必要があります'
      flash[:message_category] = 'error'
      replace_page_with_fill_objectives 'edit'
      return
    else
      destroy_blank_objectives(content_form[:objectives_attributes])

      if @content.update_attributes content_form
        get_content_resources
        case @content.status
        when 'open'
          render 'layouts/renders/main_pane', locals: { resource: 'edit_pages' }
        when 'archived'
          pg = get_page(0, @content)
          @sticky = Sticky.new(content_id: @content.id, target_id: pg['file_id'])
          render 'layouts/renders/main_pane_with_pg', locals: { resource: 'layouts/cover_page', pg: pg }
        end
      else
        replace_page_with_fill_objectives 'edit'
      end
    end
  end

  def ajax_destroy
    @content = Content.find params[:id]
    @content.destroy if @content.deletable? session[:id]
    get_content_resources
    render 'layouts/renders/all', locals: { resource: 'index' }
  end

  def ajax_destroy_asset_file
    destroy_file(AssetFile.find(params[:file_id]), 'asset')
  end

  def ajax_destroy_attachment_file
    destroy_file(AttachmentFile.find(params[:file_id]), 'attachment')
  end

  def ajax_upload_asset_file
    upload_file(params[:asset_file], AssetFile.new(asset_file_params))
  end

  def ajax_upload_attachment_file
    @content = Content.find(params[:id])
    file = params[:attachment_file]
    new_file = AttachmentFile.new(attachment_file_params)
    filename = new_file.upload_file_name

    attachment = AttachmentFile.find_by_content_id_and_upload_file_name(@content.id, filename)
    if attachment
      if attachment.update_attributes(upload: file[:upload])
        flash.now[:message] = '添付ファイル「' + filename + '」を更新しました'
        flash[:message_category] = 'info'
      else
        flash.now[:message] = '添付ファイル「' + filename + '」の更新に失敗しました'
        flash[:message_category] = 'error'
      end
    else
      flash.now[:message] = '「' + filename + '」のアップロードに失敗しました' unless new_file.save
      flash[:message_category] = 'error'
    end
    render 'layouts/renders/resource', locals: { resource: 'edit_pages' }
  end

  def ajax_destroy_page_file
    destroy_file(PageFile.find(params[:file_id]), 'page')
  end

  def ajax_upload_page_file
    create_file = PageFile.new(page_file_params)
    upload_file_check_and_save(params[:page_file], create_file)
    content_type = create_file.id.nil? ? nil : create_file.upload_content_type
    split_pages_of_pdf(create_file) if content_type == 'application/pdf'
    render 'layouts/renders/resource', locals: { resource: 'edit_pages' }
  end

  def ajax_sort_page_files
    params[:page].each_with_index { |id, i| PageFile.update(id, display_order: i + 1) }
    @content = Content.find(params[:id])
    render 'layouts/renders/resource', locals: { resource: 'edit_pages' }
  end

  # ====================================================================
  # Private Functions
  # ====================================================================

  private

  def get_content_resources
    case session[:nav_section]
    when 'home'
      @contents = Content.by_system_managers
    when 'repository'
      @contents = Content.associated_by session[:id], 'manager'
      @contents += Content.associated_by session[:id], 'assistant'
      @contents += Content.associated_by session[:id], 'user'
    end
    @contents.sort! { |a, b| (a.status_display_order <=> b.status_display_order).nonzero? || (b.updated_at <=> a.updated_at) }
  end

  def content_params
    params.require(:content).permit(:category, :title, :condition, :overview, :status, :as_category, :as_overview, objectives_attributes: %i[title allocation criterion id])
  end

  def asset_file_params
    params.require(:asset_file).permit(:content_id, :upload)
  end

  def attachment_file_params
    params.require(:attachment_file).permit(:content_id, :upload)
  end

  def page_file_params
    params.require(:page_file).permit(:content_id, :display_order, :upload)
  end

  def destroy_file(file, category)
    file.destroy
    @content = Content.find(params[:id])

    # page display order update
    if category == 'page'
      files = @content.page_files
      files.each_with_index do |fl, i|
        fl.update_attributes(display_order: i + 1)
      end
      @content.reload
    end

    render 'layouts/renders/resource', locals: { resource: 'edit_pages' }
  end

  def upload_file(file, new_file)
    upload_file_check_and_save(file, new_file)
    render 'layouts/renders/resource', locals: { resource: 'edit_pages' }
  end

  def upload_file_check_and_save(file, new_file)
    @content = Content.find(params[:id])
    filename = new_file.upload_file_name
    page = PageFile.find_by_content_id_and_upload_file_name(@content.id, filename)
    asset = AssetFile.find_by_content_id_and_upload_file_name(@content.id, filename)
    if page
      if page.update_attributes(upload: file[:upload])
        flash.now[:message] = t('activerecord.models.page_file') + '「' + filename + '」を更新しました'
        flash[:message_category] = 'info'
      else
        flash.now[:message] = t('activerecord.models.page_file') + '「' + filename + '」の更新に失敗しました'
        flash[:message_category] = 'error'
      end
    elsif asset
      if asset.update_attributes(upload: file[:upload])
        flash.now[:message] = t('activerecord.models.asset_file') + '「' + filename + '」を更新しました'
        flash[:message_category] = 'info'
      else
        flash.now[:message] = t('activerecord.models.asset_file') + '「' + filename + '」の更新に失敗しました'
        flash[:message_category] = 'error'
      end
    else
      flash.now[:message] = '「' + filename + '」のアップロードに失敗しました' unless new_file.save
      flash[:message_category] = 'info'
    end
  end

  def replace_page_with_fill_objectives(resource_name)
    @content.fill_objectives
    get_content_resources
    render 'layouts/renders/resource', locals: { resource: resource_name }
  end

  def destroy_blank_objectives(objectives)
    objectives.each do |_key, objective|
      objective['_destroy'] = 'true' if objective[:title].blank?
    end
  end

  def split_pages_of_pdf(create_file)
    filepath = create_file.upload.path
    dirname = File.dirname(filepath)
    extname = File.extname(filepath)
    filename = File.basename(filepath, extname)
    i = 1
    pages = CombinePDF.load(filepath).pages
    return unless pages.size > 1
    org_file = create_file.dup
    display_order = org_file[:display_order]
    pages.each do |page|
      pdf = CombinePDF.new
      pdf << page
      new_file_name = filename + '_p' + i.to_s + extname
      new_file_path = File.join(dirname, new_file_name)
      pdf.save new_file_path
      page = PageFile.find_by_content_id_and_upload_file_name(org_file.content_id, new_file_name)
      if page
        page[:upload_file_size] = File.size(new_file_path)
        page.save
        flash.now[:message] = t('activerecord.models.asset_file') + '「' + filename + '」を更新しました'
        flash[:message_category] = 'info'
      else
        new_file = i == 1 ? org_file : org_file.dup
        new_file[:upload_file_name] = new_file_name
        new_file[:display_order] = display_order
        new_file[:upload_file_size] = File.size(new_file_path)
        new_file.save
        display_order += 1
      end
      i += 1
    end
    create_file.destroy
  end
end
