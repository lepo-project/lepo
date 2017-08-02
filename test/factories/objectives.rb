# == Schema Information
#
# Table name: objectives
#
#  id         :integer          not null, primary key
#  content_id :integer
#  title      :string
#  criterion  :text
#  allocation :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :objective do
    sequence(:content_id) { |i| i }
    sequence(:title) { |i| "Content Objective #{i}" }
    criterion 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
    allocation 10
  end
end
