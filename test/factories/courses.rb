# == Schema Information
#
# Table name: courses
#
#  id           :integer          not null, primary key
#  term_id      :integer
#  title        :string
#  overview     :text
#  status       :string           default("draft")
#  groups_count :integer          default(1)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  image_data   :text
#  guid         :string
#  weekday      :integer          default(9)
#  period       :integer          default(0)
#  enabled      :boolean          default(TRUE)
#

FactoryBot.define do
  factory :course do
    association :term
    sequence(:guid) { |i| "dummy-course-guid-#{i}" }
    sequence(:title) { |i| "Course #{i} Title" }
    overview 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
    weekday 9

    factory :open_course do
      status 'open'
    end

    factory :archived_course do
      status 'archived'
    end
  end
end
