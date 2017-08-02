# == Schema Information
#
# Table name: notes
#
#  id                 :integer          not null, primary key
#  manager_id         :integer
#  course_id          :integer
#  master_id          :integer          default(0)
#  title              :string
#  overview           :text
#  status             :string           default("private")
#  stars_count        :integer          default(0)
#  peer_reviews_count :integer          default(0)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'test_helper'

class NoteTest < ActiveSupport::TestCase
  # ====================================================================
  # Validation Tests
  # ====================================================================
  # test for valid note data
  test 'a note with valid data is valid' do
    assert build(:note).valid?
  end

  # test for validates_presence_of :manager_id
  test 'a note without manager_id is invalid' do
    assert_invalid build(:note, manager_id: ''), :manager_id
    assert_invalid build(:note, manager_id: nil), :manager_id
  end

  # test for validates_presence_of :status
  test 'a note without status is invalid' do
    assert_invalid build(:note, status: ''), :status
    assert_invalid build(:note, status: nil), :status
  end

  # test for validates_presence_of :title
  test 'a note without title is invalid' do
    assert_invalid build(:note, title: ''), :title
    assert_invalid build(:note, title: nil), :title
  end

end
