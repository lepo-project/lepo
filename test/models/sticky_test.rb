# == Schema Information
#
# Table name: stickies
#
#  id          :integer          not null, primary key
#  manager_id  :integer
#  content_id  :integer
#  course_id   :integer
#  target_id   :integer
#  target_type :string           default("Page")
#  stars_count :integer          default(0)
#  category    :string           default("private")
#  message     :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'test_helper'

class StickyTest < ActiveSupport::TestCase
  # ====================================================================
  # Validation Tests
  # ====================================================================
  # test for valid sticky data
  test 'a sticky with valid data is valid' do
    assert build(:sticky).valid?
    assert build(:course_sticky).valid?
    assert build(:note_sticky).valid?
    assert build(:course_note_sticky).valid?
  end

  # test for validates_absence_of :content_id, if: "target_type == 'Note'"
  test 'a note sticky with content_id is invalid' do
    assert_invalid build(:note_sticky, content_id: 1), :content_id
  end

  # test for validates_presence_of :content_id, if: "target_type == 'Page'"
  test 'a page sticky without content_id is invalid' do
    assert_invalid build(:sticky, content_id: ''), :content_id
    assert_invalid build(:sticky, content_id: nil), :content_id
  end

  # test for validates_presence_of :course_id, if: "category == 'course'"
  test 'a course sticky without course_id is invalid' do
    assert_invalid build(:course_sticky, course_id: ''), :course_id
    assert_invalid build(:course_sticky, course_id: nil), :course_id
  end

  # test for validates_presence_of :manager_id
  test 'a sticky without manager_id is invalid' do
    assert_invalid build(:sticky, manager_id: ''), :manager_id
    assert_invalid build(:sticky, manager_id: nil), :manager_id
  end

  # test for validates_presence_of :target_id
  test 'a sticky without target_id is invalid' do
    assert_invalid build(:sticky, target_id: ''), :target_id
    assert_invalid build(:sticky, target_id: nil), :target_id
  end

  # test for validates_inclusion_of :category, in: %w[private course]
  test 'a sticky with category that is not incluede in [private course] is invalid' do
    assert_invalid build(:sticky, category: ''), :category
    assert_invalid build(:sticky, category: nil), :category
  end

  # test for validates_inclusion_of :target_type, in: %w[Page Note]
  test 'a sticky with target_type that is not incluede in [Page Note] is invalid' do
    assert_invalid build(:sticky, target_type: ''), :target_type
    assert_invalid build(:sticky, target_type: nil), :target_type
  end
end
