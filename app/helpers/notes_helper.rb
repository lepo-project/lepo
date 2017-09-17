module NotesHelper
  # ====================================================================
  # Public Functions
  # ====================================================================

  def get_review_num(group_notes)
    group_notes.each do |gn|
      original = Note.find(gn.original_note_id)
      return original.peer_reviews_count if original.status == 'master_review'
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
        # FIXME: PeerReview
        # no note or notes inherited from one original note should exist in one course in peer-review status
        # wrong assumption: course note made by current_user in a group_notes must be one
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
