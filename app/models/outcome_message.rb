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
  validates_presence_of :manager_id
  validates_presence_of :outcome_id
  validates_inclusion_of :score, in: (0..10).to_a, allow_nil: true
end
