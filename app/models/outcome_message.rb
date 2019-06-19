# == Schema Information
#
# Table name: outcome_messages
#
#  id         :integer          not null, primary key
#  manager_id :integer
#  outcome_id :integer
#  message    :text
#  score      :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class OutcomeMessage < ApplicationRecord
  belongs_to :manager, class_name: 'User'
  belongs_to :outcome, touch: true
  validates :manager_id, presence: true
  validates :outcome_id, presence: true
  validates :score, inclusion: { in: (0..10).to_a }, allow_nil: true
end
