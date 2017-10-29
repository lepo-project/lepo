# == Schema Information
#
# Table name: note_indices
#
#  id            :integer          not null, primary key
#  note_id       :integer
#  snippet_id    :integer
#  display_order :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class NoteIndex < ApplicationRecord
  belongs_to :note, touch: true
  belongs_to :snippet
  validates_presence_of :display_order
  validates_presence_of :note_id
  validates_presence_of :snippet_id
  validates_uniqueness_of :snippet_id, scope: [:note_id]
end
