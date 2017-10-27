# == Schema Information
#
# Table name: sticky_stars
#
#  id         :integer          not null, primary key
#  manager_id :integer
#  sticky_id  :integer
#  stared     :boolean          default(TRUE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :sticky_star do
    association :manager, factory: :user
    association :sticky
  end
end
