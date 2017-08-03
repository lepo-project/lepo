# == Schema Information
#
# Table name: note_stars
#
#  id         :integer          not null, primary key
#  manager_id :integer
#  note_id    :integer
#  stared     :boolean          default(TRUE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class NoteStar < ApplicationRecord
  belongs_to :manager, class_name: 'User'
  belongs_to :note
  validates_presence_of :manager_id
  validates_presence_of :note_id
  validates_uniqueness_of :manager_id, scope: [:note_id]
end
