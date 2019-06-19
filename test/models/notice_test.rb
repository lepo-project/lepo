# == Schema Information
#
# Table name: notices
#
#  id         :integer          not null, primary key
#  course_id  :integer
#  manager_id :integer
#  status     :string           default("open")
#  message    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class NoticeTest < ActiveSupport::TestCase
  # ====================================================================
  # Validation Tests
  # ====================================================================
  # test for valid notice data
  test 'a notice with valid data is valid' do
    assert build(:notice).valid?
    assert build(:archived_notice).valid?
  end

  # validates :manager_id, presence: true
  test 'a notice without manager_id is invalid' do
    assert_invalid build(:notice, manager_id: ''), :manager_id
    assert_invalid build(:notice, manager_id: nil), :manager_id
  end

  # validates :message, presence: true
  test 'a notice without message is invalid' do
    assert_invalid build(:notice, message: ''), :message
    assert_invalid build(:notice, message: nil), :message
  end

  # validates :status, inclusion: { in: %w[open archived] }
  test 'a notice with status that is not included in [open archived] is invalid' do
    assert_invalid build(:notice, status: ''), :status
    assert_invalid build(:notice, status: nil), :status
  end
end
