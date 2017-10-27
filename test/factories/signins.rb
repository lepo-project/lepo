# == Schema Information
#
# Table name: signins
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  src_ip     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :signin do
    association :user
    src_ip '127.0.0.1'
  end
end
