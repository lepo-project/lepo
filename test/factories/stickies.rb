# == Schema Information
#
# Table name: stickies
#
#  id          :integer          not null, primary key
#  manager_id  :integer
#  content_id  :integer
#  course_id   :integer
#  target_id   :integer
#  target_type :string           default("Page")
#  stars_count :integer          default(0)
#  category    :string           default("private")
#  message     :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryBot.define do
  factory :sticky do
    association :manager, factory: :user
    association :content
    association :target, factory: :page
    sequence(:course_id) { |i| i }
    message 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '

    factory :course_sticky do
      category 'course'
    end

    factory :note_sticky do
      content_id :nil
      association :target, factory: :note
      target_type 'Note'
    end

    factory :course_note_sticky do
      category 'course'
      content_id :nil
      association :target, factory: :note
      target_type 'Note'
    end
  end
end
