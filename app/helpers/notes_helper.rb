module NotesHelper
  # ====================================================================
  # Public Functions
  # ====================================================================

  def get_review_num(group_notes)
    group_notes.each do |gs|
      master = Note.find(gs.master_id)
      return master.peer_reviews_count if master.status == 'master_review'
    end
    0
  end

  # FIXME: PeerReview
  def get_peer_review(group_notes, group_id, user_id)
    user_group_id = @course.group_id_for user_id
    peer_review = {}
    peer_review[:eval] = []
    peer_review[:noeval] = []

    if (@course.learner? user_id) && (user_group_id == group_id)
      peer_review[:noeval] = group_notes.reject(&:review?)
      group_notes.delete_if { |gs| !gs.review? }
      review_num = [get_review_num(group_notes), group_notes.size - 1].min

      user_index = 0
      group_notes.each_with_index do |gs, i|
        # FIXME: PeerReview
        # no note or notes inherited from one original master note should exist in one course in peer-review status
        # wrong assumption: course note made by @user in a group_notes must be one
        user_index = i if gs.manager_id == user_id
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
end
