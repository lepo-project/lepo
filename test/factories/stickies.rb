# == Schema Information
#
# Table name: stickies
#
#  id          :integer          not null, primary key
#  manager_id  :integer
#  content_id  :integer
#  course_id   :integer
#  target_id   :integer
#  target_type :string           default("page")
#  stars_count :integer          default(0)
#  category    :string           default("private")
#  message     :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryGirl.define do
  factory :sticky do
    sequence(:manager_id) { |i| i }
    sequence(:content_id) { |i| i }
    sequence(:course_id) { |i| i }
    sequence(:target_id) { |i| i }
    message 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
  end
end
