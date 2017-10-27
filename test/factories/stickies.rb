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

FactoryBot.define do
  factory :sticky do
    association :manager, factory: :user
    association :content
    # association :target, factory: :page_file
    # association :target, factory: :note
    sequence(:course_id) { |i| i }
    sequence(:target_id) { |i| i }
    message 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '

    factory :course_sticky do
      category 'course'
    end

    factory :note_sticky do
      target_type 'note'
    end

    factory :course_note_sticky do
      category 'course'
      target_type 'note'
    end
  end
end
