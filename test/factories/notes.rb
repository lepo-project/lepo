# == Schema Information
#
# Table name: notes
#
#  id                 :integer          not null, primary key
#  manager_id         :integer
#  course_id          :integer
#  master_id          :integer          default(0)
#  title              :string
#  overview           :text
#  status             :string           default("private")
#  stars_count        :integer          default(0)
#  peer_reviews_count :integer          default(0)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

FactoryGirl.define do
  factory :note do
    sequence(:manager_id) { |i| i }
    sequence(:course_id) { |i| i }
    sequence(:title) { |i| "Note #{i} Title" }
    overview 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
  end
end
