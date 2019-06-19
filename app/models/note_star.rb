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
  validates :manager_id, presence: true
  validates :manager_id, uniqueness: { scope: :note_id }
  validates :note_id, presence: true
end
