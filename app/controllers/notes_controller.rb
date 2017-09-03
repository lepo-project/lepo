class NotesController < ApplicationController
  include ::StickiesController::AllActions
  # ====================================================================
  # Public Functions
  # ====================================================================
  def ajax_index
    set_nav_session params[:nav_section], 'notes', params[:nav_id]
    get_resources

    render 'layouts/renders/all', locals: { resource: 'index' }
  end

  # FIXME: Group work
  def ajax_group_index
    @group_id = params[:group_id].to_i
    get_resources
    render 'layouts/renders/main_pane', locals: { resource: 'group_index' }
  end

  def ajax_import_snippet
    original_snippet = Snippet.find params[:snippet_id] if params[:snippet_id]
    original_note = original_snippet.note if original_snippet
    master_id = original_note.master_id if original_note.master_id
    if master_id
      user_id = session[:id]
      notes = Note.where(manager_id: user_id, status: 'course', master_id: master_id).to_a
      note = notes[0]
      if note
        Snippet.create(manager_id: user_id, note_id: note.id, category: original_snippet.category, description: original_snippet.description, source_type: original_snippet.source_type, source_id: original_snippet.source_id, display_order: note.snippets.size + 1, master_id: original_snippet.id)
        note.align_display_order
      end
    end

    get_resources
    @note = Note.find original_note.id
    @snippets = @note.snippets
    get_stickies @note.course_id, @note.id
    render 'layouts/renders/resource', locals: { resource: 'show' }
  end

  # same action for snippets_controller without @sticky
  def ajax_show
    note_id = params[:id].to_i
    course_id = session[:nav_id].to_i

    @note = Note.find note_id
    get_resources
    get_stickies course_id, note_id
    @snippets = @note.snippets
    @group_id = @course.group_id_for @note.manager_id

    set_sticky_panel_session
    render 'layouts/renders/main_pane', locals: { resource: 'show' }
  end

  def ajax_show_from_others
    set_nav_session 'open_courses', 'notes', params[:nav_id]
    note_id = params[:id].to_i
    @note = Note.find note_id
    get_resources
    get_stickies @note.course_id, @note.id
    @snippets = @note.snippets
    @group_id = @course.group_id_for @note.manager_id

    set_sticky_panel_session
    render 'layouts/renders/all', locals: { resource: 'show' }
  end

  def ajax_toggle_star
    @note = Note.find_by(id: params[:id])
    if @note
      user_id = session[:id]
      note_star = NoteStar.find_by_manager_id_and_note_id(user_id, @note.id)
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
    @group_id = @course.group_id_for @note.manager_id if params[:resource] == 'group_index'
    @snippets = @note.snippets
    @note = Note.new if params[:resource] != 'show'

    case params[:resource]
    when 'index', 'group_index', 'show'
      #   render 'layouts/renders/main_pane', locals: {resource: params[:resource]}
      # when
      render 'layouts/renders/resource', locals: { resource: params[:resource] }
    when 'course_index'
      course = Course.find(session[:nav_id]) if session[:nav_id]
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

  def get_resources
    @course = Course.find(session[:nav_id])

    private_notes = Note.where(course_id: session[:nav_id], status: 'private', manager_id: session[:id]).order(updated_at: :desc).to_a
    @notes = private_notes + @course.staff_course_notes.to_a + @course.learner_course_notes(session[:id], @course.staff?(session[:id]))
  end

  def get_stickies(course_id, note_id)
    @stickies = get_course_stickies_by_target course_id, 'note', note_id
    @sticky = Sticky.new(course_id: course_id, target_type: 'note', target_id: note_id)
  end
end
