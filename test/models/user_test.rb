# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  user_id            :string
#  authentication     :string           default("local")
#  hashed_password    :string
#  salt               :string
#  token              :string
#  role               :string           default("user")
#  familyname         :string
#  familyname_alt     :string
#  givenname          :string
#  givenname_alt      :string
#  folder_id          :string
#  image_file_name    :string
#  image_content_type :string
#  image_file_size    :integer
#  image_updated_at   :datetime
#  web_url            :string
#  description        :text
#  default_note_id    :integer          default(0)
#  last_signin_at     :datetime
#  archived_at        :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # ====================================================================
  # Validation Tests
  # ====================================================================
  # test for valid user data
  test 'a user with valid data is valid' do
    assert build(:user).valid?
  end

  # test for validates_presence_of :authentication
  test 'a user without authentication is invalid' do
    assert_invalid build(:user, authentication: ''), :authentication
    assert_invalid build(:user, authentication: nil), :authentication
  end

  # test for validates_presence_of :familyname
  test 'a user without familyname is invalid' do
    assert_invalid build(:user, familyname: ''), :familyname
    assert_invalid build(:user, familyname: nil), :familyname
  end

  # test for validates_presence_of :hashed_password, if: "authentication == 'local'"
  test 'a user without hashed_password is invalid' do
    assert_invalid build(:user, hashed_password: ''), :hashed_password
    assert_invalid build(:user, hashed_password: nil), :hashed_password
    assert build(:ldap_user).valid?
  end

  # test for validates_presence_of :role
  test 'a user without role is invalid' do
    assert_invalid build(:user, role: ''), :role
    assert_invalid build(:user, role: nil), :role
  end

  # test for validates_presence_of :salt, if: "authentication == 'local'"
  test 'a user without salt is invalid' do
    assert_invalid build(:user, salt: ''), :salt
    assert_invalid build(:user, salt: nil), :salt
    assert build(:ldap_user).valid?
  end

  # test for validates_presence_of :user_id
  test 'a user without user_id is invalid' do
    assert_invalid build(:user, user_id: ''), :user_id
    assert_invalid build(:user, user_id: nil), :user_id
  end

  # test for validates_uniqueness_of :folder_id
  test 'some users with same folder_id are invalid' do
    user = create(:user)
    assert_invalid build(:user, folder_id: user.folder_id), :folder_id
  end

  # test for validates_uniqueness_of :token
  test 'some users with same token are invalid' do
    user = create(:user)
    assert_invalid build(:user, token: user.token), :token
  end

  # test for validates_uniqueness_of :user_id
  test 'some users with same user_id are invalid' do
    user = create(:user)
    assert_invalid build(:user, user_id: user.user_id), :user_id
  end
end
