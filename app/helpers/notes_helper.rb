module NotesHelper
  # ====================================================================
  # Public Functions
  # ====================================================================

  def get_review_num(group_notes)
    group_notes.each do |gn|
      original = Note.find(gn.original_ws_id)
      return original.peer_reviews_count if original.status == 'review'
    end
    0
  end

  # FIXME: PeerReview
  def get_peer_review(group_notes, group_index, user_id)
    user_group_index = @course.group_index_for user_id
    peer_review = {}
    peer_review[:eval] = []
    peer_review[:noeval] = []

    if (@course.learner? user_id) && (user_group_index == group_index)
      peer_review[:noeval] = group_notes.reject(&:review?)
      group_notes.delete_if { |gn| !gn.review? }
      review_num = [get_review_num(group_notes), group_notes.size - 1].min

      user_index = 0
      group_notes.each_with_index do |gn, i|
        user_index = i if gn.manager_id == user_id
      end

      peer_review[:eval] = group_notes.slice!(user_index + 1, review_num)
      rest_num = review_num - peer_review[:eval].size
      if rest_num > 0
        peer_review[:eval].concat group_notes.slice!(0, rest_num)
      end
      peer_review[:noeval].concat group_notes
    else
      peer_review[:noeval] = group_notes
    end
    peer_review
  end

  def note_course_candidates
    courses = Course.work_sheet_distributable_by session[:id]
    courses.pluck(:title, :id)
  end

  def note_status_candidates(note)
    case note.category
    when 'private'
      candidates = [['draft', t('activerecord.others.note.status.draft'), !note.status_updatable?('draft', session[:id])]]
      candidates.push ['archived', t('activerecord.others.note.status.archived'), !note.status_updatable?('archived', session[:id])]
    when 'work'
      candidates = [['draft', t('activerecord.others.note.status.draft'), !note.status_updatable?('draft', session[:id])]]
      candidates.push ['distributed_draft', t('activerecord.others.note.status.distributed_draft'), !note.status_updatable?('distributed_draft', session[:id])]
      candidates.push ['review', t('activerecord.others.note.status.review'), !note.status_updatable?('review', session[:id])]
      candidates.push ['open', t('activerecord.others.note.status.open'), !note.status_updatable?('open', session[:id])]
      candidates.push ['archived', t('activerecord.others.note.status.archived'), !note.status_updatable?('archived', session[:id])]
    end
  end

  def note_snippet_text(manager_flag, stickies)
    title = 'ふせんの数[枚]'
    if manager_flag
      title += ': '
      stickies.each_with_index do |st, i|
        title += User.full_name_for_id(st.manager_id)
        title += ', ' if i != (stickies.size - 1)
      end
    end
    title
  end

  def note_star_text(manager_flag, stared_users)
    title = 'スターの数[個]'
    if manager_flag
      title += ': '
      stared_users.each_with_index do |st, i|
        title += User.full_name_for_id(st.id)
        title += ', ' if i != (stared_users.size - 1)
      end
    end
    title
  end
end
