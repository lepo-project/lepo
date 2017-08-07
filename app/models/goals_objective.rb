# == Schema Information
#
# Table name: goals_objectives
#
#  id           :integer          not null, primary key
#  lesson_id    :integer
#  goal_id      :integer
#  objective_id :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class GoalsObjective < ApplicationRecord
  belongs_to :goal
  belongs_to :lesson
  belongs_to :objective
  validates_presence_of :goal_id
  validates_presence_of :lesson_id
  validates_presence_of :objective_id
  validates_uniqueness_of :objective_id, scope: [:goal_id]
end
