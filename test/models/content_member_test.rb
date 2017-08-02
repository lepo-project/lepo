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
    assert build(:content_member).valid?
  end

  # test for validates_presence_of :content_id
  test 'a content_member without content_id is invalid' do
    assert_invalid build(:content_member, content_id: ''), :content_id
    assert_invalid build(:content_member, content_id: nil), :content_id
  end

  # test for validates_presence_of :user_id
  test 'a content_member without user_id is invalid' do
    assert_invalid build(:content_member, user_id: ''), :user_id
    assert_invalid build(:content_member, user_id: nil), :user_id
  end

  # test for validates_presence_of :role
  # test 'a content_member without role is invalid' do
  #   assert_invalid build(:content_member, role: ''), :role
  #   assert_invalid build(:content_member, role: nil), :role
  # end

  # test for validates_uniqueness_of :content_id, scope: [:user_id]
  test 'some content_members with same content_id and user_id are invalid' do
    content_member = create(:content_member)
    assert_invalid build(:content_member, content_id: content_member.content_id, user_id: content_member.user_id), :content_id
  end
end
