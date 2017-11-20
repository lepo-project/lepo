# == Schema Information
#
# Table name: notes
#
#  id                 :integer          not null, primary key
#  manager_id         :integer
#  course_id          :integer          default(0)
#  original_ws_id     :integer          default(0)
#  title              :string
#  overview           :text
#  status             :string           default("draft")
#  stars_count        :integer          default(0)
#  peer_reviews_count :integer          default(0)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  category           :string           default("private")
#

FactoryBot.define do
  factory :note do
    association :manager, factory: :user
    sequence(:title) { |i| "Note #{i} Title" }
    overview 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '

    factory :lesson_note do
      category 'lesson'
      association :course
      status 'associated_course'
    end

    factory :original_draft_work_sheet do
      category 'work'
      association :course
    end

    factory :original_review_work_sheet do
      category 'work'
      association :course
      status 'review'
    end

    factory :original_open_work_sheet do
      category 'work'
      association :course
      status 'open'
    end
  end
end
