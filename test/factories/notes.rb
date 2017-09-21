# == Schema Information
#
# Table name: notes
#
#  id                 :integer          not null, primary key
#  manager_id         :integer
#  course_id          :integer          default(0)
#  original_note_id   :integer          default(0)
#  title              :string
#  overview           :text
#  status             :string           default("draft")
#  stars_count        :integer          default(0)
#  peer_reviews_count :integer          default(0)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  category           :string           default("private")
#

FactoryGirl.define do
  factory :note do
    association :course
    association :manager, factory: :user
    sequence(:title) { |i| "Note #{i} Title" }
    overview 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '

    factory :original_draft_worksheet do
      category 'worksheet'
      status 'draft'
    end

    factory :original_review_worksheet do
      category 'worksheet'
      status 'review'
    end

    factory :original_open_worksheet do
      category 'worksheet'
      status 'open'
    end
  end
end
