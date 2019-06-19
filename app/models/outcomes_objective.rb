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
  validates :eval_achievement, inclusion: { in: (0..10).to_a }, allow_nil: true
  validates :objective_id, presence: true
  validates :outcome_id, presence: true
  validates :outcome_id, uniqueness: { scope: :objective_id }
  validates :self_achievement, inclusion: { in: (0..10).to_a }, allow_nil: true

  # ====================================================================
  # Public Functions
  # ====================================================================
end
