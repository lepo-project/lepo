# == Schema Information
#
# Table name: terms
#
#  id         :integer          not null, primary key
#  sourced_id :string
#  title      :string
#  start_at   :datetime
#  end_at     :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class TermTest < ActiveSupport::TestCase
  # ====================================================================
  # Validation Tests
  # ====================================================================
  # test for valid term data
  test 'a term with valid data is valid' do
    assert build(:term).valid?
  end

  # test for validates_presence_of :end_at
  test 'a term without end_at is invalid' do
    assert_invalid build(:term, end_at: ''), :end_at
    assert_invalid build(:term, end_at: nil), :end_at
  end

  # test for validates_presence_of :start_at
  test 'a term without start_at is invalid' do
    assert_invalid build(:term, start_at: ''), :start_at
    assert_invalid build(:term, start_at: nil), :start_at
  end

  # test for validates_presence_of :title
  test 'a term without title is invalid' do
    assert_invalid build(:term, title: ''), :title
    assert_invalid build(:term, title: nil), :title
  end

  # test for validates_uniqueness_of :sourced_id, allow_nil: true
  test 'some terms with same sourced_id are invalid' do
    term = create(:term)
    assert_invalid build(:term, sourced_id: term.sourced_id), :sourced_id
  end

  # test for validates_uniqueness_of :title
  test 'some terms with same title are invalid' do
    term = create(:term)
    assert_invalid build(:term, title: term.title), :title
  end

  # test for validate :end_at_is_after_start_at
  test 'a term with end_at that is same or before start_at is invalid' do
    assert_invalid build(:term, start_at: Date.today, end_at: Date.today), :end_at
    assert_invalid build(:term, end_at: Date.today - 1.day), :end_at
  end
end
