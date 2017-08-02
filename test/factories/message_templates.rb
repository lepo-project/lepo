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

FactoryGirl.define do
  factory :message_template do
    sequence(:content_id) { |i| i }
    sequence(:manager_id) { |i| i }
    sequence(:objective_id) { |i| i }
    sequence(:message) { |i| "Message #{i}" }
  end
end
