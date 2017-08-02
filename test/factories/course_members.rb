# == Schema Information
#
# Table name: course_members
#
#  id         :integer          not null, primary key
#  course_id  :integer
#  user_id    :integer
#  role       :string
#  group_id   :integer          default(0)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :course_member do
    sequence(:course_id) { |i| i }
    sequence(:user_id) { |i| i }
    role 'manager'
  end
end
