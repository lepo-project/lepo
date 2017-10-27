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

FactoryBot.define do
  factory :message_template do
    association :content
    association :manager, factory: :user
    association :objective
    sequence(:message) { |i| "Message #{i}" }
  end
end
