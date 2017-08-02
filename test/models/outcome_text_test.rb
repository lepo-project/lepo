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

require 'test_helper'

class OutcomeTextTest < ActiveSupport::TestCase
  # ====================================================================
  # Validation Tests
  # ====================================================================
  # test for valid outcome_text data
  test 'a outcome_text with valid data is valid' do
    assert build(:outcome_text).valid?
  end

  # test for validates_presence_of :outcome_id
  test 'a outcome_text without outcome_id is invalid' do
    assert_invalid build(:outcome_text, outcome_id: ''), :outcome_id
    assert_invalid build(:outcome_text, outcome_id: nil), :outcome_id
  end
end
