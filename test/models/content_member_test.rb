# == Schema Information
#
# Table name: content_members
#
#  id         :integer          not null, primary key
#  content_id :integer
#  user_id    :integer
#  role       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class ContentMemberTest < ActiveSupport::TestCase
  # ====================================================================
  # Validation Tests
  # ====================================================================
  # test for valid content_member data
  test 'a content_member with valid data is valid' do
    assert build(:content_assistant).valid?
    assert build(:content_manager).valid?
    assert build(:content_user).valid?
  end

  # validates :content_id, presence: true
  test 'a content_member without content_id is invalid' do
    assert_invalid build(:content_assistant, content_id: ''), :content_id
    assert_invalid build(:content_assistant, content_id: nil), :content_id
  end

  # validates :content_id, uniqueness: { scope: :user_id }
  test 'some content_members with same content_id and user_id are invalid' do
    assistant = create(:content_assistant)
    assert_invalid build(:content_assistant, content_id: assistant.content_id, user_id: assistant.user_id), :content_id
  end

  # validates :role, inclusion: { in: %w[manager assistant user] }
  test 'a content_member with role that is not included in [manager assistant user] is invalid' do
    assert_invalid build(:content_assistant, role: ''), :role
    assert_invalid build(:content_assistant, role: nil), :role
  end

  # validates :user_id, presence: true
  test 'a content_member without user_id is invalid' do
    assert_invalid build(:content_assistant, user_id: ''), :user_id
    assert_invalid build(:content_assistant, user_id: nil), :user_id
  end

  # validate :content_manageable_user, if: "role != 'assistant'"
  test 'a content_member with incorrect role association is invalid' do
    assert build(:content_manager_for_user).invalid?
    assert build(:content_user_for_user).invalid?
  end
end
