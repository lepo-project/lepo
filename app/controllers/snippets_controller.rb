class SnippetsController < ApplicationController
  include SnippetsHelper
  protect_from_forgery except: :create_web_snippet
  # ====================================================================
  # Public Functions
  # ====================================================================
  def ajax_create
    @notes = current_user.notes
    note_id = params[:note_id].to_i

    @snippet = Snippet.new(manager_id: session[:id], category: params[:category], description: params[:snippet][:description], source_type: 'direct')
    Snippet.transaction do
      @snippet.save!
      NoteIndex.create!(note_id: note_id, item_id: @snippet.id, item_type: 'Snippet', display_order: params[:display_order].to_i)
    end
    render_snippets note_id
  rescue StandardError
    flash[:message] = t('controllers.snippets.creation_error')
    flash[:message_category] = 'error'
    render_snippets note_id
  end

  def ajax_destroy
    snippet = Snippet.find(params[:id])
    return unless snippet.deletable? session[:id]
    @notes = current_user.notes
    note_id = params[:note_id].to_i if params[:note_id]
    snippet.destroy

    if note_id
      render_snippets note_id
    else
      @snippets = Snippet.web_snippets_without_note_by session[:id]
      render 'layouts/renders/resource', locals: { resource: 'notes/index' }
    end
  end

  def ajax_sort
    @note = Note.find params[:note_id].to_i
    params[:item].each_with_index do |id, i|
      ni = NoteIndex.find_by(id: id)
      ni.update_attributes(display_order: i + 1) if ni
    end
    @note_items = @note.note_indices
    render 'snippets/renders/snippets'
  end

  def ajax_transfer
    snippet = Snippet.find params[:id] if params[:id]
    from_note_id = params[:from_note_id].to_i if params[:from_note_id]
    to_note_id = params[:to_note_id].to_i if params[:to_note_id]

    if snippet.transferable? session[:id], to_note_id
      if to_note_id
        display_order = NoteIndex.where(note_id: to_note_id).count + 1
        @notes = current_user.notes
        if from_note_id
          ni = NoteIndex.find_by(note_id: from_note_id, item_id: snippet.id, item_type: 'Snippet')
          ni.update_attributes(note_id: to_note_id, display_order: display_order)
          @note = Note.find from_note_id
          @note.align_display_order
          @note_items = @note.note_indices
          render 'layouts/renders/resource', locals: { resource: 'notes/show' }
        else
          NoteIndex.create(note_id: to_note_id, item_id: snippet.id, item_type: 'Snippet', display_order: display_order)
          @snippets = Snippet.web_snippets_without_note_by session[:id]
          render 'layouts/renders/resource', locals: { resource: 'notes/index' }
        end
      else
        ni = NoteIndex.find_by(note_id: from_note_id, item_id: snippet.id, item_type: 'Snippet')
        ni.destroy
        @note = Note.find from_note_id
        @note.align_display_order
        @notes = current_user.notes
        @note_items = @note.note_indices
        render 'layouts/renders/resource', locals: { resource: 'notes/show' }
      end
    else
      flash[:message] = t('controllers.snippets.transfer_error')
      flash[:message_category] = 'error'
      @notes = current_user.notes
      @snippets = Snippet.web_snippets_without_note_by session[:id]
      render 'layouts/renders/resource', locals: { resource: 'notes/index' }
    end
  end

  def ajax_update
    snippet = Snippet.find(params[:id])

    if params[:snippet][:description] == ''
      if snippet.deletable? session[:id]
        snippet.destroy
        @notes = Note.where(manager_id: session[:id]).order(updated_at: :desc)
        render_snippets params[:note_id].to_i
      end
    else
      # max character length for user text form is USER_TEXT_LENGTH
      params[:snippet][:description] = params[:snippet][:description][0, USER_TEXT_LENGTH]
      snippet.update_attributes(snippet_params)
      render_snippet params[:note_id], snippet
    end
  end

  def ajax_update_pdf
    snippet = Snippet.find(params[:id])

    snippet.update_attributes(snippet_params)
    if params[:note_id]
      # snippet inside the note
      render_snippet params[:note_id], snippet
    else
      # snippet outside the note
      @notes = current_user.notes
      @snippets = Snippet.web_snippets_without_note_by session[:id]
      render 'layouts/renders/resource', locals: { resource: 'notes/index' }
    end
  end

  def ajax_update_file
    snippet = Snippet.find(params[:id])
    snippet_file = snippet.snippet_file
    snippet_file.update_attributes(snippet_file_params)
    snippet.update_attributes(category: snippet_file.file_type, description: snippet_file.upload.url)
    render_snippet params[:note_id], snippet
  end

  def ajax_upload
    @notes = current_user.notes
    note_id = params[:note_id].to_i

    @snippet = Snippet.new(manager_id: session[:id], category: 'image', source_type: 'upload')
    Snippet.transaction do
      @snippet.save!
      NoteIndex.create!(note_id: note_id, item_id: @snippet.id, item_type: 'Snippet', display_order: params[:display_order].to_i)
      param_hash = snippet_file_params
      param_hash['snippet_id'] = @snippet.id
      snippet_file = SnippetFile.new(param_hash)
      snippet_file.save!
      @snippet.update_attributes!(category: snippet_file.file_type, source_id: snippet_file.id, description: snippet_file.upload.url)
    end
    render_snippets note_id
  rescue StandardError
    flash[:message] = t('controllers.snippets.upload_error')
    flash[:message_category] = 'error'
    render_snippets note_id
  end

  def create_web_snippet
    url = params[:u]
    title = params[:t]
    description = params[:d]
    category = params[:c] == 'i' ? 'image' : 'text'
    token = params[:tk]
    # version = params[:v]

    user = User.find_by(token: token) if token
    if !token || !user
      @warning_message = '「+Note」ボタンを更新してください'
      render 'snippets/web_snippet/bookmarklet', get_tags('snippets/web_snippet/_warning', 5000)
    elsif lepo_url? url
      @warning_message = 'LePo内の情報は、+Noteできません'
      render_warning
    elsif description.size > 255
      # This doesn't work for WEBrick, but works for NGINX
      # Upper limit of description is introduced by varchar(255) of MySQL and copyrigt point of view
      @warning_message = '選択した文字が多すぎるため、+Noteできません'
      render_warning
    elsif WebPage.pdf_url? url
      # Firefox: text snippet from PDF works for url, title and description
      # Chrome & Safari: text snippet from PDF works for url, but not for title and description
      # IE11: text snippet from PDF doesn't work (no access to lepo server)
      save_web_snippet url, '[PDF]', description, 'pdf', user
    elsif !description.empty?
      save_web_snippet url, title, description, category, user
    elsif embed_url? url
      save_web_embed_snippet url, title, user
    else
      render 'snippets/web_snippet/image_bookmarklet', get_tags('snippets/web_snippet/_image_selector', 0, token)
    end
  end

  # ====================================================================
  # Private Functions
  # ====================================================================

  private

  def get_tags(source, duration, token = '')
    # This code is inspired by the gem "rails-bookmarklet", https://github.com/oliverfriedmann/rails-bookmarklet.git
    raw_html = render_to_string source
    document = Nokogiri::HTML(raw_html)
    tags = []

    document.root.children.each do |child|
      next unless child.element?
      inner_html = ''
      child.children.each { |child_child| inner_html << child_child.to_s }
      tags.push(name: child.name, attributes: child.attributes, innerHTML: inner_html)
    end
    { formats: ['js'], layout: false, locals: { duration: duration, tags: tags, token: token } }
  end

  def snippet_params
    params.require(:snippet).permit(:category, :description)
  end

  def snippet_file_params
    params.require(:snippet_file).permit(:upload)
  end

  def embed_url?(url)
    (WebPage.scratch_url? url) || (WebPage.ted_url? url) || (WebPage.youtube_url? url)
  end

  def lepo_url?(url)
    protocol = SYSTEM_SSL_FLAG ? 'https://' : 'http://'
    url.include?(protocol + request.host_with_port)
  end

  def prep_for_nm_image(description)
    index = description.index('img.naver.jp/mig?src=')
    description = description[(index + 21)..(description.size - 1)] unless index.nil?
    description
  end

  def render_creation
    render 'snippets/web_snippet/bookmarklet', get_tags('snippets/web_snippet/_create', 2000)
  end

  def render_snippet(note_id, snippet)
    @note = Note.find note_id
    # @snippets = @note.snippets
    @note_items = @note.note_indices
    render 'snippets/renders/snippet', locals: { snippet: snippet }
  end

  def render_snippets(note_id)
    @note = Note.find note_id
    @note.align_display_order
    @note_items = @note.note_indices
    render 'snippets/renders/snippets'
  end

  def render_warning
    render 'snippets/web_snippet/bookmarklet', get_tags('snippets/web_snippet/_warning', 2000)
  end

  def save_snippet(description, category, user, source_id)
    note_id = user.default_note_id
    if note_id > 0 && Note.find_by(id: note_id) && Note.find(note_id).manager_id == user.id
      display_order = Note.find(note_id).snippets.size + 1
      Snippet.transaction do
        snippet = Snippet.create!(manager_id: user.id, category: category, description: description, source_type: 'web', source_id: source_id)
        NoteIndex.create!(item_id: snippet.id, item_type: 'Snippet', note_id: note_id, display_order: display_order)
      end
      return true
    else
      snippet = Snippet.new(manager_id: user.id, category: category, description: description, source_type: 'web', source_id: source_id)
      return snippet.save
    end
  rescue StandardError
    return false
  end

  def save_web_snippet(url, title, description, category, user)
    source_id = save_web_page url, title
    render_warning unless source_id > 0
    case category
    when 'text'
      save_snippet(description, category, user, source_id) ? render_creation : render_warning
    when 'pdf'
      # @warning_message = save_snippet(description, category, user, source_id) ? 'PDF：URLのみ保存しました（選択文字は未保存）' : nil
      @warning_message = save_snippet(description, category, user, source_id) ? t('controllers.snippets.pdf_creation') : nil
      render_warning
    when 'image'
      # TODO: Naver Matome Preparation
      description = prep_for_nm_image description
      save_snippet(description, category, user, source_id) ? render_creation : render_warning
    else
      render_warning
    end
  end

  def save_web_embed_snippet(url, title, user)
    source_id = save_web_page url, title
    render_warning unless source_id > 0
    # snippet creation
    if WebPage.scratch_url? url
      category = 'scratch'
    elsif WebPage.ted_url? url
      category = 'ted'
    elsif WebPage.youtube_url? url
      category = 'youtube'
    else
      category = 'text'
    end
    save_snippet('', category, user, source_id) ? render_creation : render_warning
  end

  def save_web_page(url, title)
    # web_page creation
    source = WebPage.find_or_initialize_by(url: url)
    unless source.update(title: title)
      render_warning
      return 0
    end
    source.id
  end
end
