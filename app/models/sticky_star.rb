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
  validates_presence_of :manager_id
  validates_presence_of :sticky_id
  validates_uniqueness_of :manager_id, scope: [:sticky_id]
end
