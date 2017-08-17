# == Schema Information
#
# Table name: notices
#
#  id         :integer          not null, primary key
#  course_id  :integer
#  manager_id :integer
#  status     :string           default("open")
#  message    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Notice < ApplicationRecord
  belongs_to :manager, class_name: 'User'
  belongs_to :course
  validates_presence_of :manager_id
  validates_presence_of :message
  validates_inclusion_of :status, in: %w[open archived]

  # ====================================================================
  # Public Functions
  # ====================================================================
  def self.for_course(course_id)
    Notice.where(course_id: course_id, status: 'open').order(updated_at: :desc).limit(20)
  end

  def self.for_system
    for_course 0
  end
end
