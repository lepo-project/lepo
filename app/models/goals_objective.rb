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
  validates :goal_id, presence: true
  validates :lesson_id, presence: true
  validates :objective_id, presence: true
  validates :objective_id, uniqueness: { scope: :goal_id }
end
