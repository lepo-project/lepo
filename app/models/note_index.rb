# == Schema Information
#
# Table name: note_indices
#
#  id            :integer          not null, primary key
#  note_id       :integer
#  item_id       :integer
#  display_order :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  item_type     :string           default("Snippet")
#

class NoteIndex < ApplicationRecord
  belongs_to :note, touch: true
  belongs_to :item, polymorphic: true
  validates_presence_of :display_order
  validates_presence_of :note_id
  validates_presence_of :item_id
  # validates_uniqueness_of :snippet_id, scope: [:note_id]
  validates_inclusion_of :item_type, in: %w[Snippet Content]
end
