# == Schema Information
#
# Table name: courses
#
#  id                 :integer          not null, primary key
#  term_id            :integer
#  folder_id          :string
#  image_file_name    :string
#  image_content_type :string
#  image_file_size    :integer
#  image_updated_at   :datetime
#  title              :string
#  overview           :text
#  status             :string           default("draft")
#  groups_count       :integer          default(1)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'test_helper'

class CourseTest < ActiveSupport::TestCase
  # ====================================================================
  # Validation Tests
  # ====================================================================
  # test for valid course data
  test 'a course with valid data is valid' do
    assert build(:course).valid?
  end

  # test for validates_presence_of :term_id
  test 'a course without term_id is invalid' do
    assert_invalid build(:course, term_id: ''), :term_id
    assert_invalid build(:course, term_id: nil), :term_id
  end

  # test for validates_presence_of :title
  test 'a course without title is invalid' do
    assert_invalid build(:course, title: ''), :title
    assert_invalid build(:course, title: nil), :title
  end

  # test for validates_presence_of :status
  test 'a course without status is invalid' do
    assert_invalid build(:course, status: ''), :status
    assert_invalid build(:course, status: nil), :status
  end

  # test for validates_uniqueness_of :folder_id
  test 'some courses with same folder_id are invalid' do
    course = create(:course)
    assert_invalid build(:course, folder_id: course.folder_id), :folder_id
  end
end
