# == Schema Information
#
# Table name: sticky_stars
#
#  id         :integer          not null, primary key
#  manager_id :integer
#  sticky_id  :integer
#  stared     :boolean          default(TRUE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class StickyStar < ApplicationRecord
  belongs_to :manager, class_name: 'User'
  belongs_to :sticky
  validates :manager_id, presence: true
  validates :manager_id, uniqueness: { scope: :sticky_id }
  validates :sticky_id, presence: true
end
