# == Schema Information
#
# Table name: content_members
#
#  id         :integer          not null, primary key
#  content_id :integer
#  user_id    :integer
#  role       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :content_member do
    sequence(:content_id) { |i| i }
    sequence(:user_id) { |i| i }
    role 'assistant'
  end
end
