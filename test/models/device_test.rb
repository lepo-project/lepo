# == Schema Information
#
# Table name: devices
#
#  id              :integer          not null, primary key
#  manager_id      :integer
#  title           :string
#  registration_id :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'test_helper'

class DeviceTest < ActiveSupport::TestCase
  # ====================================================================
  # Validation Tests
  # ====================================================================
  # test for valid device data
  test 'a device with valid data is valid' do
    assert build(:device).valid?
  end

  # validates :manager_id, presence: true
  test 'a device without manager_id is invalid' do
    assert_invalid build(:device, manager_id: ''), :manager_id
    assert_invalid build(:device, manager_id: nil), :manager_id
  end

  # validates :registration_id, uniqueness: true
  test 'some devices with same registration_id are invalid' do
    device = create(:device)
    assert_invalid build(:device, registration_id: device.registration_id), :registration_id
  end

  # validates :title, presence: true
  test 'a device without title is invalid' do
    assert_invalid build(:device, title: ''), :title
    assert_invalid build(:device, title: nil), :title
  end
end
