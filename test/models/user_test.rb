# == Schema Information
#
# Table name: users
#
#  id                   :integer          not null, primary key
#  signin_name          :string
#  authentication       :string           default("local")
#  hashed_password      :string
#  salt                 :string
#  token                :string
#  role                 :string           default("user")
#  family_name          :string
#  given_name           :string
#  phonetic_family_name :string
#  phonetic_given_name  :string
#  image_data           :text
#  web_url              :string
#  description          :text
#  default_note_id      :integer          default(0)
#  last_signin_at       :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  sourced_id           :string
#

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # ====================================================================
  # Validation Tests
  # ====================================================================
  # test for valid user data
  test 'a user with valid data is valid' do
    assert build(:user).valid?
    assert build(:admin_user).valid?
    assert build(:manager_user).valid?
    assert build(:suspended_user).valid?
    assert build(:ldap_user).valid?
  end

  # validates :authentication, inclusion: { in: %w[local ldap] }
  test 'a user with authentication that is not included in [local ldap] is invalid' do
    assert_invalid build(:user, authentication: ''), :authentication
    assert_invalid build(:user, authentication: nil), :authentication
  end

  # validates :family_name, presence: true
  test 'a user without family_name is invalid' do
    assert_invalid build(:user, family_name: ''), :family_name
    assert_invalid build(:user, family_name: nil), :family_name
  end

  # validates :hashed_password, presence: true, if: "authentication == 'local'"
  test 'a user without hashed_password is invalid' do
    assert_invalid build(:user, hashed_password: ''), :hashed_password
    assert_invalid build(:user, hashed_password: nil), :hashed_password
  end

  # validates :password, confirmation: true
  test 'a user with password that is not same to password_confirmation is invalid' do
    assert_invalid build(:user, password_confirmation: 'temporary2'), :password_confirmation
  end

  # validates :password, length: { in: USER_PASSWORD_MIN_LENGTH..USER_PASSWORD_MAX_LENGTH }, allow_blank: true, if: "authentication == 'local'"
  test 'a user with incorrect length password is invalid' do
    assert_invalid build(:user, password: 'a' * (USER_PASSWORD_MIN_LENGTH - 1)), :password
    assert_invalid build(:user, password: 'a' * (USER_PASSWORD_MAX_LENGTH + 1)), :password
  end

  # validates :role, inclusion: { in: %w[admin manager user suspended] }
  test 'a user with role that is not included in [admin manager user suspended] is invalid' do
    assert_invalid build(:user, role: ''), :role
    assert_invalid build(:user, role: nil), :role
  end

  # validates :salt, presence: true, if: "authentication == 'local'"
  test 'a user without salt is invalid' do
    assert_invalid build(:user, salt: ''), :salt
    assert_invalid build(:user, salt: nil), :salt
  end

  # validates :signin_name, presence: true
  test 'a user without signin_name is invalid' do
    assert_invalid build(:user, signin_name: ''), :signin_name
    assert_invalid build(:user, signin_name: nil), :signin_name
  end

  # validates :signin_name, uniqueness: true
  test 'some users with same signin_name are invalid' do
    user = create(:user)
    assert_invalid build(:user, signin_name: user.signin_name), :signin_name
  end

  # validates :sourced_id, uniqueness: true, allow_nil: true
  test 'some users with same sourced_id are invalid' do
    user = create(:user)
    assert_invalid build(:user, sourced_id: user.sourced_id), :sourced_id
  end

  # validates :token, presence: true
  # this test is no need because of before_validation callback

  # validates :token, uniqueness: true
  test 'some users with same token are invalid' do
    user = create(:user)
    assert_invalid build(:user, token: user.token), :token
  end

  # validate :password_non_blank, if: "authentication == 'local'"
  test 'a user without password is invalid' do
    assert_invalid build(:user, password: ''), :password
    assert_invalid build(:user, password: nil), :password
  end
end
