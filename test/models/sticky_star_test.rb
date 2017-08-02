# == Schema Information
#
# Table name: sticky_stars
#
#  id         :integer          not null, primary key
#  manager_id :integer
#  sticky_id  :integer
#  stared     :boolean          default(TRUE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class StickyStarTest < ActiveSupport::TestCase
  # ====================================================================
  # Validation Tests
  # ====================================================================
  # test for valid sticky_star data
  test 'a sticky_star with valid data is valid' do
    assert build(:sticky_star).valid?
  end

  # test for validates_presence_of :manager_id
  test 'a sticky_star without manager_id is invalid' do
    assert_invalid build(:sticky_star, manager_id: ''), :manager_id
    assert_invalid build(:sticky_star, manager_id: nil), :manager_id
  end

  # test for validates_presence_of :sticky_id
  test 'a sticky_star without sticky_id is invalid' do
    assert_invalid build(:sticky_star, sticky_id: ''), :sticky_id
    assert_invalid build(:sticky_star, sticky_id: nil), :sticky_id
  end

  # test for validates_uniqueness_of :manager_id, scope: [:sticky_id]
  test 'some sticky_stars with same manager_id and sticky_id are invalid' do
    sticky_star = create(:sticky_star)
    assert_invalid build(:sticky_star, manager_id: sticky_star.manager_id, sticky_id: sticky_star.sticky_id), :manager_id
  end
end
