# == Schema Information
#
# Table name: signins
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  src_ip     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class SigninTest < ActiveSupport::TestCase
  # ====================================================================
  # Validation Tests
  # ====================================================================
  # test for valid signin data
  test 'a signin with valid data is valid' do
    assert build(:signin).valid?
  end

  # test for validates_presence_of :user_id
  test 'a signin without user_id is invalid' do
    assert_invalid build(:signin, user_id: ''), :user_id
    assert_invalid build(:signin, user_id: nil), :user_id
  end
end
