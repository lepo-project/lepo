# == Schema Information
#
# Table name: notices
#
#  id         :integer          not null, primary key
#  course_id  :integer
#  manager_id :integer
#  status     :string           default("open")
#  message    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :notice do
    sequence(:course_id) { |i| i }
    sequence(:manager_id) { |i| i }
    message 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
  end
end
