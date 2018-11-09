class NotesController < ApplicationController
  include ::StickiesController::AllActions
  # ====================================================================
  # Public Functions
  # ====================================================================
  def ajax_index
    case params[:nav_section]
    when 'home'
      set_nav_session 'home', 'notes'
      @notes = current_user.open_notes
      @snippets = Snippet.web_snippets_without_note_by session[:id]
    when 'open_courses'
      set_nav_session 'open_courses', 'notes', params[:nav_id]
      get_resources
    when 'repository'
      set_nav_session 'repository', 'notes', params[:nav_id]
      get_resources
    end
    render 'layouts/renders/all', locals: { resource: 'index' }
  end

  # FIXME: Group work
  def ajax_index_group
    @group_index = params[:group_index].to_i
    get_resources
    render 'layouts/renders/main_pane', locals: { resource: 'index_group' }
  end

  def ajax_show
    note_id = params[:id].to_i
    @note = Note.find note_id
    case session[:nav_section]
    when 'home'
      @notes = current_user.open_notes
      @note_items = @note.note_indices
    when 'open_courses', 'repository'
      course_id = session[:nav_id]
      get_resources
      get_stickies course_id, note_id
      @note_items = @note.note_indices
      @group_index = @course.group_index_for @note.manager_id
      set_sticky_panel_session
    end
    render 'layouts/renders/main_pane', locals: { resource: 'show' }
  end

  def ajax_show_from_others
    set_nav_session 'open_courses', 'notes', params[:nav_id]
    note_id = params[:id].to_i
    @note = Note.find note_id
    get_resources
    get_stickies @note.course_id, @note.id
    @note_items = @note.note_indices
    @group_index = @course.group_index_for @note.manager_id

    set_sticky_panel_session
    render 'layouts/renders/all', locals: { resource: 'show' }
  end

  def ajax_create
    params[:note][:overview] = params[:note][:overview][0, NOTE_OVERVIEW_MAX_LENGTH]
    @note = Note.new(note_params)
    @note.manager_id = session[:id]
    if @note.save
      @note_items = []
      render 'layouts/renders/main_pane', locals: { resource: 'show' }
    else
      flash[:message] = t('controllers.notes.creation_error')
      flash[:message_category] = 'error'
      render 'layouts/renders/resource', locals: { resource: 'new' }
    end
  end

  def ajax_destroy
    @note = Note.find params[:id]
    if @note.deletable? session[:id]
      @note.destroy
      current_user.update_attributes(default_note_id: 0) if current_user.default_note_id == params[:id].to_i
      @notes = current_user.open_notes
      @snippets = Snippet.web_snippets_without_note_by session[:id]
      render 'layouts/renders/all', locals: { resource: 'index' }
    else
      @notes = current_user.open_notes
      @snippets = @note.snippets
      flash[:message] = '切り抜き または コースふせんのあるノートは削除できません'
      render 'layouts/renders/main_pane', locals: { resource: 'edit' }
    end
  end

  def ajax_edit
    @notes = current_user.open_notes
    @note = Note.find params[:id]
    @note_items = @note.note_indices
    render 'layouts/renders/main_pane', locals: { resource: 'edit' }
  end

  def ajax_new
    case params[:category]
    when 'private', 'work'
      @note = Note.new(category: params[:category])
      render 'layouts/renders/main_pane', locals: { resource: 'new' }
    end
  end

  def ajax_update
    params[:note][:overview] = params[:note][:overview][0, NOTE_OVERVIEW_MAX_LENGTH]
    @note = Note.find params[:id]

    if @note.status_updatable?(params[:note][:status], session[:id]) && @note.update_attributes(note_params)
      distribute_work_sheet @note if @note.status == 'distributed_draft'
      @note_items = @note.note_indices
      @notes = current_user.open_notes
      render 'layouts/renders/main_pane', locals: { resource: 'show' }
    else
      flash[:message] = t('controllers.notes.creation_error')
      flash[:message_category] = 'error'
      render 'layouts/renders/resource', locals: { resource: 'edit' }
    end
  end

  def ajax_toggle_star
    @note = Note.find_by(id: params[:id])
    if @note
      user_id = session[:id]
      note_star = NoteStar.find_by(manager_id: user_id, note_id: @note.id)
      star_increment = 1

      Note.transaction do
        if note_star
          star_increment = -1 if note_star.stared
          note_star.update_attributes!(stared: !note_star.stared)
        else
          NoteStar.create!(manager_id: user_id, note_id: @note.id)
        end
        stars_count = @note.stars_count + star_increment
        # update stars_count without update updated_at
        @note.update_column(:stars_count, stars_count)
      end
    end

    get_resources
    get_stickies @course.id, @note.id if params[:resource] == 'show'
    @group_index = @course.group_index_for @note.manager_id if params[:resource] == 'index_group'
    @note_items = @note.note_indices
    @note = Note.new if params[:resource] != 'show'

    case params[:resource]
    when 'index', 'index_group', 'show'
      #   render 'layouts/renders/main_pane', locals: {resource: params[:resource]}
      # when
      render 'layouts/renders/resource', locals: { resource: params[:resource] }
    when 'course_index'
      course = Course.find_enabled_by(session[:nav_id]) if session[:nav_id]
      if course
        render 'notes/renders/hot_notes', locals: { notes: course.hot_notes, course_id: course.id }
      end
    end
  end

  def export_html
    @note = Note.find params[:id]
    render layout: false
  end

  # ====================================================================
  # Private Functions
  # ====================================================================

  private

  def distribute_work_sheet(original_ws)
    copy_snippets = original_ws.direct_snippets
    course = Course.find_enabled_by original_ws.course_id
    course.learners.each do |l|
      notes = Note.where(manager_id: l.id, status: 'original_ws', original_ws_id: original_ws.id).to_a
      next unless notes.size.zero?

      Snippet.transaction do
        note = Note.create!(manager_id: l.id, course_id: course.id, title: original_ws.title, overview: original_ws.overview, category: 'work', status: 'original_ws', original_ws_id: original_ws.id)
        copy_snippets.each_with_index do |cs, i|
          snippet = Snippet.create!(manager_id: l.id, category: cs.category, description: cs.description, source_type: 'direct')
          NoteIndex.create!(note_id: note.id, item_id: snippet.id, item_type: 'Snippet', display_order: i + 1)
        end
      end
    end
  end

  def get_resources
    @course = Course.find_enabled_by session[:nav_id]

    @notes = @course.learner_work_sheets(session[:id], @course.staff?(session[:id]))
  end

  def get_stickies(course_id, note_id)
    @stickies = get_course_stickies_by_target course_id, 'Note', note_id
    @sticky = Sticky.new(course_id: course_id, target_type: 'Note', target_id: note_id)
  end

  def note_params
    params.require(:note).permit(:course_id, :overview, :category, :status, :title, :peer_reviews_count)
  end
end
