# == Schema Information
#
# Table name: outcome_texts
#
#  id         :integer          not null, primary key
#  outcome_id :integer
#  entry      :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class OutcomeText < ApplicationRecord
  belongs_to :outcome, touch: true
  validates :outcome_id, presence: true
end
