# == Schema Information
#
# Table name: message_templates
#
#  id           :integer          not null, primary key
#  manager_id   :integer
#  content_id   :integer
#  objective_id :integer
#  counter      :integer          default(0)
#  message      :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'test_helper'

class MessageTemplateTest < ActiveSupport::TestCase
  # ====================================================================
  # Validation Tests
  # ====================================================================
  # test for valid message_template data
  test 'a message_template with valid data is valid' do
    assert build(:message_template).valid?
  end

  # test for validates_presence_of :content_id
  test 'a message_template without content_id is invalid' do
    assert_invalid build(:message_template, content_id: ''), :content_id
    assert_invalid build(:message_template, content_id: nil), :content_id
  end

  # test for validates_presence_of :manager_id
  test 'a message_template without manager_id is invalid' do
    assert_invalid build(:message_template, manager_id: ''), :manager_id
    assert_invalid build(:message_template, manager_id: nil), :manager_id
  end

  # test for validates_presence_of :message
  test 'a message_template without message is invalid' do
    assert_invalid build(:message_template, message: ''), :message
    assert_invalid build(:message_template, message: nil), :message
  end

  # test for validates_presence_of :objective_id
  test 'a message_template without objective_id is invalid' do
    assert_invalid build(:message_template, objective_id: ''), :objective_id
    assert_invalid build(:message_template, objective_id: nil), :objective_id
  end
end
