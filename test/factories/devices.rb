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

FactoryBot.define do
  factory :device do
    association :manager, factory: :user
    sequence(:title) { |i| "Device #{i}" }
    registration_id { (1..32).map { ('a'..'z').to_a[rand(26)] }.join }
  end
end
