# == Schema Information
#
# Table name: objectives
#
#  id         :integer          not null, primary key
#  content_id :integer
#  title      :string
#  criterion  :text
#  allocation :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class ObjectiveTest < ActiveSupport::TestCase
  # ====================================================================
  # Validation Tests
  # ====================================================================
  # test for valid objective data
  test 'a objective with valid data is valid' do
    assert build(:objective).valid?
  end

  # test for validates_presence_of :title
  test 'a objective without title is invalid' do
    assert_invalid build(:objective, title: ''), :title
    assert_invalid build(:objective, title: nil), :title
  end

  # test for validates_inclusion_of :allocation, in: (1..10).to_a, allow_nil: true
  test 'a objective with allocation that is not included in (0..10).to_a is invalid' do
    assert build(:objective, allocation: nil).valid?
    assert_invalid build(:objective, allocation: 0), :allocation
    assert_invalid build(:objective, allocation: 11), :allocation
  end
end
