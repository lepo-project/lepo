# == Schema Information
#
# Table name: courses
#
#  id           :integer          not null, primary key
#  enabled      :boolean          default(TRUE)
#  sourced_id   :string
#  term_id      :integer
#  image_data   :text
#  title        :string
#  overview     :text
#  weekday      :integer          default(9)
#  period       :integer          default(0)
#  status       :string           default("draft")
#  groups_count :integer          default(1)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

FactoryBot.define do
  factory :course do
    association :term
    sequence(:sourced_id) { |i| "dummy-course-sourced_id-#{i}" }
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
