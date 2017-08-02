# == Schema Information
#
# Table name: goals
#
#  id         :integer          not null, primary key
#  course_id  :integer
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class GoalTest < ActiveSupport::TestCase
  # ====================================================================
  # Validation Tests
  # ====================================================================
  # test for valid goal data
  test 'a goal with valid data is valid' do
    assert build(:goal).valid?
  end

  # test for validates_presence_of :title
  test 'a goal without title is invalid' do
    assert_invalid build(:goal, title: ''), :title
    assert_invalid build(:goal, title: nil), :title
  end
end
