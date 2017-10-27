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

FactoryBot.define do
  factory :notice do
    association :manager, factory: :user
    association :course
    message 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '

    factory :archived_notice do
      status 'archived'
    end
  end
end
