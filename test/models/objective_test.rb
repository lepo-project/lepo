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
end
