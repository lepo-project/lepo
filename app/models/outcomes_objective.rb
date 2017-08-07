# == Schema Information
#
# Table name: outcomes_objectives
#
#  id               :integer          not null, primary key
#  outcome_id       :integer
#  objective_id     :integer
#  self_achievement :integer
#  eval_achievement :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class OutcomesObjective < ApplicationRecord
  belongs_to :outcome
  belongs_to :objective
  validates_presence_of :objective_id
  validates_presence_of :outcome_id
  validates_uniqueness_of :outcome_id, scope: [:objective_id]
  validates_inclusion_of :eval_achievement, in: (0..10).to_a, allow_nil: true
  validates_inclusion_of :self_achievement, in: (0..10).to_a, allow_nil: true

  # ====================================================================
  # Public Functions
  # ====================================================================
end
