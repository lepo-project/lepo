class SnippetsController < ApplicationController
  include SnippetsHelper
  protect_from_forgery except: :create_web_snippet
  # ====================================================================
  # Public Functions
  # ====================================================================
  def ajax_create
    @notes = current_user.open_notes
    note_id = params[:note_id].to_i

    @snippet = Snippet.new(snippet_params)
    @snippet.manager_id = session[:id]
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
    snippet = Snippet.find params[:id]
    return unless snippet.deletable? session[:id]
    @notes = current_user.open_notes
    note_id = params[:note_id].to_i if params[:note_id]
    if (snippet.source_type == 'page') && (session[:nav_id] > 0) && (session[:content_id] > 0)
      lesson = Lesson.find_by(course_id: session[:nav_id], content_id: session[:content_id])
      record_user_action('deleted', session[:nav_id], lesson.id, session[:content_id], snippet.source_id, nil, nil, snippet.id, nil, nil) if lesson
    end
    snippet.destroy

    if note_id
      render_snippets note_id
    else
      @snippets = Snippet.web_snippets_without_note_by session[:id]
      render 'layouts/renders/resource', locals: { resource: 'notes/index' }
    end
  end

  def ajax_move
    snippet_ni = NoteIndex.find_by(item_id: params[:id], item_type: 'Snippet', note_id: params[:note_id])
    header_ni = NoteIndex.find_by(id: params[:header_item_id])
    snippet_ni.update_attributes(display_order: header_ni.display_order) if snippet_ni && header_ni
    @notes = current_user.open_notes
    render_snippets params[:note_id]
  end

  def ajax_sort
    @note = Note.find params[:note_id]
    params[:item].each_with_index do |id, i|
      ni = NoteIndex.find_by(id: id)
      ni.update_attributes(display_order: i + 1) if ni
    end
    @notes = current_user.open_notes
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
        @notes = current_user.open_notes
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
        @notes = current_user.open_notes
        @note_items = @note.note_indices
        render 'layouts/renders/resource', locals: { resource: 'notes/show' }
      end
    else
      flash[:message] = t('controllers.snippets.transfer_error')
      flash[:message_category] = 'error'
      @notes = current_user.open_notes
      @snippets = Snippet.web_snippets_without_note_by session[:id]
      render 'layouts/renders/resource', locals: { resource: 'notes/index' }
    end
  end

  def ajax_update
    snippet = Snippet.find params[:id]

    if params[:snippet][:description] == ''
      if snippet.deletable? session[:id]
        snippet.destroy
        @notes = Note.where(manager_id: session[:id]).order(updated_at: :desc)
        render_snippets params[:note_id].to_i
      end
    else
      snippet.update_attributes(snippet_params)

      if %w[header subheader].include? snippet.category
        note = Note.find params[:note_id]
        note_indices = note.note_indices
        note_index = note_indices.find_by(item_id: snippet.id, item_type: 'Snippet')
        @header_title = note_index.header_title(note_indices) if snippet.category == 'header'
        @subheader_title = note_index.subheader_title(note_indices) if snippet.category == 'subheader'
      end
      render_snippet params[:note_id], snippet
    end
  end

  def ajax_update_pdf
    snippet = Snippet.find params[:id]

    snippet.update_attributes(snippet_params)
    @notes = current_user.open_notes
    if params[:note_id]
      # snippet inside the note
      render_snippet params[:note_id], snippet
    else
      # snippet outside the note
      @snippets = Snippet.web_snippets_without_note_by session[:id]
      render 'layouts/renders/resource', locals: { resource: 'notes/index' }
    end
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
      @warning_message = t('controllers.snippets.re_register_button_error')
      render 'snippets/web_snippet/bookmarklet', get_tags('snippets/web_snippet/_warning', 5000)
    elsif lepo_url? url
      @warning_message = t('controllers.snippets.inside_lepo_error')
      render_warning
    elsif description.size > WEB_SNIPPET_MAX_LENGTH
      # This doesn't work for WEBrick, but works for NGINX
      # Upper limit of description is introduced by copyrigt point of view
      @warning_message = t('controllers.snippets.character_numbers_error', current: description.size, limit: WEB_SNIPPET_MAX_LENGTH)
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

  def show_image
    @snippet = Snippet.find(params[:id])
    return nil unless params[:file_id] == @snippet.image_id
    url = @snippet.image_url(:px1280).to_s
    filepath = Rails.root.join('storage', url[1, url.length-1])
    send_file filepath, disposition: "inline"
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
    params.require(:snippet).permit(:category, :description, :source_type, :image)
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
